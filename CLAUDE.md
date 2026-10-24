# Thiruppugazh app: working agreements

## Make intentional changes only

Before editing, creating, or deleting code (`lib/`, `test/`, `assets/`, `android/`,
`scripts/`, `pubspec.yaml`, DB schema or migrations):

1. Say what you will change: behavior, files, and any schema, dependency, or
   backup-format impact.
2. Wait for the owner's go-ahead. A clear, specific instruction is a go-ahead; a go-ahead
   covers only the plan described, so confirm again if the scope grows.

Reading, searching, and discussing options need no confirmation. If testing shows a bug in
code you just wrote, fix it and say so. Anything else, ask.

Commit or push only when asked. Prefer small, logical commits.

## Branches and releases

- `main` is stable and always equals what is on the store.
- New work goes to `next`: build, publish, let it soak, then merge `next` into `main` and
  tag `vX.Y.Z`.
- `v2-features` is a parked tangent. Cherry-pick ideas from it one at a time onto `next`;
  never merge it.
- Bump the version in `pubspec.yaml` only when preparing a release.

## User data is sacred

An update must never lose a user's favorites, categories, notes, highlights, links, or settings.

- Schema changes are additive. Migrations are idempotent and non-fatal, and
  `AppConstants.dbVersion` is bumped with a `migrateToVN` in `database_helper.dart`
  (also create the table in `onCreate`). Never drop, rewrite, or rename user tables.
- Test upgrades from every earlier DB version (v1 to latest) with user data present,
  using the real bundled DBs from git history; compare all user tables before and after.
- New user-owned data goes into backup export and import (`backup_service.dart`) and
  stays covered by Auto Backup. The backup `version` stays 1 for additive keys, and
  old backups must still import without duplicating.
- New preference keys only. Do not rename or reuse existing ones.
- Update `docs/database.md` for every schema change.

## Build and verify

- Before saying "done": `flutter analyze` (only the known deprecation infos may remain)
  and `flutter test` must pass. Add tests with the change.
- For UI or native (Kotlin/manifest) changes, also build a debug APK and check it on the
  emulator. State plainly what was and was not verified.
- Keep `CHANGELOG.md` (`[Unreleased]`) current.
- Flutter commands touch `macos/Flutter/GeneratedPluginRegistrant.swift` and
  `windows/flutter/generated_plugins.cmake`. Revert them (`git checkout --`) before committing.

## Conventions

- **Strings:** every user-visible string goes in both `app_en.arb` and `app_ta.arb`, then
  `flutter gen-l10n`. No hard-coded text.
- **Theme:** define colors in `app_theme.dart` (light and dark). Do not rely on Material
  defaults; unset secondary colors render as teal.
- **External links:** open only http(s), and always confirm first, naming the site.
- **Providers:** never `notifyListeners()` during a build. Defer to the end of the frame.
- **Offline first:** no network features, no tracking, no accounts.
- **Verses:** group lyric lines with `splitIntoVerses` (`lib/utils/verses.dart`), the same
  rule the song page uses.

## Product principles

- Help devotees study and remember the songs. Quality of experience over growth.
- No points, streaks, or leaderboards. Features are opt-in and quiet.
- Respect the user's flow. Do not pull them out of what they were doing (a shared link
  returns them to the app they came from).
- Small, balanced, readable UI. Tamil text wraps, so test layouts in Tamil.

## Local tooling notes (Windows)

- `adb` and the emulator are under `%LOCALAPPDATA%\Android\Sdk`, not on PATH. AVD:
  `Medium_Phone_API_36`. Launch the emulator detached (PowerShell `Start-Process`); if it
  hangs on first boot, kill it and start again.
- In Git Bash use `MSYS_NO_PATHCONV=1` for device paths. In Python, print Tamil with
  `sys.stdout.reconfigure(encoding="utf-8")`.
- Contact email is `teamayilavan@gmail.com`.
