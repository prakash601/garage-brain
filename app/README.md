# Workshop OS — Garage Brain

Offline-first Flutter app for a vehicle workshop (2W + 4W). One receptionist on one Android device; owner checks in remotely via Web. Local-first reads/writes via Drift (SQLite); Supabase is the durable backend. WhatsApp deep-link notifications. See `../DESIGN.md` for product decisions and `../AGENTS.md` for implementation plan.

**Status:** Phase D hardening (T14–T16) completed. `flutter analyze` + `flutter test` are the gates.

**Docs:** [`../docs/README.md`](../docs/README.md) (index) · [`../docs/FEATURE_MATRIX.md`](../docs/FEATURE_MATRIX.md) (shipped vs pending) · [`../docs/SRS.md`](../docs/SRS.md) · [`../docs/HLD.md`](../docs/HLD.md) · [`../docs/LLD.md`](../docs/LLD.md) · [`../docs/DOCS_UI_PLAN.md`](../docs/DOCS_UI_PLAN.md) (browsable docs UI) · `../docs-site/` (live site: Docsify zero-build + VitePress build)

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter | 3.13+ (Dart 3.13) | `flutter --version` to verify |
| Supabase CLI | latest | `npm i -g supabase` or Homebrew; for `supabase db push/reset` |
| Supabase project | — | Create at [supabase.com/dashboard](https://supabase.com/dashboard) |
| Android toolchain | for APK build | `flutter doctor` must show Android SDK |
| Chrome | for Web build | Any modern Chrome for `flutter run -d chrome` |

---

## Repo layout

```
../docs/                # Full SRS/HLD/LLD set (authoritative) — see ../docs/README.md + ../docs/PROJECT_STRUCTURE.md
../docs-site/           # Browsable docs UI (Docsify zero-build + VitePress build) — see ../docs/DOCS_UI_PLAN.md
supabase/
  migrations/          # 0001_init.sql, 0002_rls.sql (append-only)
app/                   # Flutter app root (this folder)
  lib/
    main.dart
    core/              # phone/plate normalizers, validators, theme, app_config
                       # + core/widgets (sync_banner, content_frame, empty_state)
    data/
      drift/           # Drift tables mirroring Supabase + synced flag
      supabase/        # sync_worker.dart, remote_gateway.dart, sync_providers.dart
      repositories/    # customer/vehicle/job/old_bills/ownership
      backup/          # T14: BackupService + BackupScheduler
      seed/            # T15: DemoSeed
    features/
      auth/ dashboard/ search/ create_job/ job_detail/ old_bills/
      backup/          # T14: Admin → Backups screen (owner-only)
    routing/           # go_router + role-based redirect
  assets/makes.csv     # T15: seeded make list for dropdown
  tool/seed_demo.dart  # T15: idempotent demo dataset runner
  test/                # unit + widget tests mirroring lib/
```

Authoritative tree: `../docs/PROJECT_STRUCTURE.md`. When this listing and that file diverge, the docs tree wins. `AGENTS.md → Documentation sync` requires any new file/dir to update `../docs/PROJECT_STRUCTURE.md` + directory listings here and in `../README.md` + `../docs-site` nav + `../docs/FEATURE_MATRIX.md` if the feature set changed.

---

## Quick start (fresh machine)

```bash
git clone <repo>
cd garage-brain/app

# 1. Dependencies
flutter pub get

# 2. Drift codegen (after editing tables.dart / app_database.dart)
dart run build_runner build --delete-conflicting-outputs

# 3. Static analysis + tests (must pass before any commit)
flutter analyze
flutter test

# 4. Run
flutter run -d chrome                                    # web
flutter run -d <device-id>                               # android — `flutter devices` to list
```

No `.env` file is committed. Secrets travel as `--dart-define`.

---

## Supabase project setup

### 1. Create the project

1. Create a new organization + project at [Supabase Dashboard](https://supabase.com/dashboard).
2. Save the **Project URL** (`https://<ref>.supabase.co`) and the **anon (publishable) key** from **Settings → API**.

### 2. Link and apply migrations

Using the **Supabase CLI** (recommended; works for local rebuilds too):

```bash
# from repo root — one-time link
supabase link --project-ref <ref>

# apply ordered migrations (0001_init.sql then 0002_rls.sql)
supabase db push

# local rebuild from scratch (optional smoke test)
supabase db reset   # drops local DB, reapplies migrations, re-seeds if configured
```

**Without the CLI:** open **SQL Editor** in the Supabase Dashboard and run the contents of `supabase/migrations/0001_init.sql` then `0002_rls.sql` in order.

What the migrations create (see `DESIGN.md §5` for full SQL):

- `customers` (phone unique, `^[6-9][0-9]{9}$`), `vehicles` (plate `^[A-Z0-9]{6,11}$`, 2W/4W), `car_ownership_history`, `job_status` enum (4 states), `job_no_seq`, `job_cards` (+ `closed` bool, `touch_updated_at()` trigger), `old_bills` (original `bill_no` unique), `recommendation_queue`
- Indexes for the <3 s local search goal: `idx_job_cards_vehicle_time`, `idx_customers_phone`, `idx_ownership_vehicle`, `idx_old_bills_phone`
- `profiles` + `app_role()` helper + `auth.custom_access_token_hook` + RLS policies (`staff_read/insert/update` everywhere for receptionist+owner; `recommendation_queue` owner-only)

### 3. Auth hook (custom access token)

1. Dashboard → **Auth → Hooks** → enable **Custom Access Token**.
2. The hook function `auth.custom_access_token_hook(jsonb)` is already created by `0002_rls.sql` — it reads `profiles.role` and injects `app_role` into the JWT.
3. Grant is already in the migration: `grant execute on function auth.custom_access_token_hook(jsonb) to supabase_auth_admin;`

### 4. Create users

No signup screen exists (DESIGN.md §6 S1). Owner creates accounts in **Auth → Users** (invite or manual email+password), then inserts the role:

```sql
-- run as service_role or via SQL Editor as a privileged user
insert into profiles (id, role) values ('<auth.users.id>', 'owner');
-- or
insert into profiles (id, role) values ('<auth.users.id>', 'receptionist');
```

Receptionist and owner both get dashboard/search/create-job/update-status. Only `owner` can open `/admin` (→ Backups) and sees `recommendation_queue`.

### 5. Wire the keys into the app

Both keys are **anon/public** only; the service key never ships with the app (see `AGENTS.md` Secrets).

```bash
# Chrome (web)
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>

# Android
flutter run -d <device-id> \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>

# Release build examples
flutter build apk \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>

flutter build web \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

If `--dart-define` is omitted, the app still launches but `AppConfig.isSupabaseConfigured` is false and it runs fully offline against Drift (useful for local dev without a project).

---

## Running tests & lints

```bash
cd app
flutter analyze          # no warnings
flutter test             # all suites: core, repositories, drift, sync_worker, features, routing, backup, seed

# Regenerate Drift code after editing Drift tables
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch   # alternative: watch mode
```

---

## Backups & Data Safety (T14)

Design: `DESIGN.md §10`. Implementation: `lib/data/backup/`.

### What exists

- **BackupService** (`lib/data/backup/backup_service.dart`):
  - `buildExportJson()` — reads all 6 Drift tables (`customers`, `vehicles`, `car_ownership_history`, `job_cards`, `old_bills`, `recommendation_queue`) and returns a versioned map with `exported_at`.
  - `exportJsonString()` — pretty-printed JSON of the above.
  - `writeExportFile({directoryPath, fileName})` — writes the JSON to `<documents>/backups/workshop_os_export_<timestamp>.json` (or a supplied directory in tests). On Web it throws `UnsupportedError` — caller shows the string in a dialog for manual copy.
  - `copyDatabaseFile({directoryPath})` — finds the Drift SQLite file (`workshop_os.sqlite` in support/docs/tmp) and copies it to `<documents>/backups/workshop_os_backup_<timestamp>.sqlite`. Returns `null` on Web or if the DB is in-memory (tests).
  - `restoreFromJson(Map<String,dynamic>)` — idempotent `insertOnConflictUpdate` per table; safe to call repeatedly with the same file.

- **BackupScheduler** (`lib/data/backup/backup_scheduler.dart`):
  - Periodic timers: file copy every 24 h, JSON export every 7 days. Start with `await BackupScheduler(service).start()` (e.g., from a startup provider); stop with `stop()`. Errors are swallowed so a failed backup never crashes sync.

- **Owner UI** (`lib/features/backup/backup_screen.dart`, routed at `/admin`):
  - Owner-only per `routeRedirect` (receptionist is bounced to `/dashboard`).
  - Buttons: **Export JSON (all tables)** (+ **Share export** once written), **Copy database file (local backup)**, and **Restore from JSON…** (file picker with confirm dialog, then `restoreFromJson`). All show a `SnackBar` with the result. Web degrades export to a selectable dialog; restore works via picker on all platforms.

### Verify export contains all tables

```bash
flutter test test/data/backup/backup_service_test.dart --reporter expanded
```

The test builds an in-memory DB, seeds a customer/vehicle/job/old_bill, calls `buildExportJson`, and asserts each top-level table key is present and non-empty. `restoreFromJson` is exercised by round-tripping an export into a fresh in-memory DB and re-asserting row counts.

### Restore path

**From JSON export (recommended; cross-platform):**

1. Locate the latest export. On device it is at `Documents/backups/workshop_os_export_*.json`; share it to the owner via the system share sheet, email, or Files app. On Web, copy the dialog contents to a `.json` file.
2. To restore **into a fresh install** (or after `supabase db reset` side):
   - Install / reinstall the app.
   - Copy the export JSON back to the device (or paste it on Web).
   - In the app: Admin → **Restore from JSON…** → pick the file → confirm.
     (Or in code, call:)
     ```dart
     final jsonStr = await File(path).readAsString();
     await BackupService(db).restoreFromJson(jsonDecode(jsonStr));
     ```
   - `restoreFromJson` is idempotent — re-running the same file does not duplicate rows (upsert by PK).
3. **Sync after restore:** on next `SyncWorker.syncNow()` unsynced rows (if any) will be pushed to Supabase; pulled remote rows will be merged LWW on `updated_at`.

**From raw SQLite copy (Android only, advanced):**

1. The daily file copy lives at `Documents/backups/workshop_os_backup_*.sqlite`.
2. Replacing the active Drift file directly is OS-specific and not done at runtime by the app; treat it as an offline disaster-recovery copy and prefer the JSON export for restores.

### Scheduling

The weekly JSON export is modeled in `BackupScheduler(exportInterval: 7 days)`. If you need a manual weekly export regardless of timers, use the Admin → **Export JSON** button — the same file it writes is what the scheduler creates automatically.

---

## Seed: makes + demo dataset (T15)

- **Make list:** `assets/makes.csv` — 29 common makes covering 2W and 4W (Hero, Honda, Bajaj, TVS, Suzuki, Yamaha, Royal Enfield, KTM, Ather, Ola Electric, Maruti Suzuki, Hyundai, Tata, Mahindra, Toyota, Kia, Ford, Renault, Volkswagen, Skoda, Honda Cars, MG, Nissan, Datsun, Jeep, BMW, Mercedes-Benz, Audi). Loaded by `features/create_job/makes_provider.dart` → dropdown in Create Job (DESIGN.md §6 S4). `pubspec.yaml` already declares `assets/makes.csv`.

- **Demo dataset:** `lib/data/seed/demo_seed.dart` — `DemoSeed.seed(db)` inserts in FK-safe order:
  - 6 customers (Indian mobiles `9876543210`…), 6 vehicles (mix of classic plates `KA05MJ4821`/`MH12AB1234`/`DL10CA0007`, BH-series `21BH2345A`, etc., 2W/4W, Petrol/Diesel/Electric), 6 job cards cycling `Arrived→InProgress→ReadyForDelivery→Delivered`, 2 `old_bills` (paper-book records), 6 ownership rows. All IDs are fixed UUIDs and every insert uses `insertOnConflictUpdate`, so **re-running the seed is idempotent** (no duplicate `phone`, `number_plate`, or `bill_no` errors).

Run it:

```bash
# Instrumented test (no device needed) — verifies counts + idempotency
flutter test test/data/seed/demo_seed_test.dart --reporter expanded

# In-memory smoke test via Flutter (tool imports drift_flutter → needs Flutter engine)
flutter test tool/seed_demo.dart   # or run the same logic inside a debug build

# In an app (e.g., debug banner or dev-only button)
import 'package:workshop_os/data/seed/demo_seed.dart';
await DemoSeed.seed(ref.read(appDatabaseProvider));
```

`DemoSeed.seed` is idempotent (`insertOnConflictUpdate` on fixed UUIDs); re-running never duplicates `phone`, `number_plate`, or `bill_no`.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `AppConfig.isSupabaseConfigured` false | Pass both `--dart-define=SUPABASE_URL` and `SUPABASE_ANON_KEY` |
| `supabase db push` errors about existing objects | Run `supabase db reset` locally; verify migrations are applied in order |
| Auth succeeds but `app_role` missing / RLS denies | Check `profiles` row for the user and that the Custom Access Token hook is enabled |
| `flutter analyze` complains after editing Drift tables | Run `dart run build_runner build --delete-conflicting-outputs` |
| Backup copy returns `null` | Expected on Web / in-memory tests — use Export JSON instead |
| Seeding fails on second run with uniqueness error | Update pull — seed uses `insertOnConflictUpdate` and should be idempotent; file a bug with the failing table |

---

## Deploy / Run instructions

See **Supabase project setup** and **Quick start** above. For CI, ensure `flutter analyze` and `flutter test` run on every PR; no money/amount fields, no photo uploads, and no inventory code should ever be introduced (DESIGN.md §3 Out of scope).

## Browsable docs

```bash
# Docsify fallback — no Node needed
cd ../docs-site && python3 -m http.server 3000  # open http://localhost:3000

# VitePress — polished
cd ../docs-site && npm install && npm run docs:dev   # http://localhost:5173
```

See `../docs/DOCS_UI_PLAN.md` for VitePress vs Docusaurus vs MkDocs vs Starlight vs in-app `flutter_markdown` trade-offs and GitHub Pages / Vercel recipes. The canonical source for docs is `../docs/`; `../docs-site/` never duplicates Markdown.

## Documentation sync rule

`AGENTS.md §Conventions → Documentation sync`: any new file or directory must update `../docs/PROJECT_STRUCTURE.md`, directory listings in `../README.md` and this file, sidebar/nav in `../docs-site` if the page should appear, and `../docs/FEATURE_MATRIX.md` if the user-facing feature set changed. Use `git diff --name-only | grep -v PROJECT_STRUCTURE | grep -v README` as a pre-commit check.
