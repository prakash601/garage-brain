# Garage Brain — Documentation Index

> Offline-first Workshop OS for 2W + 4W service workshops (Android + Web).  
> **Version:** 1.0.0 · **Date:** 2026-08-22 · **Status:** MVP implemented (Phase A–D complete)

This `docs/` folder is the authoritative documentation set. Every Mermaid diagram below renders on GitHub, VS Code, Docsify and VitePress without modification.

## Map

| Document | Purpose | Audience |
|---|---|---|
| [SRS — Software Requirements Specification](SRS.md) | Functional + non-functional requirements, use cases, acceptance criteria | Product, QA, devs |
| [HLD — High-Level Design](HLD.md) | System context, architecture, data flows, deployment, security model | Architects, reviewers |
| [LLD — Low-Level Design](LLD.md) | Class/table/API-level design, state transitions, contracts, test plan | Implementers |
| [Tech Stack](TECH_STACK.md) | Full stack choice, versions, justification, alternatives | Devs, hiring |
| [Project Structure](PROJECT_STRUCTURE.md) | Directory tree with file-level ownership + where to add new code | All contributors |
| [Feature Matrix](FEATURE_MATRIX.md) | Shipped vs pending vs out-of-scope (MVP → Phase 2) — single source of truth | Product, agents |
| [Diagrams](DIAGRAMS.md) | ER, sequence, sync, auth, navigation — all Mermaid sources in one place | Design reviews |
| [Docs UI Plan](DOCS_UI_PLAN.md) | Options to serve this documentation as a browsable site + recommended pick + scaffold | Product, devops |
| [Decisions Log](DECISIONS.md) | Locked decisions mirrored from `DESIGN.md §12` with rationale | Stakeholders |

## Cross-links

- Product truth: [`../DESIGN.md`](../DESIGN.md) — still the source for locked decisions.
- Agent plan: [`../AGENTS.md`](../AGENTS.md) — task board T1–T16, execution rules, doc-sync rule.
- Run instructions: [`../app/README.md`](../app/README.md) — fresh-machine setup, Supabase, build.
- Root summary: [`../README.md`](../README.md)
- Migrations: [`../supabase/migrations/`](../supabase/migrations/) — `0001_init.sql`, `0002_rls.sql` (append-only).
- Live docs UI: [`../docs-site/`](../docs-site/) — static site that serves this `docs/` folder (see [DOCS_UI_PLAN](DOCS_UI_PLAN.md)).

## Conventions

- **Mermaid** used for all diagrams (C4-style context, ER, sequence, state, flowchart). No binary image assets.
- **Snake_case** in SQL, **PascalCase** for Dart classes, **snake_case** for Dart files.
- All UUIDs are client-generated v4; `synced` lives only in Drift.
- Phone = `^[6-9][0-9]{9}$` bare 10 digits; plate = `^[A-Z0-9]{6,11}$` with green/amber/red classifier (`app/lib/core/utils/plate.dart:8`, `phone.dart:4`).

## How to edit docs

1. Edit markdown in `docs/` (or `DESIGN.md`/`AGENTS.md` if a locked decision changes).
2. If you add a **new file or directory** anywhere in the repo, you **must** update `docs/PROJECT_STRUCTURE.md` and the directory listing in `README.md` + `app/README.md` — enforced by `AGENTS.md §Conventions → Documentation sync` (new rule).
3. Render locally — either `docs-site` (Node) or `flutter run` docs route — see [DOCS_UI_PLAN](DOCS_UI_PLAN.md).
4. Commit with scoped prefix (`docs: …`, `feat(search): …`).

## Quick verify

```bash
# docs-site static build (after Node scaffold)
cd docs-site && npm run build

# Flutter docs route (once wired, see DOCS_UI_PLAN)
cd app && flutter run -d chrome
# → navigate to /docs
```
