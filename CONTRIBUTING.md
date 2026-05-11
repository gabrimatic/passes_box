# Contributing

PassesBox is a small security-focused app. Good contributions keep the vault local, the behavior predictable, and the platform support honest.

Open an issue first for larger changes, especially anything that touches encryption, backup formats, authentication, or storage.

## Dev Setup

```bash
git clone https://github.com/gabrimatic/passes_box.git
cd passes_box
flutter pub get
flutter run
```

## Architecture

```
lib/
├── main.dart
├── app.dart                     # App widget, theme, routes
├── core/
│   ├── index.dart               # Barrel export
│   ├── models/
│   │   └── password.dart        # PasswordModel
│   ├── navigation/
│   │   ├── get_pages.dart       # Route definitions
│   │   └── navigation.dart      # Navigation helpers
│   ├── values/
│   │   ├── colors.dart
│   │   ├── strings.dart
│   │   └── values.dart          # Shared preferences, constants
│   └── widgets/
│       └── widgets.dart         # Reusable widgets
├── repository/
│   ├── db.dart                  # Database + encryption layer
│   ├── db_factory_io.dart
│   └── db_factory_web.dart
└── src/
    ├── splash/
    │   └── view/page.dart       # Biometric auth gate
    ├── home/
    │   ├── controller/
    │   │   ├── controller.dart  # GetX controller, CRUD
    │   │   └── io.dart          # Backup / restore
    │   ├── dialogs/
    │   │   └── dialogs.dart     # Password entry, settings, delete
    │   └── view/
    │       └── page.dart
    └── about/
        └── page/about_page.dart
```

## Key Conventions

- State management: GetX
- Database: sembast with an AES-256-GCM encrypted codec
- Platform-conditional imports for IO vs Web database factories
- All database operations return Futures and must be awaited
- PasswordModel equality is by database key

## Checks

```bash
flutter analyze
flutter test
```

## Building

| Platform | Command |
| --- | --- |
| Android | `flutter build apk` |
| iOS | `flutter build ios --no-codesign` |
| macOS | `flutter build macos` |
| Web | `flutter build web` |

## Pull Request Checklist

- [ ] `flutter analyze` passes with no issues
- [ ] `flutter test` passes
- [ ] Tested on at least one target platform
- [ ] No hardcoded secrets or keys
- [ ] Commit message is one line, descriptive
- [ ] No unrelated changes included

## Reporting Issues

Use the [bug report template](https://github.com/gabrimatic/passes_box/issues/new?template=bug_report.yml). Include:

- Platform and OS version
- Flutter version (`flutter --version`)
- Steps to reproduce
- Expected vs actual behavior

## Vulnerability Reporting

See [SECURITY.md](SECURITY.md).
