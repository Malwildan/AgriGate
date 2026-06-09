# AGENTS.md

## Cursor Cloud specific instructions

### Product overview

AgriGate is a **Flutter monorepo** (Melos workspace) for an Android-first soil-analysis app. The root app is `agri_gate_app`; shared logic lives under `packages/`. There is **no backend in this repo** — Supabase and a Railway-hosted crop API are external.

### Flutter SDK version (important)

Use **Flutter 3.35.6** (Dart 3.9.x). The committed `pubspec.lock` files target `flutter: ">=3.35.6"`. **Flutter 3.44+ / Dart 3.12+ fails `pub get`** due to a `hive_generator` + `bloc_test` solver conflict.

The SDK is installed at `$HOME/flutter` and pinned with:

```bash
cd "$HOME/flutter" && git fetch --tags origin 3.35.6 && git checkout 3.35.6
```

Ensure `PATH` includes `$HOME/flutter/bin` (and `$HOME/.pub-cache/bin` if using global Melos).

### System packages (one-time VM setup)

Linux desktop builds need GTK/ninja toolchain packages plus a C++ linker that can find `libstdc++`. Web/Chrome builds do not.

```bash
sudo apt-get install -y ninja-build libgtk-3-dev libblkid-dev liblzma-dev \
  clang cmake pkg-config libsecret-1-dev libjsoncpp-dev mesa-utils \
  g++ build-essential libstdc++-13-dev
```

If `flutter build linux` fails with `cannot find -lstdc++`, set:

```bash
export LIBRARY_PATH="/usr/lib/gcc/x86_64-linux-gnu/13:${LIBRARY_PATH:-}"
```

If the build fails with `'type_traits' file not found` under clang, prefer **web** (`flutter run -d chrome`) or set `CC=gcc` / `CXX=g++` before building.

### Dependencies

`melos.yaml` exists but **Melos 7+ requires migrating config into root `pubspec.yaml`**. Until that migration lands, install deps manually:

```bash
test -f .env.json || cp .env.example.json .env.json
mkdir -p assets/images assets/icons
flutter pub get
for d in packages/*; do [ -f "$d/pubspec.yaml" ] && (cd "$d" && flutter pub get); done
```

`.env.json` is gitignored. Placeholder Supabase values keep the app in **local-only mode** with demo Hive seed data.

### Common commands

| Task | Command |
|------|---------|
| Analyze all packages | `dart analyze` at repo root, then in each `packages/*` |
| Test all packages | `flutter test` in root and each package with a `test/` dir |
| Run app (VS Code) | Launch config **AgriGate** (`--dart-define-from-file=.env.json`) |
| Run on Chrome | `flutter run -d chrome --dart-define-from-file=.env.json` |
| Run on Linux desktop | `flutter run -d linux --dart-define-from-file=.env.json` |
| Build web | `flutter build web --dart-define-from-file=.env.json` |
| Serve built web | `python3 -m http.server 8080 --directory build/web` |

Equivalent Melos scripts (`melos run analyze`, `melos run test`) work only after Melos workspace migration.

### Services and E2E expectations

| Service | Required? | Notes |
|---------|-----------|-------|
| Flutter app | Yes | Primary deliverable |
| Hive (embedded) | Yes | In-process; seeds demo lahan when empty |
| Supabase | Optional | Real URL/key in `.env.json` + SQL migrations in `supabase/migrations/` |
| Railway crop API | Optional for UI browse | Needed for live recommendations |
| BLE soil sensor | Optional in cloud | Physical hardware; web shows connection UI only |
| GPS | Optional in cloud | Emulator/device for real coordinates |

**Cloud VM smoke test:** build web, serve `build/web`, open in Chrome, confirm dashboard + lahan list + detail + scan screen (local-only demo data).

### Gotchas

- Empty `assets/images/` and `assets/icons/` directories must exist or `flutter test` / builds warn about missing asset dirs.
- `build_runner` output for Hive (`lahan_model.g.dart`) is already committed; rerun `dart run build_runner build --delete-conflicting-outputs` in `packages/agri_core` only after model changes.
- Primary target is **Android**; Linux/web are useful for headless CI and cloud demos but lack full BLE/GPS behavior.
