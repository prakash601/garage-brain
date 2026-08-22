# Workshop OS — Design Document

**Version:** 0.2
**Status:** Draft (requirements locked after stakeholder review)
**Product:** Receptionist-first operating system for a vehicle workshop

---

## 1. Overview

Workshop OS is an offline-first application for a single workshop that services
**both 2-wheelers and 4-wheelers** as regular work. It lets the receptionist find
any vehicle's service history in under 3 seconds and create a new job card in
under 60 seconds, even when internet drops. The owner gets role-based admin
access and daily dashboards; customer retention recommendations come later.

**Success metrics**

| Metric | Target | Notes |
|---|---|---|
| History search | < 3 sec | Plate or phone lookup, works offline |
| Job creation | < 60 sec | Customer + vehicle + complaints in one flow |
| Offline resilience | Zero data loss | Occasional drops only; sync aggressively when online |

---

## 2. Users & Devices

- **1 receptionist on 1 device** (Android phone/tablet) — primary user.
- **Owner** — checks in remotely via Web build.
- Single-receptionist operation at launch; no simultaneous multi-device conflicts
  expected, but sync stays idempotent anyway.
- No self-signup: owner creates accounts (Supabase dashboard initially — no
  in-app admin tab at launch).
- Login: **email + password**.
- Roles stored as a custom JWT claim (`app_role`) via Supabase
  custom-access-token hook backed by a `profiles` table. Authorization enforced
  by RLS in Postgres.

| Role | Access |
|---|---|
| Receptionist | Dashboard, search, create jobs, update status/notes. No delete. |
| Owner | Everything above plus admin visibility (users managed via Supabase for now). |

---

## 3. Scope

### In scope (MVP)

1. **Unified search** — one search box matching both number plate **and** phone
   digits; shows timeline of recent jobs.
2. **Create customer + vehicle + job card** — single flow; free-text complaints;
   KM reading optional.
3. **Simplified status flow (4 states)** —
   `Arrived → InProgress → ReadyForDelivery → Delivered`.
   `Delivered` jobs stay visible until receptionist **manually closes** them from
   the dashboard.
4. **Dashboard** — today's jobs with status chips, pending count, completed count,
   manual close action. *(No money/collection figures anywhere in MVP.)*
5. **Offline-first writes** — local queue, background push on reconnect.
6. **"Ready" notification via WhatsApp deep link** — app opens `wa.me` with a
   prefilled message; receptionist hits send from her own WhatsApp. No SMS cost,
   no vendor setup.
7. **Human-readable job numbers** — new jobs get sequential `JOB-000001…`;
   imported historical records keep their **original bill numbers** (unique) so
   paper-book history matches.
8. **Historical bill import** — under 500 records, entered manually in-app.
   Captured fields: bill no, date, plate, customer name/phone, category (2W/4W).
9. **Backups** — Drift local file backup + periodic cloud export (Section 10).

### Explicitly out of scope (MVP)

| Feature | Why cut |
|---|---|
| Billing / GST / any money tracking | Different domain; no amounts stored at all in MVP. |
| Photo uploads | Slows job creation; storage cost. |
| Inventory / parts management | Out of domain. |
| In-app user management tab | Owner uses Supabase dashboard until needed. |
| Quick-pick complaint chips | Free text now; chips added later once wording patterns are known. |

### Phase 2 (post-MVP)

- Recommendation service (Python/FastAPI cron): service due (+120 days), churn
  risk (>120 days since visit), offers — written to `recommendation_queue`.
- Quick-pick complaint categories (data-driven from MVP free text).
- Voice input (Hindi/English), public `/track/{job_id}` page, owner analytics.

---

## 4. Architecture

```
┌───────────────────────────────────┐
│ Flutter app — Android + Web       │
│ Riverpod state · Drift SQLite     │
│ local mirror of Supabase schema   │
└──────────────┬────────────────────┘
               │ all writes hit Drift first; reads prefer local
               ▼
        ┌──────────────┐  aggressive sync (online most of the time)
        │ Drift queue  │ ── upsert unsynced rows ──▶ ┌────────────────┐
        │ synced=false │ ◀── pull changes ────────── │ Supabase PG    │
        └──────────────┘                             │ Auth · RLS · DB│
                                                     └────────────────┘
               ▼ "Ready" step opens wa.me deep link (client-side, zero cost)
```

Key decisions:

- **Local-first reads.** Screens read Drift; Supabase is durable truth.
- **Client-generated UUIDs** so Drift PK == Supabase PK → offline rows upsert
  cleanly. Server defaults are fallback only.
- **Sync state (`synced`) lives in Drift only**, never server-side.
- **Conflict rule: last-write-wins on `updated_at`** (Postgres trigger). Low risk:
  effectively one writer device.
- **Connectivity profile:** mostly online with occasional drops → sync worker runs
  aggressively (app start, reconnect event, 30s timer).

### Tech stack

| Layer | Choice | Why |
|---|---|---|
| Frontend | Flutter + Riverpod | Android + Web from one codebase; typed state/DI |
| Local store | Drift (SQLite) | Typed schema mirror, reactive queries, sync queue |
| Backend | Supabase (Postgres) | Free tier, auth, RLS, no ops |
| Notification | `wa.me` deep link | Zero cost, zero verification, receptionist-controlled |

---

## 5. Data Model

### Entity relationships

- A **customer** (phone = identity, unique) owns many **vehicles** over time.
- A **vehicle** (number_plate = natural PK, `vehicle_type` 2W/4W) has one current
  customer plus ownership history.
- A **job card** belongs to one vehicle + one customer; carries a human-readable
  `job_no` sequence.
- **old_bills** hold imported paper-book records keyed by their original unique
  bill number.

### Migration SQL (Supabase)

```sql
create extension if not exists "uuid-ossp";

-- Customers: phone IS the identity. App strips spaces/'+'/'91' before insert.
create table customers (
  id uuid primary key,                          -- client-generated UUIDv4
  name text not null check (char_length(name) >= 2),
  phone text not null unique check (phone ~ '^[6-9][0-9]{9}$'),
  created_at timestamptz default now()
);

-- Vehicles: covers bikes/scooters AND cars as regular work.
create table vehicles (
  number_plate text primary key,                -- normalized UPPER, no spaces/hyphens
  vehicle_type text not null check (vehicle_type in ('2W','4W')),
  make text not null,                           -- dropdown
  model text not null,                          -- free text
  fuel_type text check (fuel_type in ('Petrol','Diesel','CNG','Electric','Hybrid')),
  current_customer_id uuid references customers(id),
  created_at timestamptz default now()
);

-- Ownership trail (2nd owner / family member cases).
create table car_ownership_history (
  id uuid primary key,
  vehicle_number_plate text references vehicles(number_plate) on delete cascade,
  customer_id uuid references customers(id),
  start_date date not null default current_date,
  end_date date,
  created_at timestamptz default now()
);

create type job_status as enum ('Arrived','InProgress','ReadyForDelivery','Delivered');

create sequence job_no_seq start 1;

create table job_cards (
  id uuid primary key,                          -- client-generated (offline-safe)
  job_no bigint not null default nextval('job_no_seq'),  -- human-readable JOB-000001
  vehicle_number_plate text not null references vehicles(number_plate),
  customer_id uuid not null references customers(id),
  km_reading int check (km_reading >= 0),       -- optional
  complaints text not null,                     -- free text in MVP
  status job_status not null default 'Arrived',
  closed boolean not null default false,        -- manual close after Delivered
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Imported paper-book history (<500 records). Original bill numbers preserved.
-- No amounts stored — money is out of MVP scope entirely.
create table old_bills (
  id uuid primary key,
  bill_no text not null unique,                 -- original book number
  bill_date date not null,
  vehicle_number_plate text references vehicles(number_plate),
  vehicle_category text not null check (vehicle_category in ('2W','4W')),
  customer_name text not null,
  customer_phone text check (customer_phone ~ '^[6-9][0-9]{9}$'),
  notes text,
  created_at timestamptz default now()
);

-- Phase 2 recommendation output.
create table recommendation_queue (
  id uuid primary key,
  customer_id uuid references customers(id),
  vehicle_number_plate text references vehicles(number_plate),
  type text check (type in ('service_due','churn','offer')),
  message text not null,
  scheduled_for date,
  sent boolean default false
);
```

### Plate validation

Normalization (uppercase, strip spaces/hyphens) happens in the UI. Because
non-classic formats must be accepted (BH-series like `21BH2345A`, etc.):

```sql
alter table vehicles add constraint chk_plate_len
  check (char_length(number_plate) between 6 and 11 and number_plate ~ '^[A-Z0-9]+$');
```

UI rule: if the plate matches the classic pattern
(`^[A-Z]{2}[0-9]{2}[A-Z]{1,3}[0-9]{1,4}$`) → green. Otherwise → amber warning
("check plate") but **save is allowed**. Hard-fail only on non-alphanumeric.

### Indexes (for the <3s search goal)

```sql
create index idx_job_cards_vehicle_time on job_cards (vehicle_number_plate, created_at desc);
create index idx_customers_phone on customers (phone);
create index idx_ownership_vehicle on car_ownership_history (vehicle_number_plate);
create index idx_old_bills_phone on old_bills (customer_phone);
```

### updated_at trigger & conflict rule

```sql
create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

create trigger trg_job_cards_updated
  before update on job_cards
  for each row execute function touch_updated_at();
```

Conflicts during sync resolve last-write-wins using `updated_at`.

> **Job numbering note:** `job_no` comes from a Postgres sequence, but
> offline-created jobs need their final number at insert time. The app reserves
> ranges (fetch `next N` from an RPC on connect) or assigns numbers during sync.
> Decide during implementation — imported `old_bills.bill_no` is independent and
> already unique.

---

## 6. Application Screens

### S1 — Auth
Email + password. No signup. Redirect by role claim.

### S2 — Dashboard
- Today's jobs list with status chips; pull-to-refresh + offline badge.
- Counters: pending vehicles, completed today.
- **Manual close** action on Delivered jobs (removes them from active lists).
- No revenue/collection widgets.

### S3 — Search (unified)
- One search box: matches plate fragments **and** phone digits simultaneously.
- Typo-flag UI on plate-like input (green/amber per Section 5 rules).
- Found → timeline of recent jobs (+ old_bills merged) → tap into detail.
- Not found → CTA to create job (S4).

### S4 — Create Job
- Vehicle: plate auto-normalized, type toggle (2W/4W), make dropdown, model free
  text, fuel type.
- Customer: name + phone (normalized; same phone = same person, name updated in
  place if spelling differs).
- Complaints free-text textarea; KM reading optional.
- Save → Drift immediately, `synced=false`; instant UI confirmation.

### S5 — Job Detail
- Status stepper: `Arrived → InProgress → ReadyForDelivery → Delivered`.
- Notes; customer/vehicle history timeline.
- On `ReadyForDelivery`: button opens `wa.me/<phone>?text=<prefilled ready
  message>` — receptionist sends from her own WhatsApp.

---

## 7. Offline Sync Design

1. Every mutation writes Drift first with `synced = false`.
2. Sync worker (app start / reconnect / 30s timer):
   - upsert unsynced rows (safe: IDs are client-generated),
   - pull changes since last successful sync,
   - mark rows `synced = true` after confirmed push.
3. Last-write-wins on `updated_at`; single-writer reality keeps this simple.
4. Reads never block on network; badge shows connectivity state.

---

## 8. Security

```sql
alter table customers enable row level security;
alter table vehicles enable row level security;
alter table job_cards enable row level security;
alter table car_ownership_history enable row level security;
alter table old_bills enable row level security;
alter table recommendation_queue enable row level security;

create or replace function app_role() returns text
language sql stable as $$
  select coalesce(auth.jwt() ->> 'app_role', 'anon');
$$;

-- Receptionist: select/insert/update, no delete. Owner: full access.
create policy "staff_read"   on job_cards for select using (app_role() in ('receptionist','owner'));
create policy "staff_insert" on job_cards for insert with check (app_role() in ('receptionist','owner'));
create policy "staff_update" on job_cards for update using (app_role() in ('receptionist','owner'));
-- repeat shape for customers, vehicles, ownership_history, old_bills;

create policy "owner_only" on recommendation_queue
  for all using (app_role() = 'owner');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('receptionist','owner'))
);
-- Supabase custom-access-token hook embeds profiles.role as JWT claim app_role.
```

Only the public anon key ships in the client; authorization is fully server-side.

---

## 9. Notifications

Single notification moment: status → `ReadyForDelivery`. Client builds a
prefilled WhatsApp message (vehicle, job no, "ready for delivery") and opens the
`wa.me` deep link. No server integration, no per-message cost, works offline
(link opens when connectivity returns).

---

## 10. Backups & Data Safety

- **Local:** scheduled Drift database file backup on-device.
- **Cloud:** weekly export (JSON/CSV) downloadable by the owner, in addition to
  Supabase's built-in backups.

---

## 11. Non-functional Requirements

- Plate/phone search <3s locally; job creation completable in <60s.
- Platforms at launch: **Android + Web** (iOS deferred, same codebase).
- English UI; complaints may be typed in Hindi/romanized Hindi.
- Free tiers only; WhatsApp notifications cost nothing.

---

## 12. Locked Decisions Log

| Decision | Choice |
|---|---|
| Devices | 1 receptionist device + owner remote (web) |
| Phone policy | Indian mobiles only; phone = customer identity |
| Plates | All formats accepted; soft warning vs classic pattern |
| Status flow | 4 states; Delivered needs manual close |
| Dashboard | No money figures; pending + completed counts only |
| Complaints | Free text now, quick-picks later |
| Search | Unified plate + phone box |
| Make/model | Dropdown make, free-text model |
| Job numbers | Sequential JOB-000001; imported bills keep original unique bill_no |
| Import volume | <500 records, manual entry, fields per old_bills schema |
| Notification | wa.me deep link, no SMS vendor |
| Admin tab | Deferred; Supabase dashboard for user management |
| Duplicates | Same phone = same customer |
| KM reading | Optional |
| Fleet scope | 2W and 4W are both first-class |
| Money | Nothing stored in MVP |
| Auth | Email + password |
| Backup | Local Drift backup + weekly cloud export |
