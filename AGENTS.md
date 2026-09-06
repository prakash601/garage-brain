# AGENTS.md — Workshop OS

Implementation plan and working conventions for this repository.
**Read `DESIGN.md` first** — it is the source of truth for product decisions.
Do not re-litigate decisions listed in DESIGN.md §12 (Locked Decisions Log).

---

## Project Summary

Offline-first Flutter app for a vehicle workshop (2W + 4W). One receptionist on
one Android device; owner checks in via web. Local-first reads/writes via Drift
(SQLite); Supabase is the durable backend. WhatsApp deep-link notifications.

- **Stack:** Flutter · Riverpod · Drift · Supabase (Postgres, RLS, Auth)
- **Platforms at launch:** Android + Web
- **No money/amount fields anywhere. No photo uploads. No inventory.**

## Planned Repo Layout

```
supabase/
  migrations/          # ordered .sql migrations
  config/              # project config (non-secret)
app/                   # Flutter app root
  lib/
    main.dart
    core/              # constants, utils (plate/phone normalizers, validators)
    data/
      drift/           # Drift database: tables, DAOs
      supabase/        # remote client, sync worker
      repositories/    # one repository per aggregate (customer, vehicle, job)
    features/
      auth/            # S1
      dashboard/       # S2
      search/          # S3
      create_job/      # S4
      job_detail/      # S5
      old_bills/       # import UI
    routing/           # go_router config + role-based redirect
  test/                # unit + widget tests mirroring lib/
```

## Commands

```bash
# Flutter
cd app && flutter pub get
flutter analyze                 # must pass clean before any commit
flutter test                    # all tests green before any commit
flutter run -d chrome           # web target
flutter run -d <device-id>      # android target
flutter gen-l10n                # if l10n added later

# Supabase (if CLI linked)
supabase db push                # apply migrations in order
supabase db reset               # local rebuild from migrations
```

Lint/typecheck gates: `flutter analyze` + `flutter test` are the only required
gates until noted otherwise.

---

## Conventions

- Dart: `flutter_lints` defaults. No comments unless a non-obvious decision needs
  explaining; reference DESIGN.md sections instead of duplicating prose.
- Naming: tables/columns snake_case in SQL; Dart classes PascalCase, files
  snake_case. Feature folders own their widgets/controllers — no shared "widgets/"
  dumping ground unless used by ≥2 features.
- All UUIDs are generated client-side (`uuid` package v4) — never rely on DB
  defaults for PKs that sync.
- Every mutation goes through a **repository**, which writes to Drift first with
  `synced = false`. Screens never talk to Supabase directly except auth.
- Phone normalization helper: strip spaces, dashes, `+`, leading `91`; store bare
  10 digits. Plate normalization helper: uppercase, strip spaces/hyphens.
- SQL migrations are append-only, numbered `0001_…sql`, `0002_…sql`. Never edit a
  merged migration.
- Commits: imperative mood, scoped prefix (`feat(search): …`, `fix(sync): …`,
  `db: add old_bills table`). Small commits per task.
- Secrets: only the Supabase **anon key** may ship in client code via
  `--dart-define`. Never commit service keys or `.env`.
- Documentation sync (mandatory): whenever you create, rename, move, or delete
  any file or directory — anywhere in the repo (including `app/lib/**`,
  `supabase/**`, `tool/**`, `docs/**`, `docs-site/**`) — you **must** in the
  same PR/commit update:
  1. `docs/PROJECT_STRUCTURE.md` — the authoritative directory tree,
  2. `docs/README.md` — the docs index / cross-links if the change affects docs,
  3. `README.md` (root) and `app/README.md` — directory listings / cross-links,
  4. `docs-site` nav/sidebar if the new page should appear in the browsable docs,
  5. `docs/FEATURE_MATRIX.md` if the change adds or retires a user-facing feature.
  Keep `DESIGN.md` and `AGENTS.md` consistent if a locked decision changes.
  Agents: treat a missing README/structure update as a failed verification gate
  (like `flutter analyze`). Suggested pre-commit check:
  `git diff --name-only --diff-filter=ACR | grep -v PROJECT_STRUCTURE | grep -v README` —
  if non-empty, ensure the docs files above are also in `git diff --name-only`.

### Testing expectations

- Unit tests mandatory for: phone/plate normalizers, validators, sync queue
  logic, repositories (with in-memory Drift).
- Widget tests mandatory for: search typo-flag UI, status stepper transitions,
  create-job validation flow.
- Each task lists its verification command; run it before marking done.

---

## Implementation Plan

Work is split into independently runnable tasks. Dependencies are explicit —
a task marked `(needs T#)` must not start until its dependency's PR merges.
Tasks without overlapping file scopes can run in parallel.

### Phase A — Foundations

#### T1. Database migrations `(no deps)` — *files: `supabase/migrations/`*
Write `0001_init.sql` containing everything from DESIGN.md §5 + §8:
extensions, `customers`, `vehicles` (2W/4W), `car_ownership_history`,
`job_status` enum (4 states), `job_no_seq`, `job_cards` (+ `closed` bool),
`old_bills`, `recommendation_queue`, plate length/format check, all indexes,
`touch_updated_at()` trigger + trigger on `job_cards`.
Verify: `supabase db reset` applies cleanly; smoke-test inserts for each table.

#### T2. Auth & RLS SQL `(needs T1)` — *files: `supabase/migrations/0002_rls.sql`*
`profiles` table, `app_role()` helper, custom-access-token hook config notes,
RLS enable + policies per DESIGN.md §8 (staff select/insert/update everywhere;
recommendation_queue owner-only).
Verify: policy matrix tested as receptionist vs owner vs anon roles.

#### T3. Flutter scaffold `(no deps)` — *files: `app/`*
`flutter create`, deps: `riverpod`, `flutter_riverpod`, `drift`, `drift_dev`,
`build_runner`, `go_router`, `supabase_flutter`, `uuid`, `connectivity_plus`.
Wire `flutter_lints`, app shell with bottom nav placeholder, dark/light theme
tokens, `--dart-define` config reader for SUPABASE_URL/ANON_KEY.
Verify: `flutter analyze` clean; empty app runs on Chrome and Android.

#### T4. Core utilities `(no deps, pure Dart)` — *files: `app/lib/core/`, `test/core/`*
Phone normalizer + validator (Indian mobile regex), plate normalizer +
classifier (green = classic pattern match, amber = other alnum 6–11 chars,
red = invalid chars). Job-number formatter (`JOB-%06d`).
Verify: full unit-test coverage of edge cases (O/0 plates, +91 numbers, etc.).

### Phase B — Data Layer

#### T5. Drift schema mirror `(needs T3)` — *files: `app/lib/data/drift/`*
Drift tables mirroring every Supabase table + `synced` boolean on each synced
table + `synced_at` timestamps. Open database, type converters for enums.
Verify: opens in-memory; round-trip insert/select test per table.

#### T6. Repositories `(needs T4, T5)` — *files: `app/lib/data/repositories/`, `test/repositories/`*
CustomerRepository (phone-is-identity upsert semantics), VehicleRepository,
JobRepository (create with client UUID + local job_no placeholder, status
transitions guarded to legal moves only, manual close), OldBillsRepository,
OwnershipRepository (close-old/open-new on owner change).
Verify: unit tests against in-memory Drift covering duplicate-phone merge,
illegal status transition rejection.

#### T7. Sync worker `(needs T6)` — *files: `app/lib/data/supabase/`*
Push unsynced rows (upsert by client UUID), pull-changes-since cursor,
mark-synced bookkeeping. Triggers: app start, connectivity regained
(`connectivity_plus`), 30s timer. Last-write-wins on `updated_at`.
Verify: integration-style test with mocked remote: create offline → flush →
assert pushed and marked; conflict test where newer `updated_at` wins.

### Phase C — Features

#### T8. Auth feature S1 `(needs T3, T7 optional)` — *files: `app/lib/features/auth/`, `app/lib/routing/`*
Email/password login screen, session persistence, go_router redirect by role
claim (receptionist → dashboard; owner → dashboard + admin entry point stub).
No signup screen.
Verify: widget test for failed/succeeded login; redirect unit test.

#### T9. Search S3 `(needs T6, T8)` — *files: `app/lib/features/search/`*
Unified search box matching plate fragments AND phone digits simultaneously;
green/amber/red live flag using T4 classifier; results → recent-jobs timeline
(jobs merged with old_bills by plate/phone); empty state CTA → Create Job.
Debounced, reads Drift only (<3s requirement).
Verify: widget tests: plate hit, phone hit, amber-flag input, not-found state.

#### T10. Create Job S4 `(needs T6, T8, T9 for CTA wiring)` — *files: `app/lib/features/create_job/`*
Single flow: vehicle section (normalized plate w/ live flag, 2W/4W toggle,
make dropdown from seeded list in assets, model free text, fuel type),
customer section (name, normalized phone; existing phone pre-fills name),
complaints free text, optional KM. Save → Drift instantly, success snackbar
without waiting on network.
Verify: widget test of full happy path <60s interaction budget; validation
tests; offline save test (network off, row lands in queue).

#### T11. Dashboard S2 `(needs T6, T8)` — *files: `app/lib/features/dashboard/`*
Today's jobs list with status chips, pending count, completed count,
pull-to-refresh, offline badge, manual close action on Delivered rows.
No revenue widgets ever.
Verify: widget tests for counts math, close flow, offline badge visibility.

#### T12. Job Detail S5 + WhatsApp `(needs T6, T9/T10 navigation)` — *files: `app/lib/features/job_detail/`*
Status stepper (Arrived→InProgress→ReadyForDelivery→Delivered), notes editing,
vehicle/customer history timeline, `wa.me/<phone>?text=…` launch button shown at
ReadyForDelivery (prefilled message: vehicle, job no, ready text; URL-launcher
package).
Verify: stepper transition tests; deep-link URL construction unit test.

#### T13. Old bills import `(needs T6, T8)` — *files: `app/lib/features/old_bills/`*
Simple repeatable form: bill_no (unique, dup rejected inline), bill_date, plate,
category, customer name/phone, notes. Bulk-friendly UX (save-and-next keeps
plate/customer warm).
Verify: widget test incl. duplicate bill_no rejection.

### Phase D — Hardening

#### T14. Backups `(needs T7)` — scheduled Drift file copy on-device; weekly JSON
export shareable/downloadable by owner.
Verify: export contains all tables; restore path documented in README.

#### T15. Seed make/model list + demo dataset `(needs T5)` — assets CSV of common
makes/models; dev seed script with sample customers/vehicles/jobs for testing.
Verify: seeds idempotent.

#### T16. README + setup docs `(needs T1–T3 merged)` — local dev setup, Supabase
project linking, dart-defines, deploy/run instructions for Android + Web.
Verify: fresh-machine walkthrough succeeds.

---

## Task Execution Rules for Agents

1. Announce the task ID you are executing; do only that task's scope.
2. Never touch files owned by another unmerged task; if a dependency is missing,
   stop and report instead of improvising a stub in someone else's area.
3. Shared code needed by two tasks goes into the earlier task or a new numbered
   task — not silently into whichever PR notices it second.
4. Run `flutter analyze` + `flutter test` (and the task's verify step) before
   finishing. Paste failures, don't hide them.
5. Update this file: tick nothing manually — completed tasks get their PR merged
   and the task list below is updated in the merging PR.

### Status Board

| Task | Depends on | Status |
|---|---|---|
| T1 migrations | — | done |
| T2 RLS | T1 | done |
| T3 scaffold | — | done |
| T4 core utils | — | done |
| T5 drift schema | T3 | done |
| T6 repositories | T4, T5 | done |
| T7 sync worker | T6 | done |
| T8 auth | T3 | done |
| T9 search | T6, T8 | done |
| T10 create job | T6, T8, T9 | done |
| T11 dashboard | T6, T8 | done |
| T12 job detail | T6 | done |
| T13 old bills | T6, T8 | done |
| T14 backups | T7 | done |
| T15 seed data | T5 | done |
| T16 docs | T1–T3 | done |

Parallelizable now: **T1, T3, T4** (zero overlap). After those: T5+T8 together,
then T6, then T7/T9/T11/T13 branch out.

---

## Agent skills

### Issue tracker

GitHub Issues via `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels as-is. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout. See `docs/agents/domain.md`.
