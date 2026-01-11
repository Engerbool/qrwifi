# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WiFi QR Poster Generator - A Flutter application that creates beautiful, printable WiFi QR code posters. Users input WiFi credentials, customize the poster design with templates, and export high-resolution images for printing.

## Development Commands

```bash
# Run the app
flutter run                    # Run on connected device/emulator
flutter run -d chrome          # Run on web (Chrome)
flutter run -d windows         # Run on Windows desktop

# Code quality
flutter analyze                # Static analysis with flutter_lints
dart format .                  # Format all Dart files

# Testing
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Run single test file

# Build
flutter build apk              # Android APK
flutter build web              # Web build
flutter build windows          # Windows desktop
```

## Architecture

### State Management Pattern
Uses `Provider` with `ChangeNotifier`. Three global providers initialized in `main.dart`:
- `ThemeProvider` - Dark/light mode
- `LocaleProvider` - English/Korean language
- `PosterProvider` - Central state for WiFi config, template selection, poster customization, and export

### Screen Flow
`SplashScreen` → `HomeScreen` → `EditorScreen` → `PreviewScreen`

Routes defined in `lib/config/routes.dart`.

### Platform-Specific Export
The export system uses conditional imports for cross-platform support:
- `export_service.dart` - Core service with platform detection
- `export_service_web.dart` - Web: Downloads via browser blob/anchor
- `export_service_mobile.dart` - Mobile: Saves to gallery with permission handling
- `export_service_stub.dart` - Fallback stub

The pattern: `import 'stub.dart' if (dart.library.html) 'web.dart' if (dart.library.io) 'mobile.dart'`

### Poster Rendering
`PosterCanvas` widget wraps content in `RepaintBoundary` for high-resolution capture. Two layout modes:
- A4 vertical layout (2480x3508px @ 300dpi)
- Business card horizontal layout (1063x591px)

Layout adapts automatically based on `PosterSize` selection.

### Template System
`PosterTemplate` in `lib/models/poster_template.dart` defines 22 templates across 5 categories (basic, warm, cool, nature, creative). Each template specifies:
- Background color/gradient
- Text color
- QR code foreground/background colors

### Localization
Simple key-value translation map in `lib/config/translations.dart`. Supports English (`en`) and Korean (`ko`). Access via `AppTranslations.get(key, languageCode)`.

### WiFi QR Format
`WifiConfig.toQrString()` generates standard WiFi QR format: `WIFI:T:<encryption>;S:<ssid>;P:<password>;H:<hidden>;;`

## Key Files

- `lib/providers/poster_provider.dart` - Central state container
- `lib/widgets/poster_canvas.dart` - Poster rendering with A4/business card layouts
- `lib/services/export_service.dart` - Cross-platform export orchestration
- `lib/config/constants.dart` - `PosterSize` definitions and encryption types
- `lib/models/poster_template.dart` - All template definitions

## Firebase Status

Firebase is configured in `pubspec.yaml` but initialization is **commented out** in `main.dart`. Run `flutterfire configure` before enabling auth features.
