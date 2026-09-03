# Diagrams — Garage Brain (All Mermaid)

**Every diagram here also appears inline in `HLD.md` / `LLD.md`. This file collects them for reviews and for the docs-site gallery.**

> Tip: paste any block into https://mermaid.live or render via VitePress/Docsify/VS Code.

---

## 1. System Context

```mermaid
C4Context
  title System Context — Workshop OS
  Person(receptionist, "Receptionist", "1 Android device; creates/finds jobs")
  Person(owner, "Owner", "Web browser; dashboard + backups")
  System_Ext(supabase, "Supabase", "Postgres + Auth + RLS (durable truth)")
  System_Ext(whatsapp, "WhatsApp", "wa.me deep link")
  System(workshop, "Workshop OS (Flutter)", "Riverpod · Drift SQLite · go_router")
  Rel(receptionist, workshop, "Uses (offline-first)")
  Rel(owner, workshop, "Reviews via Web")
  Rel(workshop, supabase, "Sync: upsert / pull since cursor")
  Rel(workshop, whatsapp, "wa.me at ReadyForDelivery")
```

---

## 2. Container / Module Map

```mermaid
flowchart TB
  subgraph Client["Flutter App — Android + Web"]
    direction TB
    UI["UI — features/*"]
    State["State — Riverpod"]
    Repo["Repositories"]
    Drift["Drift (SQLite)"]
    Sync["SyncWorker + RemoteGateway"]
    Backup["BackupService"]
    Core["Core — phone/plate/job_number"]
  end
  Supabase[("Supabase Postgres\nRLS + Auth + hook")]
  UI --> State --> Repo --> Drift
  Sync <--> Drift
  Sync <--> Supabase
  Backup <--> Drift
```

---

## 3. ER Diagram (Drift + Supabase)

```mermaid
erDiagram
  customers ||--o{ vehicles : current_customer_id
  vehicles ||--o{ car_ownership_history : vehicle_number_plate
  customers ||--o{ car_ownership_history : customer_id
  customers ||--o{ job_cards : customer_id
  vehicles ||--o{ job_cards : vehicle_number_plate
  vehicles ||--o{ old_bills : vehicle_number_plate
  customers ||--o{ recommendation_queue : customer_id

  customers { text id PK text phone UK }
  vehicles { text numberPlate PK text vehicleType }
  car_ownership_history { text id PK text vehicleNumberPlate FK }
  job_cards { text id PK int jobNo text status bool closed }
  old_bills { text id PK text billNo UK }
  recommendation_queue { text id PK text type }
```

Full column detail in `LLD.md §2.1`.

---

## 4. Write Path — Create Job

```mermaid
sequenceDiagram
  actor R as Receptionist
  participant UI as CreateJobScreen
  participant Svc as CreateJobService
  participant Repo as Repositories
  participant DB as Drift
  participant SW as SyncWorker
  participant PG as Supabase
  R->>UI: Fill form (plate/phone normalized)
  UI->>Svc: save(...)
  Svc->>Repo: customer upsert (phone=identity)
  Svc->>Repo: vehicle upsert (plate PK)
  Svc->>Repo: ownership close/open
  Svc->>Repo: job_cards insert (UUID, Arrived, synced=false)
  Repo->>DB: writes
  Svc-->>UI: snackbar (no network wait)
  SW->>PG: upsert unsynced rows
  PG-->>SW: ok
  SW->>DB: synced=true
  SW->>PG: fetchSince → insertOnConflictUpdate
```

---

## 5. Read Path — Search + Dashboard

```mermaid
flowchart LR
  User --> Box["Search box (debounced)"]
  Box --> Norm{"normalizePlate / normalizePhone\nclassifyPlate"}
  Norm --> QV["vehicles LIKE %frag%"]
  Norm --> QC["customers LIKE %digits%"]
  QV & QC --> Merge["jobs + old_bills merge\nsort desc"]
  Merge --> Timeline["Timeline → /job/:id"]
  Dash["Dashboard"] --> DQ["job_cards today && !closed"]
  DQ --> Chips["chips + pending/completed\nDelivered→Close"]
```

---

## 6. Sync Worker — Triggers + Pull→Push

```mermaid
flowchart TB
  Start["App start"] --> SW["SyncWorker.syncNow()\npull FK-safe → push FK-safe\n_cursors + _localWins + _syncing guard"]
  Timer["30 s timer"] --> SW
  Conn["connectivity_plus\nonConnectivityChanged"] --> SW
  SW <--> Drift[(Drift)]
  SW <--> Supa[(Supabase)]
```

---

## 7. Auth + RLS

```mermaid
flowchart TB
  Login["LoginScreen email+password"] --> Auth["Supabase Auth"]
  Auth --> Hook["auth.custom_access_token_hook\ninjects app_role"]
  Hook --> JWT["JWT app_role"]
  JWT --> RLS["RLS: staff_read/insert/update\nrecommendation_queue owner-only"]
  RLS --> Tables[("customers · vehicles · job_cards …")]
```

---

## 8. Job Status State Machine

```mermaid
stateDiagram-v2
  [*] --> Arrived
  Arrived --> InProgress
  InProgress --> ReadyForDelivery : WhatsApp button appears
  ReadyForDelivery --> Delivered
  Delivered --> Closed : closeJob (closed=true)
  note right of Closed : closed is a bool, not a status value
```

---

## 9. Deployment

```mermaid
flowchart TB
  Dev --> CLI["supabase link + db push"]
  CLI --> Supa[("Supabase Project")]
  Dev --> Flutter["flutter build apk/web\n--dart-define URL/ANON_KEY"]
  Flutter --> APK["APK"]
  Flutter --> Web["Web (Wasm)"]
  APK & Web --> Users["Receptionist + Owner"]
  Users <--> Supa
```

---

## 10. Backup / Restore

```mermaid
flowchart LR
  Drift[(Drift)] --> Export["BackupService\nbuildExportJson → writeExportFile\nDocuments/backups/*.json"]
  Drift --> Copy["copyDatabaseFile\n*.sqlite (Android)"]
  Export --> Share["Share / Download"]
  Share --> Restore["restoreFromJson\ninsertOnConflictUpdate\nidempotent"]
  Restore --> Drift
```

---

## 11. Routing Shell

```mermaid
flowchart TB
  Router["GoRouter\nRoutePaths + routeRedirect\n_stateful shell (4 branches)"] --> Login["/login"]
  Router --> Shell["StatefulShellRoute"]
  Shell --> Dash["/dashboard (Jobs)"]
  Shell --> Search["/search"]
  Shell --> New["/new-job"]
  Shell --> Import["/old-bills"]
  Router --> Job["/job/:id (top-level)"]
  Router --> Admin["/admin — BackupScreen (owner-only)"]
```
