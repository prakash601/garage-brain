-- 0001_init.sql
-- Workshop OS initial schema (DESIGN.md §5). Append-only; never edit after merge.
-- RLS / profiles / app_role() live in 0002_rls.sql (task T2).

create extension if not exists "uuid-ossp";

create table customers (
  id         uuid primary key,
  name       text not null check (char_length(name) >= 2),
  phone      text not null unique check (phone ~ '^[6-9][0-9]{9}$'),
  created_at timestamptz not null default now()
);

create table vehicles (
  number_plate        text primary key
    check (
      char_length(number_plate) between 6 and 11
      and number_plate ~ '^[A-Z0-9]+$'
    ),
  vehicle_type        text not null check (vehicle_type in ('2W', '4W')),
  make                text not null,
  model               text not null,
  fuel_type           text check (fuel_type in ('Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid')),
  current_customer_id uuid references customers(id),
  created_at          timestamptz not null default now()
);

create table car_ownership_history (
  id                    uuid primary key,
  vehicle_number_plate  text not null references vehicles(number_plate) on delete cascade,
  customer_id           uuid references customers(id),
  start_date            date not null default current_date,
  end_date              date,
  created_at            timestamptz not null default now(),
  constraint chk_ownership_dates check (end_date is null or end_date >= start_date)
);

create type job_status as enum ('Arrived', 'InProgress', 'ReadyForDelivery', 'Delivered');

create sequence job_no_seq start 1;

create table job_cards (
  id                    uuid primary key,
  job_no                bigint not null default nextval('job_no_seq')
                          constraint uq_job_cards_job_no unique,
  vehicle_number_plate  text not null references vehicles(number_plate),
  customer_id           uuid not null references customers(id),
  km_reading            int check (km_reading >= 0),
  complaints            text not null,
  status                job_status not null default 'Arrived',
  closed                boolean not null default false,
  notes                 text,
  created_by            uuid references auth.users(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create table old_bills (
  id                   uuid primary key,
  bill_no              text not null unique,
  bill_date            date not null,
  vehicle_number_plate text references vehicles(number_plate),
  vehicle_category     text not null check (vehicle_category in ('2W', '4W')),
  customer_name        text not null,
  customer_phone       text check (customer_phone ~ '^[6-9][0-9]{9}$'),
  notes                text,
  created_at           timestamptz not null default now()
);

create table recommendation_queue (
  id                   uuid primary key,
  customer_id          uuid references customers(id),
  vehicle_number_plate text references vehicles(number_plate),
  type                 text check (type in ('service_due', 'churn', 'offer')),
  message              text not null,
  scheduled_for        date,
  sent                 boolean not null default false,
  created_at           timestamptz not null default now()
);

create index idx_job_cards_vehicle_time
  on job_cards (vehicle_number_plate, created_at desc);

create index idx_customers_phone
  on customers (phone);

create index idx_ownership_vehicle
  on car_ownership_history (vehicle_number_plate);

create index idx_old_bills_phone
  on old_bills (customer_phone);

create index idx_old_bills_plate
  on old_bills (vehicle_number_plate);

create or replace function touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_job_cards_updated
  before update on job_cards
  for each row execute function touch_updated_at();
