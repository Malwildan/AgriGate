create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.lahan (
  id bigint primary key,
  owner text not null,
  area text not null,
  location text not null default '',
  status text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz,
  constraint lahan_status_check
    check (status in ('Aktif', 'Perencanaan', 'Tidak Aktif'))
);

create table if not exists public.scan_records (
  id bigint primary key,
  lahan_id bigint not null references public.lahan (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  recorded_at timestamptz not null,
  ph double precision not null,
  moisture integer not null,
  recommendation text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz
);

create index if not exists idx_lahan_user_id on public.lahan (user_id);
create index if not exists idx_scan_records_user_id on public.scan_records (user_id);
create index if not exists idx_scan_records_lahan_id on public.scan_records (lahan_id);

drop trigger if exists set_lahan_updated_at on public.lahan;
create trigger set_lahan_updated_at
before update on public.lahan
for each row
execute function public.set_updated_at();

drop trigger if exists set_scan_records_updated_at on public.scan_records;
create trigger set_scan_records_updated_at
before update on public.scan_records
for each row
execute function public.set_updated_at();

alter table public.lahan enable row level security;
alter table public.scan_records enable row level security;

drop policy if exists "Users can read own lahan" on public.lahan;
create policy "Users can read own lahan"
on public.lahan
for select
using (auth.uid() = user_id);

drop policy if exists "Users can insert own lahan" on public.lahan;
create policy "Users can insert own lahan"
on public.lahan
for insert
with check (auth.uid() = user_id);

drop policy if exists "Users can update own lahan" on public.lahan;
create policy "Users can update own lahan"
on public.lahan
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own lahan" on public.lahan;
create policy "Users can delete own lahan"
on public.lahan
for delete
using (auth.uid() = user_id);

drop policy if exists "Users can read own scan records" on public.scan_records;
create policy "Users can read own scan records"
on public.scan_records
for select
using (auth.uid() = user_id);

drop policy if exists "Users can insert own scan records" on public.scan_records;
create policy "Users can insert own scan records"
on public.scan_records
for insert
with check (auth.uid() = user_id);

drop policy if exists "Users can update own scan records" on public.scan_records;
create policy "Users can update own scan records"
on public.scan_records
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own scan records" on public.scan_records;
create policy "Users can delete own scan records"
on public.scan_records
for delete
using (auth.uid() = user_id);