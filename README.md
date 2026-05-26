# AgriGate

Gateway to a Better Agricultural Ecosystems.

Note: The application works best when used with compatible supporting hardware.

## Local Setup

1. Copy `.env.example.json` to `.env.json` and fill in your values.
2. Apply the SQL in `supabase/migrations/202605050001_lahan_sync.sql` to your Supabase project.
3. Enable **Email OTP** auth in Supabase Auth settings (disable anonymous sign-in for production).
4. Launch the `AgriGate` VS Code configuration or run:

```bash
flutter run --dart-define-from-file=.env.json
```

### Environment variables (`.env.json`)

| Key | Required | Description |
|-----|----------|-------------|
| `SUPABASE_URL` | For sync | Supabase project URL |
| `SUPABASE_ANON_KEY` | For sync | Supabase anon key |
| `RAILWAY_API_URL` | For recommendations | Crop recommendation API base URL |
| `ENABLE_DEMO_SEED` | No | Set `"true"` in **debug** builds only to seed demo lahan when Supabase is not configured |

If Supabase is not configured, the app runs in **local-only** mode (no cloud sync, no sign-in).

Demo seed data is **never** inserted in release/profile builds.

## Sync Model

- Hive remains the immediate local source of truth for lahan and scan history.
- Local writes enqueue pending sync operations and succeed even while offline.
- Pull-to-refresh on the lahan list replays the queue to Supabase, pulls remote rows, and rewrites the local cache.
- Supabase uses **email OTP** sign-in; synced data is scoped per authenticated user.

## BLE Sensor Payload

Hardware should send UTF-8 text over the sensor characteristic, for example:

- Legacy: `PH:6.5` (moisture defaults to 0; API may supply soil moisture from GPS)
- Full: `PH:6.5;MOISTURE:45`

## Release checklist (Android)

1. Set production `.env.json` (no placeholders, `ENABLE_DEMO_SEED=false`).
2. Configure Play App Signing and `android/key.properties` (not committed).
3. Bump `version` in `pubspec.yaml`.
4. Build: `flutter build appbundle --dart-define-from-file=.env.json --release`
5. Run `melos run test` and verify CI is green on `main`.
6. Smoke-test: sign-in, scan, save, sync, delete lahan.
7. Rollback: ship previous Play Console release if needed.

## Observability

`AppLogger` in `agri_core` writes structured debug logs. Wire Sentry or Firebase Crashlytics at the `AppLogger.e` call sites before large-scale rollout.
