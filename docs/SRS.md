# Software Requirements Specification (SRS) — Garage Brain / Workshop OS

**Version:** 1.0.0 · **Date:** 2026-08-22 · **Authors:** Workshop OS team  
**Status:** Implemented (MVP) — derives from `DESIGN.md` v0.2  
**Platforms:** Android (primary, receptionist) + Web (owner). iOS deferred.  
**Reference:** IEEE 830-style; maps to `AGENTS.md` tasks T1–T16 and `DESIGN.md §1–12`.

---

## 1. Introduction

### 1.1 Purpose
Define requirements for an **offline-first workshop operating system** that lets a single receptionist (one Android device) find any vehicle's service history in <3 s and create a job card in <60 s, even when internet drops. Owner checks in via Web. No billing, photo, or inventory features in MVP.

### 1.2 Scope (what the system **is**)
- Unified plate+phone search → timeline of jobs + imported old bills.
- Single-flow job creation: vehicle + customer + complaints (+ optional KM).
- 4-state status lifecycle with manual close; WhatsApp deep-link at Ready.
- Drift(SQLite)-first with Supabase sync (last-write-wins), RLS by role.
- Old-bill import (<500 records, manual), backups, make dropdown + demo seed.

### 1.3 Definitions

| Term | Meaning |
|---|---|
| Job card | Single service visit: 1 vehicle + 1 customer + complaints + status |
| Phone = identity | Same bare 10-digit phone = same `customers` row (normalized via `phone.dart:4`) |
| Plate normalization | Uppercase + strip spaces/hyphens (`plate.dart:6`); stored `^[A-Z0-9]{6,11}$` |
| Plate flag | green = classic `^[A-Z]{2}[0-9]{2}[A-Z]{1,3}[0-9]{1,4}$`, amber = 6–11 alnum non-classic, red = invalid (`plate.dart:9`) |
| `synced` | Drift-only boolean; `false` = in local queue |
| Old bill | Imported paper-book record with original `bill_no` (unique) |

### 1.4 References
- `DESIGN.md` (product truth), `AGENTS.md` (tasks/conventions), `supabase/migrations/0001_init.sql`, `0002_rls.sql`, `app/lib/core/utils/*`, `app/lib/data/drift/tables.dart:1`, `app/lib/routing/app_router.dart:1`.

---

## 2. Overall Description

### 2.1 Product perspective
Local-first Flutter app (Riverpod + Drift + `drift_flutter`) talks to Supabase Postgres/Auth/RLS. All writes hit Drift with `synced=false` (`data/drift/tables.dart:5`); sync worker pulls/pushes on connect + timer. `wa.me` deep-link costs nothing.

### 2.2 User classes

| User | Device | Role claim (`app_role`) | Access |
|---|---|---|---|
| Receptionist | 1 Android phone/tablet | `receptionist` | Dashboard, search, create, status/notes, import |
| Owner | Any Web browser | `owner` | All above + `/admin` (BackupService), `recommendation_queue` |
| Anonymous | — | `anon` | Nothing (RLS blocks) |

No signup screen. Owner creates users in Supabase dashboard; `profiles` row carries role (see `supabase/migrations/0002_rls.sql`).

### 2.3 Operating environment
- Android 8+ (SQLite + `path_provider` + `sqlite3_flutter_libs`), modern Chrome for Web (Wasm SQLite via `drift_flutter`).
- Connectivity: mostly online with occasional drops — sync every 30 s + on reconnect (`data/supabase/sync_worker.dart:18`).
- Free tiers only.

### 2.4 Constraints
- No amounts/money, no photo uploads, no inventory (locked in `DESIGN.md §12`).
- Offline resilience = zero data loss; reads never block on network.
- Single writer → LWW on `updated_at` is acceptable.

---

## 3. Functional Requirements

### 3.1 FR-01 — Authentication (S1) — `T8` ✓ shipped
- **FR-01.1** Email+password login screen; session persisted.
- **FR-01.2** `go_router` redirect by `app_role` (`routing/app_router.dart:27`): anon→`/login`, logged-in on `/login`→`/dashboard`, `/admin` owner-only.
- **FR-01.3** Role comes from Custom Access Token hook `auth.custom_access_token_hook(jsonb)` (created in `0002_rls.sql`).
- **Acceptance:** widget tests `test/features/auth/*`, redirect unit test `test/routing/app_router_test.dart`.

### 3.2 FR-02 — Dashboard (S2) — `T11` ✓ shipped
- **FR-02.1** Today's jobs list with status chips, pull-to-refresh, offline badge.
- **FR-02.2** Counters: pending vehicles, completed today (no revenue widgets ever).
- **FR-02.3** Manual **Close** on `Delivered` rows → sets `closed=true` (`tables.dart:79`), removes from active lists.
- **Acceptance:** `test/features/dashboard/dashboard_test.dart`.

### 3.3 FR-03 — Unified Search (S3) — `T9` ✓ shipped
- **FR-03.1** Single box matches plate fragments **and** phone digits simultaneously, debounced, reads Drift only (<3 s).
- **FR-03.2** Live flag: green/amber/red via `classifyPlate` (`plate.dart:9`); amber shows "check plate" but does not block.
- **FR-03.3** Found → timeline merging `job_cards` + `old_bills` by plate/phone, tap→detail. Not found → CTA → Create Job.
- **Acceptance:** `test/features/search/search_test.dart`, `test/core/utils/plate_test.dart`.

### 3.4 FR-04 — Create Job (S4) — `T10` ✓ shipped
- **FR-04.1** Vehicle section: normalized plate with live flag, 2W/4W toggle, **make dropdown from `assets/makes.csv`** (29 makes), model free text, fuel type enum.
- **FR-04.2** Customer section: name + normalized phone (`phone.dart:4`); same phone pre-fills name and `CustomerRepository` upserts (phone-is-identity).
- **FR-04.3** Complaints free text (required), KM optional (`km_reading >= 0`).
- **FR-04.4** Save → `CreateJobService` creates/fetches customer + upserts vehicle + ownership history + inserts `job_cards` with client UUID, placeholder `job_no`, `synced=false`; instant snackbar.
- **Acceptance:** `test/features/create_job/create_job_test.dart`, `test/repositories/*`.

### 3.5 FR-05 — Job Detail + WhatsApp (S5) — `T12` ✓ shipped
- **FR-05.1** Status stepper `Arrived → InProgress → ReadyForDelivery → Delivered` — illegal jumps rejected by `JobRepository` (`data/repositories/job_repository.dart`).
- **FR-05.2** Notes edit, vehicle/customer history timeline.
- **FR-05.3** At `ReadyForDelivery`, button opens `wa.me/<phone>?text=…` with prefilled message (vehicle + `JOB-xxxxxx` via `core/utils/job_number.dart` + ready text) using `url_launcher` (`features/job_detail/whatsapp.dart`).
- **Acceptance:** `test/features/job_detail/job_detail_test.dart`, deep-link URL test.

### 3.6 FR-06 — Old Bills Import — `T13` ✓ shipped
- **FR-06.1** Fields: `bill_no` (unique, dup rejected inline), `bill_date`, plate, `vehicle_category` 2W/4W, customer name/phone, notes (`tables.dart:93`). No amounts.
- **FR-06.2** `OldBillsRepository` guards `bill_no` uniqueness; bulk UX: save-and-next keeps plate/customer warm.
- **Acceptance:** `test/features/old_bills/old_bills_test.dart`, `test/repositories/old_bills_repository_test.dart`.

### 3.7 FR-07 — Offline Sync — `T7` ✓ shipped
- **FR-07.1** Every mutation writes Drift with `synced=false`, `syncedAt=null` (SyncColumns mixin `tables.dart:5`).
- **FR-07.2** `SyncWorker` (`data/supabase/sync_worker.dart:18`): push unsynced rows via `RemoteGateway.upsert` (PK = client UUID), pull `fetchSince` with per-table `created_at`/`updated_at` cursor, mark `synced=true`. Triggers: app start, `connectivity_plus` reconnect, 30 s timer. Reentrant guard `_syncing`.
- **FR-07.3** FK-safe order: pull customers→vehicles→ownership→jobs→old_bills→recommendations; push same order (`sync_worker.dart:60`).
- **FR-07.4** Conflict: LWW on `updated_at` for `job_cards` (`_localWins`), locally-dirty rows win until pushed for other tables.
- **Acceptance:** `test/data/supabase/sync_worker_test.dart`.

### 3.8 FR-08 — Backups — `T14` ✓ shipped
- **FR-08.1** `BackupService` (`data/backup/backup_service.dart:11`): `buildExportJson` / `exportJsonString` (versioned JSON of 6 tables), `writeExportFile` to `Documents/backups/*.json`, `copyDatabaseFile` raw SQLite copy (Android only), `restoreFromJson` idempotent upsert.
- **FR-08.2** `BackupScheduler` (`backup_scheduler.dart`): 24 h file copy, 7 d JSON export timers; owner UI at `/admin` (`features/backup/backup_screen.dart`) route-guarded to `owner`.
- **FR-08.3** Web degrades: file copy returns null, export shows dialog for copy.
- **Acceptance:** `test/data/backup/backup_service_test.dart`.

### 3.9 FR-09 — Seed Data — `T15` ✓ shipped
- **FR-09.1** `assets/makes.csv` (29 makes) declared in `pubspec.yaml:76`.
- **FR-09.2** `DemoSeed.seed(db)` (`data/seed/demo_seed.dart`) — 6 customers/vehicles/job_cards(old→new states)/2 old_bills/6 ownership rows, FK-safe order, `insertOnConflictUpdate` with fixed UUIDs → idempotent. Cold-start auto-seed when `AppConfig.isSupabaseConfigured==false` (`main.dart:28`).
- **Acceptance:** `test/data/seed/demo_seed_test.dart`.

### 3.10 FR-10 — Data Model & Validation
- **FR-10.1** SQL truth in `0001_init.sql`: `customers`(`phone` unique `^[6-9][0-9]{9}$`), `vehicles`(plate `^[A-Z0-9]{6,11}$`, 2W/4W, fuel enum), `car_ownership_history` (FK cascade, `chk_ownership_dates`), `job_status` enum, `job_no_seq` + `job_cards` (FKs, `km>=0`, `closed`, `touch_updated_at()` trigger), `old_bills`(`bill_no` unique), `recommendation_queue` (Phase 2 stub).
- **FR-10.2** Indexes: `idx_job_cards_vehicle_time`, `idx_customers_phone`, `idx_ownership_vehicle`, `idx_old_bills_phone`.
- **FR-10.3** App normalizers: `normalizePhone` (`phone.dart:4`) strips spaces/dashes/+/leading 91; `normalizePlate` (`plate.dart:6`).

---

## 4. Non-Functional Requirements

| ID | Requirement | Target / Verification |
|---|---|---|
| NFR-01 | Search latency | <3 s locally (Drift, no network) — widget test timing |
| NFR-02 | Job creation | <60 s end-to-end in UI (no quick-pick chips in MVP) |
| NFR-03 | Offline resilience | Zero loss; every write survives drop; sync on reconnect |
| NFR-04 | Sync aggressiveness | Push within ≤30 s when online; reentrant-safe |
| NFR-05 | Security | Public anon key only; RLS enforces all access; JWT `app_role` |
| NFR-06 | Platforms | Android + Web from one Flutter codebase; Web uses Wasm SQLite |
| NFR-07 | Data cost | Free tiers + `wa.me` deep-link (no SMS vendor) |
| NFR-08 | Maintainability | `flutter analyze` clean, `flutter test` green per commit (AGENTS.md gates) |
| NFR-09 | Backups | Daily SQLite copy + weekly JSON export; restore idempotent |

---

## 5. Use-Case Summaries

### UC-01 Receptionist creates job for new vehicle
**Pre:** Logged in as receptionist, online or offline. **Flow:** Search plate → not found → CTA → Create Job → fill vehicle (plate auto-normalized, green/amber flag) → pick make → model → fuel → customer name+phone → complaints → optional KM → Save → snackbar; row has `synced=false`. **Post:** SyncWorker pushes when online; job appears on Dashboard/Timeline.

### UC-02 Receptionist finds history
**Pre:** Any vehicle/customer exists. **Flow:** Search box type plate fragment or phone digits → debounced Drift queries → flagged plate → timeline (jobs + old bills) → tap → detail.

### UC-03 Advance status + notify
**Flow:** Open Job Detail → stepper → move to `ReadyForDelivery` → WhatsApp button appears → tap → `wa.me` prefilled → receptionist sends from own WhatsApp → later `Delivered` → Dashboard manual Close.

### UC-04 Import old paper bills
**Flow:** Import tab → fill bill_no/bill_date/plate/category/name/phone/notes → Save validates unique bill_no → bulk save-and-next retains plate/customer.

### UC-05 Owner export/restore
**Flow:** Owner → `/admin` → Export JSON / Copy DB file → share; later restore via `BackupService.restoreFromJson` (idempotent).

---

## 6. Acceptance Criteria (MVP gate)
- `supabase db reset` applies both migrations cleanly; RLS matrices pass as receptionist/owner/anon.
- `flutter analyze` no warnings; `flutter test` all green (core, repositories, drift, sync_worker, features, routing, backup, seed).
- Offline create → queue → online flush marks `synced=true`; LWW conflict on `updated_at` respected.
- No money fields anywhere; plate/phone normalizers cover edge cases (`O/0`, `+91`, BH series).

---

## 7. Pending / Out-of-Scope
See [Feature Matrix](FEATURE_MATRIX.md) and `DESIGN.md §3 (Phase 2)` — intentionally not in this SRS scope: billing/GST, photo uploads, inventory, quick-pick chips, voice, `/track/{job_id}`, analytics, recommendation cron (tables exist, no cron yet), in-app user tab.

---

## 8. Traceability (FR → Task → Test)

| FR | Task | Code | Tests |
|---|---|---|---|
| FR-01 | T8 | `features/auth/*`, `routing/app_router.dart:27` | `test/features/auth/*`, `test/routing/*` |
| FR-02 | T11 | `features/dashboard/*`, `repositories/job_repository.dart` | `test/features/dashboard/*` |
| FR-03 | T9 | `features/search/*`, `core/utils/plate.dart:8` | `test/features/search/*`, `test/core/utils/plate_test.dart` |
| FR-04 | T10 | `features/create_job/*`, `data/seed/makes.csv` | `test/features/create_job/*` |
| FR-05 | T12 | `features/job_detail/*` | `test/features/job_detail/*` |
| FR-06 | T13 | `features/old_bills/*` | `test/features/old_bills/*` |
| FR-07 | T7 | `data/supabase/sync_worker.dart:18` | `test/data/supabase/sync_worker_test.dart` |
| FR-08 | T14 | `data/backup/*`, `features/backup/*` | `test/data/backup/*` |
| FR-09 | T15 | `data/seed/*`, `assets/makes.csv` | `test/data/seed/*` |
| FR-10 | T1,T5 | `supabase/migrations/0001_init.sql`, `data/drift/tables.dart:1` | `test/data/drift/*` |
