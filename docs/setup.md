# Developer Setup Guide

This guide explains how to set up and run the Thiruppugazh application on your local development environment.

## Prerequisites

-   **Flutter SDK**: Ensure you have the latest stable version of Flutter installed.
    -   `flutter doctor` should verify your installation.
-   **Dart SDK**: Included with Flutter.
-   **Android Studio / Xcode**: For emulator/simulator management and platform-specific builds.
-   **VS Code** (Recommended): With Flutter and Dart extensions.

## Getting Started

1.  **Clone the Repository**
    ```bash
    git clone <repository-url>
    cd thiruppugazh
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the Application**
    -   **Android Emulator / Device**:
        ```bash
        flutter run
        ```
    -   **iOS Simulator / Device** (macOS only):
        ```bash
        open ios/Runner.xcworkspace
        # Or:
        flutter run -d <device-id>
        ```
    -   **Windows / Linux / macOS** (Desktop):
        ```bash
        flutter run -d windows
        flutter run -d linux
        flutter run -d macos
        ```

## Project Structure

-   `lib/`: Contains all Dart source code.
    -   `data/`: Database helper and repositories.
    -   `l10n/`: Localization files (ARB).
    -   `models/`: Data models.
    -   `providers/`: State management (ChangeNotifiers).
    -   `ui/`: UI components and screens.
    -   `utils/`: Helper utilities.
-   `assets/`: Images, fonts, and the pre-populated database (`thiruppugazh.db`).
-   `test/`: Unit and widget tests.
-   `scripts/build_db.py`: Rebuilds `assets/thiruppugazh.db` and `assets/english_data.json` from `songs/*.json`.
-   `web_app/`: Static fallback website for shared song links — see [`docs/web-app.md`](web-app.md). Separate from the app build; requires only Python (stdlib, no `pip install`), not Flutter.

## Troubleshooting

-   **Database Issues**: If you modify the schema or face issues, try uninstalling the app from the emulator/device to trigger a fresh database copy from assets.
-   **Localization**: After editing ARB files, run `flutter gen-l10n` to update `app_localizations.dart`.
