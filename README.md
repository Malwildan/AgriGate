# AgriGate

Gateway to a Better Agricultural Ecosystems.

Note: The application works best when used with compatible supporting hardware.

## Local Setup

1. Edit `.env.json` with your Supabase project URL and anon key.
2. Apply the SQL in `supabase/migrations/202605050001_lahan_sync.sql` to your Supabase project.
3. Enable anonymous auth in Supabase Auth settings.
4. Launch the `AgriGate` VS Code configuration or run Flutter with `--dart-define-from-file=.env.json`.

If `.env.json` still contains placeholder values, the app stays in local-only mode and skips remote sync.

## Sync Model

- Hive remains the immediate local source of truth for lahan and scan history.
- Local writes enqueue pending sync operations and succeed even while offline.
- Pull-to-refresh on the lahan list replays the queue to Supabase, pulls remote rows, and rewrites the local cache.
- Supabase uses anonymous auth, so synced data stays device-scoped until a real auth flow is introduced.
