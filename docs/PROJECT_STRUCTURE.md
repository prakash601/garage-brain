# Project Structure — Garage Brain / Workshop OS

**Version:** 1.1.0 · **Date:** 2026-09-03  
**Root:** `garage-brain/` — see `AGENTS.md §Planned Repo Layout` for task ownership.

---

## 1. Directory Tree (authoritative)

```
garage-brain/
├── AGENTS.md                 # Task board T1–T16, conventions, execution rules ← update on every task
├── DESIGN.md                 # Product truth v0.2 + locked decisions §12
├── README.md                 # Root summary + quick start → links to docs/
├── supabase/
│   ├── config.toml           # Supabase CLI config (non-secret)
│   └── migrations/
│       ├── 0001_init.sql     # T1: customers, vehicles, ownership, job_status, seq, job_cards, old_bills, recommendation_queue, indexes, touch_updated_at
│       └── 0002_rls.sql      # T2: profiles, app_role(), custom_access_token_hook, RLS policies
├── docs/                     # ← THIS FOLDER — full SRS/HLD/LLD set
│   ├── README.md             # Index + cross-links + conventions
│   ├── SRS.md                # IEEE 830-style requirements, FR-01..10, use cases
│   ├── HLD.md                # C4 context/container, flows, sync, security, deployment
│   ├── LLD.md                # Module/class/table/API/transition/test detail
│   ├── TECH_STACK.md         # Stack choices + versions + justification
│   ├── PROJECT_STRUCTURE.md  # ← YOU ARE HERE (update on every new file/dir)
│   ├── FEATURE_MATRIX.md     # Shipped vs pending vs out-of-scope (single truth)
│   ├── DIAGRAMS.md           # All Mermaid sources in one place (ER/sequence/state/etc.)
│   ├── DECISIONS.md          # Locked decisions mirrored from DESIGN.md §12
│   └── DOCS_UI_PLAN.md       # Docs site options + recommended pick + scaffold
├── docs-site/                # Static docs UI (VitePress-style) serving docs/ → GitHub Pages
│   ├── index.html            # VitePress-inspired SPA shell (also usable as Docsify fallback)
│   ├── package.json          # Docs toolchain (optional; docs render without build)
│   ├── vite.config.js        # If Vite is chosen (see DOCS_UI_PLAN.md)
│   └── public/               # Built assets
├── app/                      # Flutter app root (all Dart)
│   ├── pubspec.yaml          # Deps: riverpod, drift, go_router, supabase_flutter, uuid, connectivity_plus, file_picker, share_plus ...
│   ├── analysis_options.yaml # flutter_lints 6.0 gate
│   ├── assets/
│   │   └── makes.csv         # T15: 29 makes (Hero..Audi) → makes_provider.dart
│   ├── lib/
│   │   ├── main.dart         # Supabase init or _seedDemoDataIfEmpty → WorkshopOsApp
│   │   │                       # (auto-starts BackupScheduler + SyncWorker, Phase 1)
│   │   ├── core/
│   │   │   ├── config/
│   │   │   │   └── app_config.dart        # --dart-define reader + isSupabaseConfigured
│   │   │   ├── theme/
│   │   │   │   ├── app_theme.dart         # light/dark ThemeData (+ shared input/card/list themes, Phase 4)
│   │   │   │   └── status_colors.dart     # Phase 4: plate-flag + job-chip colors (dark-mode safe)
│   │   │   ├── widgets/                 # Phase 1+4 shared widgets (≥2 features)
│   │   │   │   ├── sync_banner.dart       # Phase 1: global offline/pending/retry banner
│   │   │   │   ├── content_frame.dart     # Phase 4: 720px web content cap
│   │   │   │   └── empty_state.dart       # Phase 4: shared empty-state (icon/title/action)
│   │   │   └── utils/
│   │   │       ├── phone.dart             # T4: normalizePhone + isValidPhone (phone.dart:4)
│   │   │       │                           # (+ trunk-0/bracket hardening, Phase 3)
│   │   │       ├── plate.dart             # T4: normalizePlate + classifyPlate (plate.dart:6)
│   │   │       ├── job_number.dart        # T4: formatJobNo JOB-%06d
│   │   │       └── validators.dart        # Phase 3: isValidCustomerName + tryParseKm
│   │   ├── data/
│   │   │   ├── drift/
│   │   │   │   ├── tables.dart            # T5: SyncColumns mixin + 6 tables (tables.dart:1)
│   │   │   │   ├── enums.dart             # T5: VehicleType/FuelType/JobStatus converters
│   │   │   │   ├── app_database.dart      # T5: @DriftDatabase + driftDatabase Wasm open (app_database.dart:34)
│   │   │   │   ├── app_database.g.dart    # Generated — never hand-edit
│   │   │   │   └── database_provider.dart # Riverpod provider for AppDatabase
│   │   │   ├── repositories/
│   │   │   │   ├── customer_repository.dart   # T6: phone-is-identity
│   │   │   │   ├── vehicle_repository.dart    # T6: plate PK upsert
│   │   │   │   ├── job_repository.dart        # T6: create + guarded transitions + close
│   │   │   │   ├── old_bills_repository.dart  # T6: bill_no unique
│   │   │   │   └── ownership_repository.dart  # T6: close-old/open-new
│   │   │   ├── supabase/
│   │   │   │   ├── remote_gateway.dart            # T7: fetchSince + upsert contract
│   │   │   │   ├── supabase_remote_gateway.dart   # T7: Supabase impl
│   │   │   │   ├── sync_mappers.dart              # T7: Row ↔ Companion mappers
│   │   │   │   ├── sync_worker.dart               # T7: pull→push, cursors, _localWins (sync_worker.dart:18)
│   │   │   │   │                                   # (+ per-table fault isolation, Phase 1)
│   │   │   │   └── sync_providers.dart            # Phase 1: gateway/worker/status/pending-count providers
│   │   │   ├── backup/
│   │   │   │   ├── backup_service.dart        # T14: export/copy/restoreFromJson (backup_service.dart:11)
│   │   │   │   ├── backup_scheduler.dart      # T14: 24h/7d timers
│   │   │   │   └── backup_providers.dart      # T14: Riverpod wiring
│   │   │   └── seed/
│   │   │       └── demo_seed.dart             # T15: 6+6+6+2+6 idempotent rows
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── auth_gateway.dart      # Abstract AuthGateway
│   │   │   │   ├── auth_providers.dart    # Riverpod
│   │   │   │   └── login_screen.dart      # T8: email+password
│   │   │   ├── dashboard/
│   │   │   │   ├── dashboard_screen.dart  # T11: today list + chips + Close
│   │   │   │   └── dashboard_providers.dart
│   │   │   ├── search/
│   │   │   │   ├── search_screen.dart     # T9: unified box + flag + CTA
│   │   │   │   ├── search_service.dart    # T9: Drift queries + merge
│   │   │   │   └── search_providers.dart  # T9: debounced
│   │   │   ├── create_job/
│   │   │   │   ├── create_job_screen.dart # T10: vehicle+customer+complaints form
│   │   │   │   ├── create_job_service.dart# T10: cross-repo orchestration
│   │   │   │   └── makes_provider.dart    # T15: loads makes.csv
│   │   │   ├── job_detail/
│   │   │   │   ├── job_detail_screen.dart    # T12: stepper + timeline + WA button
│   │   │   │   ├── job_detail_providers.dart
│   │   │   │   └── whatsapp.dart             # T12: wa.me builder
│   │   │   ├── old_bills/
│   │   │   │   └── old_bills_screen.dart  # T13: import form + save-and-next
│   │   │   └── backup/
│   │   │       └── backup_screen.dart     # T14: owner /admin (Export + Copy)
│   │   └── routing/
│   │       └── app_router.dart            # T8: RoutePaths + routeRedirect + GoRouter (routing/app_router.dart:1)
│   ├── test/
│   │   ├── core/utils/{phone,plate,job_number,validators}_test.dart
│   │   ├── core/widgets/phase4_test.dart   # Phase 4: EmptyState/ContentFrame/status colors
│   │   ├── data/
│   │   │   ├── drift/app_database_test.dart
│   │   │   ├── backup/backup_service_test.dart
│   │   │   ├── seed/demo_seed_test.dart
│   │   │   └── supabase/{sync_worker,sync_status}_test.dart
│   │   │       # sync_status: Phase 1 fault-isolation (lastError/lastSyncAt)
│   │   ├── repositories/{customer,vehicle,job,old_bills,ownership}_test.dart + helpers.dart
│   │   ├── features/{auth,search,create_job,dashboard,job_detail,old_bills}/* + routing/app_router_test.dart
│   │   ├── helpers/fake_auth_gateway.dart
│   │   └── widget_test.dart
│   ├── tool/
│   │   └── seed_demo.dart                 # T15: runnable demo seed (flutter test tool/seed_demo.dart)
│   ├── README.md                          # Full setup + Supabase + backups + seed + troubleshooting
│   └── web/ + android/ + .metadata …
└── .gitignore (+ app/.gitignore)
```

**Generated-only:** `app/lib/data/drift/app_database.g.dart` — regenerate with `dart run build_runner build --delete-conflicting-outputs` after editing `tables.dart`/`app_database.dart`.

---

## 2. Ownership by Task (AGENTS.md mapping)

| Task | Owns | Status |
|---|---|---|
| T1 | `supabase/migrations/0001_init.sql` | ✓ shipped (exists) |
| T2 | `supabase/migrations/0002_rls.sql` | ✓ shipped (exists) |
| T3 | `app/` scaffold, `pubspec.yaml`, `main.dart`, `routing/`, `core/theme/` | ✓ shipped |
| T4 | `app/lib/core/utils/*` + `test/core/*` | ✓ shipped |
| T5 | `app/lib/data/drift/*` | ✓ shipped |
| T6 | `app/lib/data/repositories/*` + `test/repositories/*` | ✓ shipped |
| T7 | `app/lib/data/supabase/*` (+ `test/data/supabase/*`) | ✓ shipped |
| T8 | `app/lib/features/auth/*`, `app/lib/routing/*` | ✓ shipped |
| T9 | `app/lib/features/search/*` | ✓ shipped |
| T10 | `app/lib/features/create_job/*` | ✓ shipped |
| T11 | `app/lib/features/dashboard/*` | ✓ shipped |
| T12 | `app/lib/features/job_detail/*` | ✓ shipped |
| T13 | `app/lib/features/old_bills/*` | ✓ shipped |
| T14 | `app/lib/data/backup/*`, `app/lib/features/backup/*` | ✓ shipped |
| T15 | `app/assets/makes.csv`, `app/lib/data/seed/*`, `app/tool/seed_demo.dart` | ✓ shipped |
| T16 | `README.md`, `app/README.md` + now `docs/*` | ✓ this deliverable |

---

## 3. Where to add new code

| New feature | Put it here | Also update |
|---|---|---|
| New table/column | `supabase/migrations/000N_*.sql` (append-only!) + `app/lib/data/drift/tables.dart:1` + `enums.dart` + regenerate `.g.dart` | `docs/SRS.md §3.10`, `docs/DIAGRAMS.md` ER, `test/data/drift/*` |
| New repository method | `app/lib/data/repositories/<aggregate>_repository.dart` | `test/repositories/*` |
| New screen | `app/lib/features/<name>/` (screen + providers + service if cross-repo) | `app/lib/routing/app_router.dart:15` + `test/features/<name>/*` |
| New util/validator | `app/lib/core/utils/<name>.dart` | `test/core/utils/*` |
| New docs page | `docs/<PAGE>.md` + link from `docs/README.md` | `docs-site` nav (if not auto) + root `README.md` |
| Docs site change | `docs-site/` | `docs/DOCS_UI_PLAN.md` |

---

## 4. Conventions that guard this tree

- **No shared `widgets/`** dumping ground — ≥2-feature shared widget gets `app/lib/core/widgets/` (now: `sync_banner`, `content_frame`, `empty_state`).
- **Repository is the only writer** to Drift (`AGENTS.md §Conventions`); screens call repos/providers only.
- **Migrations are append-only** `0001`, `0002`, … never edit merged SQL.
- **Commits:** imperative, scoped (`feat(search): …`, `docs: …`, `db: …`).
- **Secrets:** only anon key via `--dart-define`; never commit `.env` / service key.
- **Documentation sync (NEW — AGENTS.md rule):** creating or renaming any file or directory **must** update `docs/PROJECT_STRUCTURE.md` + directory listings in `README.md` and `app/README.md` + nav in `docs/README.md` and `docs-site` if present. CI can enforce via `git diff --name-only` check. See `AGENTS.md §Conventions → Documentation sync`.

---

## 5. Verification

```bash
flutter analyze   # no warnings
flutter test      # core + drift + repos + sync_worker + features + routing + backup + seed
dart run build_runner build --delete-conflicting-outputs   # after drift edits
supabase db reset # reapplies 0001 then 0002 locally (or Dashboard SQL Editor)
```
