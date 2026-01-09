# Project: qrwifi

## Overview
**qrwifi** is a Flutter application designed to generate beautiful, printable WiFi QR code posters. Users can input their WiFi credentials (SSID, Password), generate a scannable QR code, and customize the poster's visual design for printing or sharing.

## Tech Stack
- **Framework:** Flutter (Dart SDK ^3.8.1)
- **State Management:** `provider` (^6.1.2)
- **Authentication:** Firebase Auth, Google Sign-In
- **Key Dependencies:**
  - `qr_flutter`: For generating QR codes.
  - `image_gallery_saver`, `path_provider`: For saving generated posters.
  - `permission_handler`: For managing device permissions.
  - `google_fonts`: For typography.
  - `flutter_animate`, `shimmer`: For UI animations.

## Project Structure (`lib/`)
The project follows a standard feature-layer architecture:

- **`config/`**: App-wide configuration (themes, constants, routes).
- **`models/`**: Data classes defining the domain objects.
- **`providers/`**: State management classes extending `ChangeNotifier` (e.g., `AuthProvider`, `PosterProvider`).
- **`screens/`**: Full-page widgets representing different views of the app.
- **`services/`**: Logic for external interactions (API calls, Firebase, Local Storage).
- **`widgets/`**: Reusable UI components.
- **`app.dart`**: The root `MaterialApp` widget.
- **`main.dart`**: The application entry point. Sets up `MultiProvider` and initializes the app.

## Development Workflow

### Prerequisites
- Flutter SDK installed.
- Android Studio / Xcode for native platform build tools.

### Common Commands
- **Run App:**
  ```bash
  flutter run
  ```
- **Run Tests:**
  ```bash
  flutter test
  ```
- **Analyze Code:**
  ```bash
  flutter analyze
  ```
- **Format Code:**
  ```bash
  dart format .
  ```

### Firebase Setup
The project relies on Firebase, but initialization is currently commented out in `lib/main.dart`:
```dart
// TODO: Initialize Firebase after running flutterfire configure
// await Firebase.initializeApp(...)
```
Ensure `flutterfire configure` is run and the initialization code is uncommented before working on Auth features.

## Coding Conventions
- **Linter:** Strictly follows `flutter_lints` rules.
- **State Management:** Use `Provider` for accessing and modifying state. Avoid `setState` for complex state.
- **UI:** Break down complex screens into smaller widgets in `widgets/`.
- **Async:** Use `async`/`await` properly; handle errors in Services or Providers, not just UI.
