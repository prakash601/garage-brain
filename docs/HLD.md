# High-Level Design (HLD) — Garage Brain / Workshop OS

**Version:** 1.0.0 · **Date:** 2026-08-22 · **Status:** Implemented (MVP)  
**Principles:** offline-first, local-first reads, single-writer LWW, zero-cost notification.

---

## 1. System Context (C4 L1)

```mermaid
C4Context
  title System Context — Workshop OS

  Person(receptionist, "Receptionist", "1 Android device; creates/finds jobs")
  Person(owner, "Owner", "Web browser; dashboard + backups")
  System_Ext(supabase, "Supabase", "Postgres + Auth + RLS (durable truth)")
  System_Ext(whatsapp, "WhatsApp", "wa.me deep link (no vendor cost)")
  System(workshop, "Workshop OS (Flutter)", "Riverpod · Drift SQLite · go_router")

  Rel(receptionist, workshop, "Uses (offline-first)")
  Rel(owner, workshop, "Reviews via Web")
  Rel(workshop, supabase, "Sync: upsert unsynced rows / pull since cursor")
  Rel(workshop, whatsapp, "Opens wa.me/<phone>?text= at ReadyForDelivery")
  UpdateLayoutConfig($c4ShapeInRow="true", $c4BoundaryInRow="true")
```

**Boundary:** one physical workshop. No multi-tenant routing. Free-tier constraints assumed.

---

## 2. Container View (C4 L2)

```mermaid
flowchart TB
  subgraph Client["Flutter App — Android + Web"]
    direction TB
    UI["UI Layer<br/>features/auth, dashboard, search,<br/>create_job, job_detail, old_bills, backup<br/> + routing/go_router"]
    State["State<br/>Riverpod providers<br/>(auth, search, dashboard, etc.)"]
    Repo["Repository Layer<br/>Customer / Vehicle / Job /<br/>OldBills / Ownership"]
    Drift["Drift (SQLite)<br/>AppDatabase · 6 tables + synced flag<br/>drift_flutter (Wasm on Web)"]
    Sync["SyncWorker<br/>30s timer + connectivity_plus<br/>+ RemoteGateway"]
    Backup["BackupService + BackupScheduler<br/>JSON export + SQLite copy"]
    Core["Core<br/>phone/plate normalizers, validators,<br/>job_number formatter, theme, AppConfig"]
  end

  Supabase[("Supabase Postgres<br/>customers, vehicles, car_ownership_history,<br/>job_cards, old_bills, recommendation_queue<br/>+ job_no_seq + RLS + profiles + hook")]

  UI --> State --> Repo --> Drift
  Core -. used by .-> UI & Repo
  Repo -. writes synced=false .-> Drift
  Sync <--> Drift
  Sync <--> Supabase
  Backup <--> Drift
  UI --> Sync
  UI --> Backup

  classDef shipped fill:#c8e6c9,stroke:#2e7d32
  class UI,State,Repo,Drift,Sync,Backup,Core shipped
```

**Dependency rule:** `UI → State → Repository → Drift`; screens never call Supabase except via `SyncWorker`/`RemoteGateway` and Auth.

---

## 3. Key Decisions & Trade-offs

| Decision | Choice | Consequence | Alternative rejected |
|---|---|---|---|
| Offline queue location | `synced` boolean in Drift only (`tables.dart:5`) | Server never knows pending; trivial LWW | Server-side pending table |
| PK generation | Client UUID v4 (`uuid` package) | Offline inserts upsert cleanly; no seq reservation complexity | Server-assigned `job_no_seq` only (would block offline) |
| Conflict | LWW on `updated_at` (trigger `touch_updated_at()` in `0001_init.sql`) | Low risk (1 writer) | CRDT / vector clock |
| Notification | `wa.me` deep link + `url_launcher` (`features/job_detail/whatsapp.dart`) | Zero cost/vendor | SMS gateway / Twilio |
| AuthZ shape | JWT `app_role` via `auth.custom_access_token_hook` (`0002_rls.sql`), RLS `staff_read/insert/update`, `recommendation_queue` owner-only | Client ships only anon key | Custom backend RBAC |
| Local DB on Web | `drift_flutter` Wasm (`app_database.dart:34`) | Single schema across platforms | IndexedDB wrapper |
| Backup | Dual: raw SQLite copy (Android) + weekly JSON export (cross-platform) | Web gravity: JSON is real restore path | Server-only backups |

---

## 4. Data Flow — Write Path (Create Job)

```mermaid
sequenceDiagram
  actor R as Receptionist
  participant UI as CreateJobScreen
  participant Svc as CreateJobService
  participant CR as CustomerRepository
  participant VR as VehicleRepository
  participant OR as OwnershipRepository
  participant JR as JobRepository
  participant DB as Drift AppDatabase
  participant SW as SyncWorker
  participant GW as RemoteGateway
  participant PG as Supabase PG

  R->>UI: Fill plate → normalizePlate() + classifyPlate()<br/>(plate.dart:6/9) + make/model/fuel<br/>+ name/phone normalizePhone() + complaints/KM
  UI->>Svc: save(...)
  Svc->>CR: upsert by phone (phone = identity)
  CR->>DB: insertOnConflictUpdate customers (synced=false)
  Svc->>VR: upsert by plate (upper + strip)
  VR->>DB: insertOnConflictUpdate vehicles (synced=false)
  Svc->>OR: close old / open new if owner changed
  OR->>DB: car_ownership_history (synced=false)
  Svc->>JR: insert job_cards {client UUID, local job_no, status=Arrived, synced=false}
  JR->>DB: insert job_cards
  Svc-->>UI: success (snackbar) — no network wait
  Note over SW,PG: Later: app start / reconnect / 30s timer
  SW->>DB: select where synced=false (FK-safe order)
  SW->>GW: upsert(table, rows)
  GW->>PG: upsert by UUID
  PG-->>GW: ok
  SW->>DB: update synced=true, syncedAt=now()
  SW->>PG: fetchSince(cursor) → pull remote → insertOnConflictUpdate with _localWins / LWW
```

**Invariant:** screen success is decoupled from network; `synced` is the only queue signal.

---

## 5. Data Flow — Read Path (Search + Dashboard)

```mermaid
flowchart LR
  User --> Box["Search box<br/>(debounced)"]
  Box --> Norm{"normalizePhone / normalizePlate<br/>classifyPlate green/amber/red"}
  Norm -->|"plate fragment"| QV["Drift: vehicles where plate LIKE %frag%"]
  Norm -->|"phone digits"| QC["Drift: customers where phone LIKE %digits%"]
  QV & QC --> Merge["Merge → job_cards JOIN vehicles/customers<br/>+ old_bills by plate/phone<br/>sort by created_at desc"]
  Merge --> Timeline["Timeline UI<br/>tap → /job/:id"]

  Dash["Dashboard"] --> DQ["Drift: job_cards where<br/>created_at today<br/>+ closed=false"]
  DQ --> Chips["Status chips + pending/completed counts<br/>Delivered → manual Close sets closed=true"]
```

All reads prefer Drift; Supabase is **pull-on-sync** only (`sync_worker.dart:62` — pulls before pushes).

---

## 6. Synchronization Model

```mermaid
flowchart TB
  subgraph Triggers
    Start["App start → syncNow()"]
    Timer["30 s Timer.periodic"]
    Conn["connectivity_plus onConnectivityChanged<br/>none → has connection"]
  end

  subgraph SyncWorker["SyncWorker.syncNow() — reentrant guard _syncing"]
    direction TB
    Pull["Pull (FK-safe order)<br/>fetchSince per table<br/>_cursors[table] = max created_at/updated_at<br/>_localWins / !synced guard → insertOnConflictUpdate"]
    Push["Push (FK-safe order)<br/>select where synced=false<br/>gateway.upsert(UUID)<br/>→ synced=true, syncedAt=now()"]
    Pull --> Push
  end

  Triggers --> SyncWorker
  SyncWorker --> Drift[(Drift)]
  SyncWorker <--> Supabase[(Supabase)]

  Note["Conflict: job_cards LWW on updated_at<br/>others: dirty local wins until flushed"]
```

**Cursors:** in-memory `_cursors: Map<String,String>` keyed by table; iso strings, monotonic via `_bump` (`sync_worker.dart:81`). Single-device assumption makes volatile cursors acceptable; a full pull resyncs if process restarts.

---

## 7. Security & Privacy

```mermaid
flowchart TB
  Login["LoginScreen — email+password<br/>(supabase_flutter)"] --> SupaAuth["Supabase Auth<br/>auth.users + profiles.role"]
  SupaAuth --> Hook["Custom Access Token Hook<br/>auth.custom_access_token_hook(jsonb)<br/>injects app_role claim"]
  Hook --> JWT["JWT { app_role: receptionist|owner|anon }"]
  JWT --> RLS["RLS policies<br/>staff_read/insert/update everywhere<br/>recommendation_queue owner-only<br/>owner_delete on most tables"]
  RLS --> Tables[("customers · vehicles · job_cards ·<br/>car_ownership_history · old_bills")]

  Client["Client ships only anon key<br/>(--dart-define SUPABASE_ANON_KEY)"]
  Client -. used by .-> Login
```

- No `.env` committed; service key never shipped (AGENTS.md Secrets).
- Phone stored bare 10 digits, plate bare alnum; no PII beyond name+phone.
- Client UUIDs mean no sequence enumeration.

---

## 8. Deployment View

```mermaid
flowchart TB
  Dev["Developer"] --> CLI["supabase link + db push<br/>(or Dashboard SQL Editor)"]
  CLI --> SupaProj[("Supabase Project<br/>migrations 0001_init + 0002_rls<br/>+ Auth hook enabled<br/>+ profiles seed")]

  Dev --> Flutter["flutter build apk / build web<br/>--dart-define SUPABASE_URL/ANON_KEY"]
  Flutter --> APK["Android APK<br/>(backup: Documents/backups/*.sqlite + *.json)"]
  Flutter --> Web["Web build (Wasm SQLite)<br/>(backup: exportJsonString dialog)"]
  APK & Web --> Users["Receptionist (Android) + Owner (Web)"]
  Users <--> SupaProj

  Docs["docs/ + docs-site/<br/>VitePress/Docsify/Astro<br/>→ GitHub Pages / Vercel / Netlify"]
  Docs -. deploy .-> Pages["Static hosting"]
```

- Local dev without keys runs fully offline + auto-seeds demo data (`main.dart:28`).
- `flutter analyze && flutter test` is the CI gate (no backend needed for tests — in-memory Drift).

---

## 9. Non-Functional Mapping

| Concern | HLD answer |
|---|---|
| <3 s search | Drift indexes + local-only reads; no network in path |
| Zero loss | `synced=false` queue + aggressive push + idempotent upsert |
| Roles | JWT + RLS, owner gated `/admin`, `recommendation_queue` owner-only |
| Cost | Free Supabase tier + `wa.me`; no vendor |
| Backup | BackupService JSON (portable) + file copy (Android) + BackupScheduler |
| Testability | Pure normalizers/validators + in-memory Drift + fake `RemoteGateway`/`AuthGateway` |

---

## 10. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Lost cursors on restart → re-pull volume | Per-table `created_at` cursors; idempotent `insertOnConflictUpdate`; small dataset (<500 bills + daily jobs) |
| Plate garbage | Amber allows non-classic `6–11` alnum; red only on non-alnum/length fail — business rule wants accept |
| Job number gaps/collision offline | Client UUID PK + server `job_no_seq` as display number; offline placeholder `job_no` replaced on sync or range reservation later |
| Web file backup unsupported | JSON export dialog is primary restore; file copy is best-effort Android-only |
| Auth hook misconfig | Troubleshooting section in `app/README.md:246`; pre-seeded demo users in seed for offline dev |
