# Contributing

Contributions are welcome. Open an issue first for larger changes.

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
├── core/
│   ├── models/          # Data models (PasswordModel)
│   ├── navigation/      # App navigation helpers
│   ├── values/          # Shared preferences, constants
│   └── widgets/         # Reusable widgets
├── repository/
│   ├── db.dart          # Database + encryption layer
│   ├── db_factory_io.dart
│   └── db_factory_web.dart
├── src/
│   └── home/
│       ├── controller/  # GetX controller, backup/restore
│       ├── dialogs/     # Password add/edit dialogs
│       └── view/        # Home page UI
└── main.dart
```

## Key Conventions

- State management: GetX
- Database: sembast with AES-256 encrypted codec
- Platform-conditional imports for IO vs Web database factories
- All database operations return Futures and must be awaited
- PasswordModel equality is by database key

## Running Tests

```bash
flutter test
flutter analyze
```

## Building

| Platform | Command |
| --- | --- |
| Android | `flutter build apk` |
| iOS | `flutter build ios --no-codesign` |
| macOS | `flutter build macos` |
| Web | `flutter build web` |

## PR Checklist

- [ ] `flutter analyze` passes with no issues
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
