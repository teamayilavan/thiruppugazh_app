# Fixing "App must target Android 16 (API level 36)" — Play Console Warning

**Status:** Not yet fixed — this is a planning document only. No code has been changed.
**Date written:** 2026-08-09
**Deadline from Google:** Aug 31, 2026 (after this date you cannot publish ANY update — including bug fixes — until the app targets API 36). A one-time extension to Nov 1, 2026 can be requested from within Play Console if needed.

---

## 1. What the warning actually means

Google Play requires every app to target an Android API level within one year of the latest Android release. Android 16 (API level 36) is now the current release, so Play Console is warning that this app's target API level (35, i.e. Android 15) will fall out of the compliance window on Aug 31, 2026.

Two different things are easy to conflate — keep them separate:

| Term | What it controls | Where it lives in this project |
|---|---|---|
| `minSdk` | Oldest Android version the app can install on | `android/app/build.gradle.kts` → `flutter.minSdkVersion` (Flutter default) |
| `compileSdk` | Which Android SDK version the app is *compiled against* (which APIs are available to the compiler) | `android/app/build.gradle.kts` → `flutter.compileSdkVersion` |
| `targetSdk` | Which Android version's *behavior/runtime rules* the app opts into (this is what Play Console checks) | `android/app/build.gradle.kts` → `flutter.targetSdkVersion` |

We only need to raise `compileSdk` and `targetSdk` to 36. `minSdk` (currently Flutter's default, 21) does not need to change and should stay low so the app keeps supporting older phones.

---

## 2. Root cause in this specific project

This app does **not** hardcode SDK versions. In `android/app/build.gradle.kts`:

```kotlin
android {
    compileSdk = flutter.compileSdkVersion
    defaultConfig {
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        ...
```

These three values are **inherited from the installed Flutter SDK itself**, not set as numbers in this repo. Every Flutter release ships a hardcoded default in its own gradle plugin code (`FlutterExtension.kt`).

I checked the Flutter SDK currently installed on this machine (`D:\Software\Flutter\flutter`, **Flutter 3.32.8**, from July 2025) and confirmed its built-in defaults are:

```
compileSdkVersion = 35
targetSdkVersion  = 35
```

That's exactly the "Android 15 (API level 35)" Play Console flagged. So the underlying cause isn't a misconfiguration in the app — it's that the Flutter SDK on the build machine predates Android 16 and hasn't been upgraded since July 2025.

Also relevant to this project's Android build:
- Android Gradle Plugin (AGP): **8.7.3** (`android/settings.gradle.kts`)
- Gradle: **8.12** (`android/gradle/wrapper/gradle-wrapper.properties`)
- Kotlin: **2.1.0**
- NDK: **27.0.12077973** (pinned explicitly in `build.gradle.kts`)

Targeting SDK 36 requires **AGP 8.9.1+ and Gradle 8.11.1+** at minimum. Gradle 8.12 already satisfies that, but **AGP 8.7.3 does not** and will need to be bumped.

---

## 3. Fix options

### Option A — Upgrade the Flutter SDK (recommended)

Since this project already delegates to `flutter.compileSdkVersion` / `flutter.targetSdkVersion` rather than hardcoding numbers, the cleanest fix is to upgrade the Flutter SDK itself to a version whose default is 36. This is also the officially recommended approach — Flutter's own docs say to always build against the latest stable Flutter release, and doing so means future Android API bumps largely take care of themselves the same way.

As of writing, the latest stable Flutter release is **3.44.0** (released 2026-05-18), which defaults to `compileSdk`/`targetSdk` 36.

Pros:
- No manual SDK version numbers to maintain/forget in `build.gradle.kts`.
- Also picks up Dart/Flutter framework fixes, performance improvements, and keeps `flutter_lints`/plugin compatibility current.
- Matches how the project is already structured (relying on Flutter's defaults).

Cons:
- A `flutter upgrade` is a bigger jump (3.32.8 → 3.44.0, roughly a year of Flutter releases) and has some chance of surfacing breaking changes in dependencies or generated code that need a compatibility pass.
- Requires bumping AGP regardless (see step below), since AGP 8.7.3 is below the 8.9.1 floor for SDK 36.

### Option B — Override the SDK versions manually, keep current Flutter version

Instead of upgrading Flutter, hardcode the values in `android/app/build.gradle.kts`:

```kotlin
android {
    compileSdk = 36
    defaultConfig {
        targetSdk = 36
        ...
```

Pros:
- Smaller, more contained change; avoids touching Flutter/Dart SDK or dependency versions.

Cons:
- Still requires bumping AGP to ≥8.9.1 (compileSdk 36 needs a new-enough AGP regardless of how the number gets there).
- Working against an old Flutter SDK (3.32.8) with a newer target SDK is a combination the Flutter team doesn't primarily test against; there have been real reports (Flutter issue #174516) of specific Flutter versions silently ignoring manual SDK overrides, so this path needs a clean build verification (see Section 5) to be sure the override actually took effect.
- You lose the various other engine/tooling improvements that came out since July 2025, without saving much effort — you still have to touch Gradle files either way.

**Recommendation: Option A.** Given this project intentionally uses `flutter.compileSdkVersion`/`flutter.targetSdkVersion` rather than pinned numbers, upgrading Flutter keeps that design intact and is the path Flutter/Google both point developers toward. Reserve Option B only if `flutter upgrade` turns out to be blocked by a dependency that hasn't caught up yet.

---

## 4. Step-by-step fix (Option A)

All commands are run from the repo root (`D:\Ayilavan_Projects\Mobile_Apps\thiruppugazh`) in PowerShell unless noted.

1. **Create a branch** for this change (don't do it on `main`):
   ```
   git checkout -b chore/target-sdk-36
   ```

2. **Check what's currently outdated** (informational, doesn't change anything):
   ```
   flutter --version
   flutter pub outdated
   ```

3. **Upgrade the Flutter SDK itself** (this changes the SDK at `D:\Software\Flutter\flutter`, i.e. shared tooling, not files inside this repo):
   ```
   flutter upgrade
   flutter --version
   ```
   Confirm the reported version is 3.35+ (any version whose Flutter release notes mention Android API 36 support — 3.44.0 is current as of this writing).

4. **Bump the Android Gradle Plugin** in `android/settings.gradle.kts`. Change:
   ```kotlin
   id("com.android.application") version "8.7.3" apply false
   ```
   to at least `8.9.1` (check the [AGP release notes](https://developer.android.com/build/releases/gradle-plugin) for the current stable version and use that instead if newer — no reason to pick the floor if a newer stable AGP exists).

5. **Check the Gradle wrapper version** in `android/gradle/wrapper/gradle-wrapper.properties`. It's currently `8.12`, which already satisfies the ≥8.11.1 requirement, so no change needed there — but if you bump AGP to something newer than 8.9.1, cross-check [AGP's Gradle compatibility table](https://developer.android.com/build/releases/gradle-plugin#updating-gradle) to make sure 8.12 is still compatible with whatever AGP version you land on; bump the wrapper if not.

6. **Check the Kotlin Gradle plugin** version (`org.jetbrains.kotlin.android` = `2.1.0`). Not required for the API 36 fix specifically, but while touching these files it's worth confirming it's still compatible with the new AGP/Gradle combo — the AGP release notes list the minimum supported Kotlin version.

7. **Do NOT touch `minSdk`.** Leave `flutter.minSdkVersion` as-is; there's no requirement to raise it, and doing so would drop support for older devices unnecessarily.

8. **Clean and rebuild** to force Gradle to pick up the new toolchain (important — stale Gradle caches have been known to keep using old SDK versions silently):
   ```
   flutter clean
   flutter pub get
   ```

9. **Verify the actual compiled SDK version** — don't just trust that the upgrade "should" have worked, confirm it (see Section 5 below).

10. **Full regression pass**, since this touches the entire native build toolchain, not just a version number:
    - `flutter analyze`
    - `flutter test`
    - Build and run the app on a real device or emulator; click through the app's main flows (song list, search, lyrics language toggle, sharing, deep links via `app_links`) since native plugin behavior can shift with AGP/SDK bumps.
    - Pay particular attention to any permission dialogs, file picker (`file_picker`), and share sheet (`share_plus`) behavior — Android 16 tightens some runtime behaviors here.

11. **Commit** the changes (expect diffs in `android/settings.gradle.kts`, possibly `android/gradle/wrapper/gradle-wrapper.properties`, and Flutter's own version-lock files like `.metadata` / `pubspec.lock` if any dependency versions shifted during `flutter upgrade`).

---

## 5. How to verify the fix actually worked (before publishing)

Don't rely on Play Console's own confirmation email as your first signal — verify locally first:

1. **Inspect the built AAB/APK's manifest directly.** After building (`flutter build appbundle` or `flutter build apk`), the effective `targetSdkVersion` is baked into the merged manifest at:
   ```
   build\app\intermediates\merged_manifest\release\AndroidManifest.xml
   ```
   Open it and confirm `android:targetSdkVersion="36"` (or check `uses-sdk` element).

2. **Or ask Gradle directly:**
   ```
   cd android
   .\gradlew.bat :app:dependencies --configuration releaseRuntimeClasspath
   ```
   or more directly, print the resolved config:
   ```
   .\gradlew.bat -q properties | Select-String -Pattern "compileSdk|targetSdk"
   ```
   (If that doesn't surface it — Flutter's plugin computes these outside standard Gradle properties — the manifest check in step 1 is the reliable source of truth.)

3. **Bundletool inspection (most authoritative for what Play will actually see):** if you have `bundletool` installed, run
   ```
   java -jar bundletool.jar dump manifest --bundle=app-release.aab
   ```
   and confirm the `targetSdkVersion` line.

---

## 6. Publishing to production

Once the local build confirms `targetSdk = 36` and the regression pass in step 10 is clean:

1. **Bump the app version.** In `pubspec.yaml`, the current version is `1.2.0+3`. Since this is a toolchain/compliance change with no user-facing feature, a build-number-only bump is appropriate, e.g. `1.2.0+4` (or `1.2.1+4` if you prefer to signal it as a patch release — either is defensible; just be consistent with how this project has versioned similar maintenance releases before).

2. **Build the release App Bundle** (Play requires `.aab`, not `.apk`, for production uploads):
   ```
   flutter build appbundle --release
   ```
   This uses the `key.properties` / signing config already wired up in `android/app/build.gradle.kts`. Confirm `android/key.properties` exists and is populated locally (it's git-ignored, so this is a per-machine file, not something to check into the repo).

3. **Test before production — don't skip straight to a production release.** Google explicitly calls this out in the warning message too ("Before you do this, you can test your app using internal, closed, or open testing"). Recommended order:
   - **Internal testing track** first — upload the `.aab` to the Internal testing track in Play Console, install on a couple of real devices (ideally one running Android 16 if available, to catch any edge-to-edge/behavior-change regressions specific to targeting API 36), sanity-check the app.
   - **(Optional) Closed testing** with a small group if you want a wider check before going live.
   - **Production** once internal testing looks clean.

4. **Upload to Play Console:**
   - Go to **Play Console → your app → Testing → Internal testing** (or **Production**, once ready) → **Create new release**.
   - Upload the `.aab` from `build/app/outputs/bundle/release/app-release.aab`.
   - Play Console will auto-run **Pre-launch report** checks — wait for these before promoting to production; they'll flag crashes/ANRs on real device farm hardware, which is a good independent check on the SDK bump.
   - Fill in release notes (even brief internal ones for a compliance-only release, e.g. "Maintenance update: target Android 16 (API level 36) per Play Store requirement.").
   - Submit for review.

5. **Promote internal → production** (Play Console → the release → "Promote release" → select Production) once you're satisfied with testing. Google typically reviews production submissions within a few hours to a couple of days.

6. **Confirmation from Google.** Per the original notification: once the update is live, Play Console will send a notification confirming the app is no longer flagged as non-compliant. This can take some time after the release goes live (not always instant) — don't be alarmed if it's not immediate.

---

## 7. Quick checklist

- [ ] `git checkout -b chore/target-sdk-36`
- [ ] `flutter upgrade` → confirm version ≥3.35 (or whichever version defaults to API 36)
- [ ] Bump AGP in `android/settings.gradle.kts` to ≥8.9.1
- [ ] Confirm Gradle wrapper ≥8.11.1 (currently 8.12 — likely fine)
- [ ] `flutter clean && flutter pub get`
- [ ] `flutter build appbundle --release`
- [ ] Confirm `targetSdkVersion="36"` in merged manifest
- [ ] `flutter analyze` / `flutter test` clean
- [ ] Manual regression pass on a device (deep links, sharing, file picker, lyrics language toggle, edge-to-edge UI)
- [ ] Bump `pubspec.yaml` version (e.g. `1.2.0+4`)
- [ ] Upload to **Internal testing**, verify on-device
- [ ] Promote to **Production**
- [ ] Wait for Play Console's compliance-resolved notification

---

## 8. Sources

- [Target API level requirements for Google Play apps — Play Console Help](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en)
- [Android Gradle Plugin release notes / Gradle compatibility table](https://developer.android.com/build/releases/gradle-plugin)
- Flutter SDK source inspected directly: `packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt` (confirms Flutter 3.32.8 defaults to compileSdk/targetSdk 35)
- [flutter/flutter issue #174516](https://github.com/flutter/flutter/issues/174516) — notes on some Flutter versions not honoring manual SDK overrides, hence the verification step in Section 5
