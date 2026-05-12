# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [2.3.0] - 2026-05-12

### Added

- Vault health summary on the home screen for weak, reused, and old passwords.
- Shared credential policy for title, URL, TOTP, export passphrase, and vault audit checks.
- Tested CSV import parser for common Chrome, Bitwarden, 1Password, and generic column names.
- Focused tests now cover credential policy, CSV import, password generation, search, and password dialog flows.

### Changed

- Saving a credential no longer copies its password automatically. Copying secrets is now explicit.
- Password generation now guarantees every selected character class appears in the generated password.
- Credential entry now hides passwords by default and validates URL and TOTP fields before saving.
- Restore flows now ask before replacing the current vault.
- CSV import now normalizes safe URLs, TOTP secrets, and imported categories.
- Android backup/import no longer requests broad external storage permissions.
- Web builds now use packaged CanvasKit assets and remove the loading screen after the first Flutter frame.
- The app now shows a vault recovery screen instead of hanging when a local vault uses an incompatible encryption format.
- Home, cards, search, health, TOTP, empty, splash, and recovery surfaces now use a quieter password-manager UI palette.
- Release builds now run `flutter analyze` and `flutter test` before packaging Android, Web, macOS, or Windows artifacts.
- CI actions now use current GitHub runner-compatible versions.

### Fixed

- Clipboard auto-clear now covers password-card copies, password history copies, and TOTP code copies.
- In-app version label now matches the `2.3.0` release.
- Editing a password now records the previous password in password history again.
- Password age warnings now use the last password update time instead of only the entry creation time.

## [2.2.0] - 2026-04-30

### Changed

- Encryption upgraded from AES-256-CBC without authentication to AES-256-GCM throughout. Every ciphertext now carries a 16-byte authentication tag, so tampered or corrupted data is rejected before decryption.
- Database codec signature updated to `passes_box_gcm`. Existing databases are incompatible and must be re-imported.
- Device backup format (`.pbb`): nonce reduced from 16 to 12 bytes for GCM; authentication tag appended. Old `.pbb` files are not compatible.
- Portable backup format (`.pbbx`): key derivation changed from PBKDF2-SHA256 (100k iterations) to Argon2id (m=4096 KiB, t=3, p=1). Version byte removed. Old `.pbbx` files are not compatible.
- QR export format (`pbbentry2:`): key derivation changed from PBKDF2-SHA256 (10k iterations) to Argon2id. Old `pbbentry:` QR codes are not scannable by this version.

---

## [2.1.0] - 2026-03-08

### Added
- Password search with real-time filtering by title, username, and URL
- Sort options: newest, oldest, A–Z, Z–A
- Category filter chips on the home screen
- Notes field on every credential entry
- URL field with one-tap launch from the card
- Password strength indicator in the entry dialog
- Configurable password generator: length slider, charset toggles (uppercase, lowercase, digits, symbols, no-ambiguous), passphrase mode with word count and separator
- Duplicate password detection with confirmation prompt
- TOTP / 2FA support: store a TOTP secret, generate live codes with a countdown ring, and scan QR codes to populate the secret
- Recycle bin: deleted entries are soft-deleted and auto-purged after 30 days
- Password history: last 5 passwords per entry, accessible from the card
- Portability-safe backup (.pbbx): AES-256-CBC encrypted with a user passphrase via PBKDF2, restorable on any device
- CSV import: auto-detects columns, supports Bitwarden, 1Password, Chrome, and generic formats
- HIBP breach check (opt-in): checks passwords against the Have I Been Pwned database using k-anonymity
- QR code export/import: encrypt a single entry with a passphrase and share via QR
- Clipboard auto-clear: copied passwords are cleared after 30 seconds
- Auto-lock: app locks after 5 minutes of inactivity on mobile
- Failed authentication limit: 3 failed biometric attempts trigger a 30-second lockout with countdown
- Screenshot prevention: Android FLAG_SECURE blocks screenshots and task-switcher previews; iOS shows a privacy overlay
- Haptic feedback on copy actions
- Password age warnings: yellow at 90 days, red at 180 days

---

## [2.0.0] - 2026-03-08

### Changed

- Encryption architecture: random per-device AES-256 key stored in platform secure storage (replaces hardcoded key)
- Random IV generated per encryption operation (replaces static IV)
- Password generator uses `Random.secure()` for cryptographically secure output
- Backup/restore uses per-device encryption key with random IV
- Restore operation is now atomic: parses before clearing existing data
- Android target/compile SDK upgraded to 36
- Android Gradle Plugin upgraded to 8.9.1, Gradle to 8.12
- Web bootstrap moved to `flutter_bootstrap.js`, replacing the deprecated service worker pattern
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
- Force unwraps on nullable PasswordModel fields replaced with null-safe defaults
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
