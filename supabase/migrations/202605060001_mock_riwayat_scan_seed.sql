-- Mock riwayat scan seed for manual verification.
-- Replace target_user_id with a valid auth.users.id before running manually if
-- you want the inserts below to execute. The default UUID keeps this script as
-- a safe no-op in environments where no matching auth user exists yet.

do $$
declare
  target_user_id uuid := 'f5315c63-be98-4d3a-850a-a5bc9603ffb7';
begin
  if not exists (
    select 1
    from auth.users
    where id = target_user_id
  ) then
    raise notice 'Skipping mock riwayat scan seed. Replace target_user_id with a valid auth.users.id before applying this seed manually.';
    return;
  end if;

  insert into public.lahan (
    id,
    owner,
    area,
    location,
    status,
    user_id,
    created_at,
    updated_at,
    deleted_at
  )
  values
    (
      91000001,
      'Pak Budi',
      '2 Hektar',
      '-6.2000, 106.8166',
      'Aktif',
      target_user_id,
      '2026-04-10T07:00:00Z',
      '2026-05-06T08:20:00Z',
      null
    ),
    (
      91000002,
      'Bu Sari',
      '1.2 Hektar',
      '-7.2575, 112.7521',
      'Perencanaan',
      target_user_id,
      '2026-03-22T08:30:00Z',
      '2026-05-05T06:10:00Z',
      null
    )
  on conflict (id) do update
  set
    owner = excluded.owner,
    area = excluded.area,
    location = excluded.location,
    status = excluded.status,
    user_id = excluded.user_id,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at;

  insert into public.scan_records (
    id,
    lahan_id,
    user_id,
    recorded_at,
    ph,
    moisture,
    recommendation,
    created_at,
    updated_at,
    deleted_at
  )
  values
    (
      92000001,
      91000001,
      target_user_id,
      '2026-04-12T07:15:00Z',
      5.4,
      38,
      'Jagung',
      '2026-04-12T07:20:00Z',
      '2026-04-12T07:20:00Z',
      null
    ),
    (
      92000002,
      91000001,
      target_user_id,
      '2026-04-24T07:20:00Z',
      6.1,
      48,
      'Padi',
      '2026-04-24T07:25:00Z',
      '2026-04-24T07:25:00Z',
      null
    ),
    (
      92000003,
      91000001,
      target_user_id,
      '2026-05-03T07:25:00Z',
      6.4,
      56,
      'Cabai',
      '2026-05-03T07:30:00Z',
      '2026-05-03T07:30:00Z',
      null
    ),
    (
      92000004,
      91000001,
      target_user_id,
      '2026-05-06T07:30:00Z',
      6.8,
      62,
      'Cabai',
      '2026-05-06T07:35:00Z',
      '2026-05-06T07:35:00Z',
      null
    ),
    (
      92000005,
      91000002,
      target_user_id,
      '2026-03-28T08:10:00Z',
      5.8,
      44,
      'Kedelai',
      '2026-03-28T08:15:00Z',
      '2026-03-28T08:15:00Z',
      null
    ),
    (
      92000006,
      91000002,
      target_user_id,
      '2026-04-17T08:40:00Z',
      6.0,
      51,
      'Padi',
      '2026-04-17T08:45:00Z',
      '2026-04-17T08:45:00Z',
      null
    ),
    (
      92000007,
      91000002,
      target_user_id,
      '2026-05-05T06:00:00Z',
      6.3,
      58,
      'Cabai',
      '2026-05-05T06:05:00Z',
      '2026-05-05T06:05:00Z',
      null
    )
  on conflict (id) do update
  set
    lahan_id = excluded.lahan_id,
    user_id = excluded.user_id,
    recorded_at = excluded.recorded_at,
    ph = excluded.ph,
    moisture = excluded.moisture,
    recommendation = excluded.recommendation,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at;
end;
$$;