# Security

PassesBox is a password manager. Security is the entire point.

## Encryption Architecture

All password records are encrypted at rest using AES-256-CBC. The encryption key is a 256-bit random key generated once per device installation and stored in the platform's secure storage.

| Layer | Mechanism |
| --- | --- |
| Key generation | 32 bytes from `Random.secure()` |
| Key storage | Platform secure storage (Keychain, Android Keystore, localStorage) |
| Encryption | AES-256-CBC via `encrypt` package |
| IV | 16 bytes from `IV.fromSecureRandom(16)`, unique per operation |
| Database | sembast with custom encrypted codec |
| Backup files | Same AES-256-CBC encryption, random IV per file |

## Platform Key Storage

| Platform | Backend |
| --- | --- |
| iOS | Keychain Services |
| macOS | Keychain Services |
| Android | Android Keystore (EncryptedSharedPreferences) |
| Web | localStorage (browser sandbox) |

Web storage is inherently less secure than native platforms. The encryption key is stored in localStorage, which is accessible to JavaScript running on the same origin.

## What PassesBox Does Not Do

- No network calls. The app is entirely offline.
- No analytics, telemetry, or crash reporting.
- No cloud sync. Data stays on the device.
- No clipboard persistence. Passwords are copied to clipboard on creation; clearing is left to the OS.
- No hardcoded keys or static IVs.

## Backup Security

Backup files (`.pbb`) are encrypted with the device's encryption key. This means:

- Backups can only be restored on the same device (or a device with the same key).
- If the app is uninstalled, the encryption key is lost and backups become unreadable.
- Backup files are binary (IV + AES ciphertext), not human-readable.

## Android

- `android:allowBackup="false"` prevents Android's automatic backup from capturing the database.
- Biometric authentication uses the `USE_BIOMETRIC` permission.

## iOS and macOS

- File sharing and document browsing are disabled in Info.plist.
- App sandbox is enabled with minimal entitlements.

## Vulnerability Reporting

If you find a security issue, please report it privately:

1. Open a [GitHub Security Advisory](https://github.com/gabrimatic/passes_box/security/advisories/new)
2. Include steps to reproduce, expected behavior, and impact assessment
3. Allow up to 48 hours for initial response

Do not open public issues for security vulnerabilities.

## Out of Scope

- Social engineering attacks
- Physical device access with an unlocked screen
- Browser extension or OS-level keyloggers
- Vulnerabilities in upstream dependencies (report those to the respective maintainers)
