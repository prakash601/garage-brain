-- 0002_rls.sql
-- Auth & RLS (DESIGN.md §8). Append-only; never edit after merge.
--
-- Custom-access-token hook setup (done in Supabase Dashboard > Auth > Hooks,
-- not expressible in SQL migrations):
--   1. Enable "Custom Access Token" hook.
--   2. Hook function (created below as auth.custom_access_token_hook) adds
--      claim: app_role = profiles.role of the user.
--   3. Grant execute on that function to supabase_auth_admin.
--
-- Roles live only in JWT claims; the client never queries profiles directly.
-- Receptionist: select/insert/update everywhere, no delete.
-- Owner: full access everywhere. recommendation_queue is owner-only entirely.

create or replace function app_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(auth.jwt() ->> 'app_role', 'anon');
$$;

revoke all on function app_role() from public;
grant execute on function app_role() to authenticated, anon;

create table public.profiles (
  id   uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('receptionist','owner'))
);

alter table public.profiles enable row level security;

create policy "staff_read_profiles"
  on public.profiles for select
  using (app_role() in ('receptionist','owner'));

-- Custom Access Token hook: embeds profiles.role as the `app_role` JWT claim.
create or replace function auth.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
as $$
declare
  claims jsonb;
  user_role text;
begin
  select role into user_role from public.profiles where id = (event ->> 'user_id')::uuid;

  claims := event -> 'claims';
  if user_role is not null then
    claims := jsonb_set(claims, '{app_role}', to_jsonb(user_role));
  else
    claims := jsonb_set(claims, '{app_role}', '"anon"');
  end if;

  event := jsonb_set(event, '{claims}', claims);
  return event;
end;
$$;

grant execute on function auth.custom_access_token_hook(jsonb) to supabase_auth_admin;

-- RLS enablement
alter table public.customers              enable row level security;
alter table public.vehicles               enable row level security;
alter table public.job_cards              enable row level security;
alter table public.car_ownership_history  enable row level security;
alter table public.old_bills              enable row level security;
alter table public.recommendation_queue   enable row level security;

-- Staff policies per table: select/insert/update for both roles,
-- delete for owner only. Generated with the same shape as job_cards in §8.

create policy "staff_read_customers"     on public.customers     for select using (app_role() in ('receptionist','owner'));
create policy "staff_insert_customers"   on public.customers     for insert with check (app_role() in ('receptionist','owner'));
create policy "staff_update_customers"   on public.customers     for update using (app_role() in ('receptionist','owner'));
create policy "owner_delete_customers"   on public.customers     for delete using (app_role() = 'owner');

create policy "staff_read_vehicles"      on public.vehicles      for select using (app_role() in ('receptionist','owner'));
create policy "staff_insert_vehicles"    on public.vehicles      for insert with check (app_role() in ('receptionist','owner'));
create policy "staff_update_vehicles"    on public.vehicles      for update using (app_role() in ('receptionist','owner'));
create policy "owner_delete_vehicles"    on public.vehicles      for delete using (app_role() = 'owner');

create policy "staff_read_job_cards"     on public.job_cards     for select using (app_role() in ('receptionist','owner'));
create policy "staff_insert_job_cards"   on public.job_cards     for insert with check (app_role() in ('receptionist','owner'));
create policy "staff_update_job_cards"   on public.job_cards     for update using (app_role() in ('receptionist','owner'));
create policy "owner_delete_job_cards"   on public.job_cards     for delete using (app_role() = 'owner');

create policy "staff_read_ownership_history"    on public.car_ownership_history for select using (app_role() in ('receptionist','owner'));
create policy "staff_insert_ownership_history"  on public.car_ownership_history for insert with check (app_role() in ('receptionist','owner'));
create policy "staff_update_ownership_history"  on public.car_ownership_history for update using (app_role() in ('receptionist','owner'));
create policy "owner_delete_ownership_history"  on public.car_ownership_history for delete using (app_role() = 'owner');

create policy "staff_read_old_bills"     on public.old_bills     for select using (app_role() in ('receptionist','owner'));
create policy "staff_insert_old_bills"   on public.old_bills     for insert with check (app_role() in ('receptionist','owner'));
create policy "staff_update_old_bills"   on public.old_bills     for update using (app_role() in ('receptionist','owner'));
create policy "owner_delete_old_bills"   on public.old_bills     for delete using (app_role() = 'owner');

-- Owner-only aggregate (DESIGN.md §8): no receptionist access at all.
create policy "owner_only_recommendation_queue"
  on public.recommendation_queue
  for all
  using (app_role() = 'owner')
  with check (app_role() = 'owner');
