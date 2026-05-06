# Plan: Supabase Lahan Sync

Recommended approach: add Supabase as an offline-first backend for lahan and scan history without pushing backend logic into the feature BLoCs. Keep Hive as the immediate local source of truth, use anonymous Supabase auth behind the scenes, add a queued sync layer in agri_core, and make refresh explicitly sync before reloading local data.

## Steps

1. Foundation. Add Supabase dependencies at the app layer and in `packages/agri_core/pubspec.yaml`, introduce a small runtime config surface using dart-defines for the Supabase URL and anon key, initialize Supabase in `lib/main.dart`, and register the Supabase client plus backend session/bootstrap services in `lib/app/di/injection.dart`. This blocks everything else.
2. Backend contract. Create the Supabase project, enable anonymous auth, and add the first schema for `lahan` and `scan_records`. Keep the current client-generated integer IDs as remote bigint primary keys so existing use cases do not need ID remapping. Add `user_id`, `created_at`, `updated_at`, and deletion markers where needed, then secure rows with RLS using `auth.uid()`.
3. Domain and model hardening. Replace the display-only scan date in `packages/agri_core/lib/src/domain/entities/entities.dart` with a canonical timestamp so sorting and sync are reliable. Remove or gate the current demo seeding in `packages/agri_core/lib/src/data/repositories/hive_lahan_repository.dart` so Supabase-enabled builds do not upload sample data. Add remote DTOs, JSON mapping, and auth/network/sync failures in `packages/agri_core/lib/src/domain/failures/failures.dart`.
4. Offline-first sync layer. Keep Hive as the read/write local store, but add a pending-operation queue in agri_core so add, update, and save-scan operations succeed locally first and then enqueue remote sync work. Implement composite repositories behind `packages/agri_core/lib/src/domain/repositories/repositories.dart` that replay queued operations to Supabase, pull remote rows, merge by id and timestamp, and rewrite the local cache.
5. Feature wiring. Keep feature packages backend-agnostic. Update `packages/feature_lahan_list/lib/src/presentation/bloc/lahan_list_bloc.dart` so refresh performs sync plus reload instead of just re-reading Hive. Keep `packages/feature_result/lib/src/presentation/bloc/result_bloc.dart` and `packages/feature_lahan_detail/lib/src/presentation/bloc/detail_bloc.dart` on use cases only. Move scan-date formatting into the detail widgets, mainly `packages/feature_lahan_detail/lib/src/presentation/widgets/scan_history_timeline.dart` and the latest-scan display in `packages/feature_lahan_detail/lib/src/presentation/widgets/detail_hero_card.dart`.
6. Verification. Add repository tests in agri_core, because there are currently no agri_core tests. Add feature tests for lahan refresh and result save flows. Finish with `melos analyze`, `melos test`, and a manual offline-to-online smoke test that covers local writes, app restart, reconnect, refresh, and Supabase row verification.

## Key Notes

- In scope: anonymous auth without a login UI, lahan plus scan-history sync, offline-first local writes, refresh-driven pull sync, and Supabase RLS setup.
- Out of scope for phase 1: user-facing login, cross-device account linking, storage, realtime subscriptions, weather migration, and CI/CD work.
- Important constraint: anonymous auth is device-scoped. If you later want the same data across reinstalls or multiple devices, that next phase should add real auth instead of changing the repository model again.
- Recommendation: use dart-defines for Supabase config instead of treating bundled env files as a security boundary in Flutter.

## Relevant Files

- `lib/main.dart`
- `lib/app/di/injection.dart`
- `pubspec.yaml`
- `packages/agri_core/pubspec.yaml`
- `packages/agri_core/lib/agri_core.dart`
- `packages/agri_core/lib/src/domain/entities/entities.dart`
- `packages/agri_core/lib/src/domain/failures/failures.dart`
- `packages/agri_core/lib/src/domain/repositories/repositories.dart`
- `packages/agri_core/lib/src/domain/usecases/usecases.dart`
- `packages/agri_core/lib/src/data/repositories/hive_lahan_repository.dart`
- `packages/feature_lahan_list/lib/src/presentation/bloc/lahan_list_bloc.dart`
- `packages/feature_result/lib/src/presentation/bloc/result_bloc.dart`
- `packages/feature_lahan_detail/lib/src/presentation/widgets/scan_history_timeline.dart`
- `packages/feature_lahan_detail/lib/src/presentation/widgets/detail_hero_card.dart`

## Verification Checklist

1. Add repository-layer tests in agri_core.
2. Add feature tests for lahan refresh and result save.
3. Run `melos exec -- flutter pub get`, `melos analyze`, and `melos test`.
4. Run a manual offline and online sync smoke test.
