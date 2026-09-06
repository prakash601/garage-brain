# Feature Matrix — Shipped vs Pending — Garage Brain

**Version:** 1.2.0 · **Date:** 2026-09-06  
**Single source of truth** for "what exists / what is next". Mirrors `DESIGN.md §3`, `AGENTS.md T1–T16`.

---

## 1. MVP — Shipped (Phase A–D, T1–T16) ✓

Every row below has code + tests + docs. Quick probe file is listed so reviewers can verify without guessing.

| Feature (AGENTS/DD ref) | Code | Tests | Notes |
|---|---|---|---|
| **DB migrations** T1 — `customers`, `vehicles`, `car_ownership_history`, `job_status`, `job_no_seq`, `job_cards`(+`closed`), `old_bills`, `recommendation_queue`, indexes, `touch_updated_at()` | `supabase/migrations/0001_init.sql` | `supabase db reset` | Append-only |
| **Auth & RLS** T2 — `profiles`, `app_role()`, `auth.custom_access_token_hook`, RLS (`staff_read/insert/update`, owner-only queue) | `supabase/migrations/0002_rls.sql` | Policy matrix (receptionist/owner/anon) | Hook enabled in Dashboard → Auth → Hooks |
| **Flutter scaffold** T3 — Riverpod + Drift + go_router + Supabase + theme + AppConfig | `app/pubspec.yaml`, `app/lib/main.dart:11`, `app/lib/routing/app_router.dart:1` | `flutter analyze` | `AppConfig.isSupabaseConfigured` offline path |
| **Core utils** T4 — phone/plate normalizers + validators + `JOB-%06d` | `app/lib/core/utils/phone.dart:4`, `plate.dart:6`, `job_number.dart` | `test/core/utils/*` | BH-series amber, `+91` strip covered |
| **Drift mirror** T5 — 6 tables + `SyncColumns` (`synced`/`syncedAt`) + Wasm | `app/lib/data/drift/tables.dart:1`, `enums.dart`, `app_database.dart:34` | `test/data/drift/app_database_test.dart` | `.g.dart` is codegen |
| **Repositories** T6 — Customer (phone identity), Vehicle, Job (guarded transitions+close), OldBills (bill_no uniq), Ownership (close/open) | `app/lib/data/repositories/*` | `test/repositories/*` | All write `synced=false` |
| **Sync worker** T7 — pull-then-push, FK-safe order, cursors, LWW, 30s+connectivity | `app/lib/data/supabase/sync_worker.dart:18` + `remote_gateway.dart` | `test/data/supabase/sync_worker_test.dart` + `sync_e2e_test.dart` (two-device offline→online→Web proof) | Fake gateway in test; shared `fake_remote_gateway.dart` |
| **Auth UI** T8 / S1 — login screen + role redirect + session | `app/lib/features/auth/*`, `app/lib/routing/app_router.dart:27` | `test/features/auth/*`, `test/routing/app_router_test.dart` | No signup |
| **Search** T9 / S3 — unified plate+phone, green/amber/red flag, timeline + CTA | `app/lib/features/search/*` | `test/features/search/*` | Reads Drift only, debounced |
| **Create Job** T10 / S4 — vehicle(type/make/model/fuel) + customer(phone identity) + complaints/KM → instant Drift + snackbar | `app/lib/features/create_job/*` + `assets/makes.csv` | `test/features/create_job/*` | Offline queue proven |
| **Dashboard** T11 / S2 — today's jobs + chips + pending/completed + pull-refresh + offline badge + manual Close | `app/lib/features/dashboard/*` | `test/features/dashboard/*` | No revenue widgets |
| **Job Detail** T12 / S5 — stepper, notes, history timeline, `wa.me` at Ready | `app/lib/features/job_detail/*` + `whatsapp.dart` + `url_launcher` | `test/features/job_detail/*` | URL construction unit test |
| **Old bills import** T13 — form + bill_no unique inline + save-and-next | `app/lib/features/old_bills/*` | `test/features/old_bills/*` | <500 records manual |
| **Backups** T14 — `BackupService` (JSON+SQLite copy+restore) + `BackupScheduler` + `/admin` | `app/lib/data/backup/*`, `app/lib/features/backup/*` | `test/data/backup/backup_service_test.dart` | JSON is Web path |
| **Seed** T15 — `makes.csv` (29) + `DemoSeed` (6+6+6+2+6 idempotent) | `app/assets/makes.csv`, `app/lib/data/seed/demo_seed.dart` | `test/data/seed/demo_seed_test.dart` | Auto-seed when offline |
| **Docs** T16 — README + setup + Supabase linking + backups/seed docs + **now `docs/` full set** | `README.md`, `app/README.md`, `docs/*` | — | This matrix |

**Done means:** migration exists and `db reset` clean, `flutter analyze` no warnings, `flutter test` green, offline write → queue → flush verified.

---

## 1b. Hardening Phases 1–4 (post-MVP, pre-Phase-2) ✓

Shipped 2026-09-03. `flutter analyze` clean, 146 tests green.

| Phase | What changed | Probe |
|---|---|---|
| **P1 sync reliability** | `SyncWorker` auto-starts on boot (30s + reconnect); per-table fault isolation (`lastError`/`lastSyncAt`); global `SyncBanner` (offline/pending/retry) in home shell; pending-count provider | `app/lib/data/supabase/sync_providers.dart`, `app/lib/core/widgets/sync_banner.dart`, `test/data/supabase/sync_status_test.dart` |
| **P2 receptionist speed** | Dashboard status filters + FAB + vehicle-type labels; search name-match + recents + result counts + LIKE-escaping; create-job plate autofill + keep-customer-warm + View action; job-detail notes fix + call button + stepper fix | `test/features/{dashboard,search,create_job}/*` |
| **P3 data quality** | Phone hardening (trunk-0, brackets/dots); shared `validators.dart`; old-bills ledger + keep-date + live dup check + `Save & Done` stays put; open-job warning; real JSON restore + share-export (`file_picker`, `share_plus`) | `test/core/utils/validators_test.dart`, `test/features/old_bills/*` |
| **P4 UI polish** | Central `status_colors.dart` (no raw `Colors.` in screens); shared input/card/list-tile theme; 720px `ContentFrame` on 6 screens; shared `EmptyState` | `test/core/widgets/phase4_test.dart` |

---

## 2. MVP — Out of Scope (intentionally not shipped)

Locked per `DESIGN.md §3 Explicitly out of scope` and `§12`. Reintroducing any of these requires a new AGENTS task + DESIGN amendment.

| Feature | Why cut | What would be needed if revived |
|---|---|---|
| **Billing / GST / any amount field** | Different domain; zero money in MVP | New columns + RLS + out-of-scope reversal |
| **Photo uploads** | Slows job creation; storage cost | `image_picker` + Supabase Storage + RLS bucket |
| **Inventory / parts** | Out of domain | Full new aggregate |
| **In-app user management tab** | Owner uses Supabase dashboard | Admin CRUD + invite edge function |
| **Quick-pick complaint chips** | Free text first; chips later data-driven | Chip taxonomy from MVP corpus |
| **Fleet ≠ 2W/4W isolation** | Both first-class, single fleet | No change |

---

## 3. Phase 2 — Pending (Post-MVP roadmap from `DESIGN.md §3`)

Not implemented. `recommendation_queue` table exists as a stub; no service writes to it yet.

| Feature | Spec (`DESIGN.md`) | Estimated scope | Dependency |
|---|---|---|---|
| **Recommendation service** (Python/FastAPI cron) — service_due (+120d), churn (>120d since visit), offer | Writes `recommendation_queue` (`supabase/migrations/0001_init.sql` already has table) | New repo `supabase/functions` or external cron + `recommendation_queue` policies already owner-only | T1 (+ external service) |
| **Quick-pick complaint categories** | Data-driven chips from MVP free text | New table `complaint_categories` + UI chips in Create Job | Phase 1 corpus |
| **Voice input** (Hindi/English) | Speech-to-text for complaints | `speech_to_text` package + locale handling | Phase 1 field data |
| **Public ` /track/{job_id}` page** | Customer-facing read-only status | Public RLS policy (anon `select` by id), Web route, no auth | T2 RLS amendment |
| **Owner analytics** | Dashboard metrics (volume, turnaround) | Aggregation queries + charts (no money) | Job data |
| **Multi-device receptionists** | Concurrent writers; LWW may not suffice | CRDT/vector clock or "last writer wins + conflict toast" | Ops decision |
| **Inventory / Billing** | Explicit future domain | Full new DESIGN section | Product decision |

---

## 4. Gap Analysis — What would make MVP "more complete" without Phase 2

Optional hardening that could be done before Phase 2 without breaking locked decisions:

| Item | Effort | Value |
|---|---|---|
| File-picker restore affordance in `/admin` (pick JSON → `restoreFromJson`) | Small | Makes restore self-serve today (currently code-only, see `app/README.md:201`) |
| Analytics-light dashboard (e.g., 7-day sparkline of jobs by status) | Small–Med | No Phase 2 analytics scope, just counts over time |
| Search history / recent plates chips | Small | Speeds receptionist (<3s → even faster) |
| Offline banner in every screen (not only Dashboard) | Small | Reinforces offline badge system-wide |
| E2E sync proof (automated) | Done — `test/data/supabase/sync_e2e_test.dart`: offline create → online sync → second device sees job → owner edit returns | Proves the sync contract on every `flutter test` run |

None of these are required for MVP gate; list exists so product can prioritize explicitly.

---

## 5. How to verify shipped vs pending

```bash
# Shipped — should all pass
cd app
flutter analyze
flutter test   # covers every row in §1

supabase db reset  # proves migrations (T1–T2)

# Pending — should NOT exist yet
grep -R "recommendation.*cron\|pg_cron\|track/{job" app/lib supabase/  # expect only spec/table, no service
grep -R "amount\|price\|total\|gst\|inventory" app/lib                 # expect no hits (money ban)
```

---

## 6. Changelog for this matrix

- **2026-08-22 (1.0.0):** Initial publish. All T1–T16 marked shipped based on working-tree code that is present but not yet committed (`git status` shows `?? app/ supabase/`). Pending is Phase 2 per `DESIGN.md`. This is the authoritative "what exists" until `AGENTS.md Status Board` is flipped to ticked and committed.
- **2026-09-06 (1.1.1):** Doc-sync: dropped aspirational `supabase/config.toml` references (file never existed — link Supabase via Dashboard/SQL Editor per `app/README.md`), indexed `docs/agents/` skill docs, committed `AGENTS.md` skill block.
- **2026-09-06 (1.2.0):** E2E sync proof (`sync_e2e_test.dart` + shared `fake_remote_gateway.dart`); fixed `_dt('')` crash on nullable dates (`end_date`, `scheduled_for`) found by the new test.
