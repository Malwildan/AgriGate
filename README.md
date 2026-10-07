# AgriGate

Gateway to a Better Agricultural Ecosystems.

Note: The application works best when used with compatible supporting hardware.

## Local Setup

1. Edit `.env.json` with your Supabase project URL and anon key.
2. Apply the SQL in `supabase/migrations/202605050001_lahan_sync.sql` to your Supabase project.
3. Enable anonymous auth in Supabase Auth settings.
4. Launch the `AgriGate` VS Code configuration or run Flutter with `--dart-define-from-file=.env.json`.

If `.env.json` still contains placeholder values, the app stays in local-only mode and skips remote sync.

## iOS builds from Windows

After this setup is merged into `main`, clone the complete repository into a new Windows folder (the old partial `D:\agrigate` folder is not a Git checkout):

```powershell
git clone https://github.com/Malwildan/AgriGate.git D:\AgriGate-full
cd D:\AgriGate-full
```

Edit the app on Windows, then commit and push your changes. Push to the public GitHub repository's `main` branch, open a pull request, or run **iOS build** from the Actions tab. GitHub Actions uses a macOS runner with Flutter 3.35.7 to build two archives. Download them from the completed run's **Artifacts** section:

- `AgriGate-iphonesimulator` contains a debug `Runner.app` for an iOS simulator on a Mac.
- `AgriGate-iphoneos-unsigned` contains a release `Runner.app` for an iPhone, without code signing. It cannot be installed on a normal device or submitted to the App Store as delivered.

The workflow uses local-only mode and does not require Supabase credentials. The app's unused asset directory entries were removed from `pubspec.yaml` because those directories are absent from the repository. If you later add images or icons, declare their paths again.

To install on your own iPhone, set a unique bundle identifier in `ios/Runner.xcodeproj` and sign through Xcode with your Apple Account. App Store distribution requires Apple Developer Program membership (normally $99 USD per year), a distribution certificate, and a matching provisioning profile. Apple currently requires App Store uploads to use Xcode 26 or later and the iOS 26 SDK. Archive and upload a signed build with a qualifying Xcode version or a separate secured CI workflow. Keep signing certificates, private keys, provisioning profiles, and App Store Connect credentials out of the public repository. This workflow checks iOS compilation and does not publish an app.

## Sync Model

- Hive remains the immediate local source of truth for lahan and scan history.
- Local writes enqueue pending sync operations and succeed even while offline.
- Pull-to-refresh on the lahan list replays the queue to Supabase, pulls remote rows, and rewrites the local cache.
- Supabase uses anonymous auth, so synced data stays device-scoped until a real auth flow is introduced.
