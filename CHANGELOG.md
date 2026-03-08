# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.0] - 2026-03-08

### Changed

- Encryption architecture: random per-device AES-256 key stored in platform secure storage (replaces hardcoded key)
- Random IV generated per encryption operation (replaces static IV)
- Password generator uses `Random.secure()` for cryptographically secure output
- Backup/restore uses per-device encryption key with random IV
- Restore operation is now atomic: parses before clearing existing data
- Android target/compile SDK upgraded to 36
- Android Gradle Plugin upgraded to 8.9.1, Gradle to 8.12
- Web bootstrap modernized to `flutter_bootstrap.js` (replaces deprecated service worker pattern)
- macOS entitlements cleaned up: added `network.client`, removed unnecessary `keychain-access-groups`
- iOS Info.plist: disabled file sharing and document browsing for security
- HomeController database operations are now properly awaited
- PasswordModel uses database key equality for correct list operations

### Removed

- Hardcoded encryption key (`kKey` in values.dart)
- Dead code: commented-out navigation functions, duplicate `deleteAll()`
- Deprecated Android manifest attributes (`requestLegacyExternalStorage`, `SplashScreenDrawable`)
- Useless Container wrapper in web layout

### Fixed

- `File.fromRawPath` bug in restore (was passing file content as path)
- Force-unwraps on nullable PasswordModel fields replaced with null-safe defaults
- `HomeController.to` changed from `static final` to getter (was evaluated too early)
- `indexWhere` guarded against -1 return value
- Android `android:exported` added for Android 12+ compatibility
- Android `allowBackup` set to false (security requirement for password manager)

---

## [1.0.0] - 2022

### Added

- Initial release
- AES encrypted sembast database
- Biometric authentication
- Password generator
- Backup and restore (.pbb format)
- Android, iOS, Web, and Windows support
