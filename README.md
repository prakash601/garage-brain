# Garage Brain — Workshop OS

> Offline-first Flutter app for a vehicle workshop (2W + 4W). One Android device for the receptionist; owner on Web. Drift + Supabase + wa.me.

**Stack:** Flutter · Riverpod · Drift (SQLite) · Supabase (Postgres, RLS, Auth) · `connectivity_plus` · `go_router` · `uuid`  
**Platforms:** Android (primary) + Web (owner). iOS deferred. No money fields, no photos, no inventory — see `docs/DECISIONS.md`.

## Docs

| Doc | What it is |
|---|---|
| [`docs/README.md`](docs/README.md) | Docs index & cross-links |
| [`docs/SRS.md`](docs/SRS.md) | Software Requirements Specification (FR-01..10, NFRs, use cases, traceability) |
| [`docs/HLD.md`](docs/HLD.md) | High-Level Design (C4 context/container, flows, sync, security, deployment) |
| [`docs/LLD.md`](docs/LLD.md) | Low-Level Design (tables/enums/repos/sync/auth/routing/screens, with `file:line` refs) |
| [`docs/TECH_STACK.md`](docs/TECH_STACK.md) | Full stack & versions & justification |
| [`docs/PROJECT_STRUCTURE.md`](docs/PROJECT_STRUCTURE.md) | Authoritative directory tree + where to add new code |
| [`docs/FEATURE_MATRIX.md`](docs/FEATURE_MATRIX.md) | Shipped vs pending vs out-of-scope (single truth) — **start here for "what exists"** |
| [`docs/DIAGRAMS.md`](docs/DIAGRAMS.md) | All Mermaid diagrams in one place |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Locked decisions (mirror `DESIGN.md §12`) |
| [`docs/DOCS_UI_PLAN.md`](docs/DOCS_UI_PLAN.md) | Docs UI options + recommended hybrid + scaffold |
| [`DESIGN.md`](DESIGN.md) | Product truth (source for decisions) |
| [`AGENTS.md`](AGENTS.md) | Task board T1–T16 + conventions (read before coding) |
| [`docs-site/`](docs-site/) | Browsable docs site (Docsify zero-build + VitePress build) → `docs-site/README.md` |

Rule: `AGENTS.md §Conventions → Documentation sync` — creating/renaming/deleting any file or directory **must** update `docs/PROJECT_STRUCTURE.md` + directory listings here and in `app/README.md` + `docs-site` nav + `docs/FEATURE_MATRIX.md` if the feature set changed. Treat a missing update as a failed gate like `flutter analyze`.

## Directory layout

```
garage-brain/
├── docs/                    # Full SRS/HLD/LLD set (authoritative)
├── docs-site/               # Static docs UI (see docs/DOCS_UI_PLAN.md)
├── supabase/migrations/     # 0001_init.sql, 0002_rls.sql (append-only)
├── app/                     # Flutter app root — `flutter run -d chrome` / Android
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/            # phone/plate normalizers, validators, job_number, theme, app_config
│   │   ├── data/
│   │   │   ├── drift/       # Drift tables mirroring Supabase + synced flag
│   │   │   ├── supabase/    # sync_worker + remote_gateway
│   │   │   ├── repositories/# customer/vehicle/job/old_bills/ownership
│   │   │   ├── backup/      # T14: BackupService + scheduler
│   │   │   └── seed/        # T15: DemoSeed
│   │   ├── features/        # auth/dashboard/search/create_job/job_detail/old_bills/backup
│   │   └── routing/         # go_router + role redirect (routeRedirect)
│   ├── assets/makes.csv     # 29 makes for dropdown
│   ├── tool/seed_demo.dart  # Idempotent demo run
│   └── test/                # Mirrors lib/ (core + drift + repos + sync + features + routing + backup + seed)
├── DESIGN.md                # Product truth v0.2
└── AGENTS.md                # Implementation plan + conventions
```

See `docs/PROJECT_STRUCTURE.md` for the full tree with file-level ownership (when it and this listing diverge, `docs/PROJECT_STRUCTURE.md` wins).

## Browsable docs (UI)

```bash
# Docsify fallback — no Node needed:
cd docs-site && python3 -m http.server 3000   # open http://localhost:3000
# or
npx serve docs-site

# VitePress — polished (requires Node 20+):
cd docs-site && npm install && npm run docs:dev   # http://localhost:5173
cd docs-site && npm run docs:build               # .vitepress/dist/ → GitHub Pages / Vercel
```

See `docs/DOCS_UI_PLAN.md` for the full options matrix (Docsify vs VitePress vs Docusaurus vs MkDocs vs Starlight vs in-app `flutter_markdown`) and the hosting recipes.

## Quick start

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze && flutter test
flutter run -d chrome --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…
```

Supabase linking, auth hook, keys, backups, seed, deploy: see [`app/README.md`](app/README.md). Diagrams render natively on GitHub (all Mermaid) — also via `docs-site/`.

## Verification gate

```bash
cd app && flutter analyze && flutter test
# any commit must also keep docs/PROJECT_STRUCTURE.md + this README + app/README.md + docs-site nav + FEATURE_MATRIX.md in sync (AGENTS.md rule)
```
