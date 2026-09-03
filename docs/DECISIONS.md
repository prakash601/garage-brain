# Locked Decisions Log — Garage Brain

**Mirror of `DESIGN.md §12` — do not re-litigate. Copy is intentional so this `docs/` set is self-contained. If a decision changes, update `DESIGN.md §12` first, then this file.**

| Decision | Choice | Source |
|---|---|---|
| Devices | 1 receptionist device + owner remote (web) | `DESIGN.md:378` + `AGENTS.md:12` |
| Phone policy | Indian mobiles only; phone = customer identity | `DESIGN.md:380` / `core/utils/phone.dart:4` |
| Plates | All formats accepted; soft warning vs classic pattern (`green`/`amber`/`red`) | `DESIGN.md:381` / `core/utils/plate.dart:9` |
| Status flow | 4 states `Arrived→InProgress→ReadyForDelivery→Delivered`; Delivered needs manual **Close** (`closed` bool) | `DESIGN.md:382` / `data/drift/tables.dart:79` |
| Dashboard | No money figures; pending + completed counts only | `DESIGN.md:383` / `features/dashboard/*` |
| Complaints | Free text now, quick-picks later (data-driven) | `DESIGN.md:384` |
| Search | Unified plate + phone box, Drift-only, <3 s | `DESIGN.md:385` / `features/search/*` |
| Make/model | Dropdown make (`assets/makes.csv` 29), free-text model | `DESIGN.md:386` |
| Job numbers | Sequential `JOB-xxxxxx` (`job_no_seq`); imported bills keep original unique `bill_no` | `DESIGN.md:387` / `core/utils/job_number.dart` |
| Import volume | <500 records, manual entry, fields per `old_bills` schema | `DESIGN.md:388` |
| Notification | `wa.me` deep link, no SMS vendor | `DESIGN.md:389` / `features/job_detail/whatsapp.dart` |
| Admin tab | Deferred; Supabase dashboard for user management | `DESIGN.md:390` / `routing/app_router.dart:35` |
| Duplicates | Same phone = same customer (upsert in place) | `DESIGN.md:391` / `data/repositories/customer_repository.dart` |
| KM reading | Optional (`km_reading >=0` nullable) | `DESIGN.md:392` / `data/drift/tables.dart:73` |
| Fleet scope | 2W and 4W are both first-class | `DESIGN.md:393` / `tables.dart:27`, `makes.csv` |
| Money | Nothing stored in MVP (no amount field anywhere) | `DESIGN.md:394` |
| Auth | Email + password, no signup | `DESIGN.md:395` / `features/auth/login_screen.dart` |
| Backup | Local Drift file backup + weekly JSON export (cross-platform) | `DESIGN.md:396` / `data/backup/backup_service.dart:11` |

Additions locked in this docs release:
- Documentation lives in `docs/` (`docs/README.md` is the index) and is served by `docs-site/` (see `DOCS_UI_PLAN.md`).
- New files/directories must update `docs/PROJECT_STRUCTURE.md` + `README.md` + `app/README.md` (enforced by updated `AGENTS.md` rule).

To unlock/change: propose in a PR that edits `DESIGN.md §12` + this file together, with product sign-off. Agents must not improvise a stub in another task's area to work around this log (`AGENTS.md:213`).
