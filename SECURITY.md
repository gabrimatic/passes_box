# Security

PassesBox is a password manager, so the security model needs to be clear.

## Encryption Architecture

Password records are encrypted at rest with AES-256-GCM. Every ciphertext carries a 16-byte authentication tag, so tampered or corrupted data is rejected before decryption. The encryption key is a 256-bit random key generated once per device installation and stored in the platform's secure storage.

| Layer | Mechanism |
| --- | --- |
| Key generation | 32 bytes from `Random.secure()` |
| Key storage | Platform secure storage (Keychain, Android Keystore, localStorage) |
| Database encryption | AES-256-GCM, 12-byte nonce + 16-byte auth tag per record |
| Device backup (`.pbb`) | AES-256-GCM with the device key, 12-byte nonce + 16-byte auth tag |
| Portable backup (`.pbbx`) | Argon2id (m=4096 KiB, t=3, p=1) → AES-256-GCM |
| QR export (`pbbentry2:`) | Argon2id (m=4096 KiB, t=3, p=1) → AES-256-GCM |

### Why AES-256-GCM

GCM is an authenticated encryption mode. Unlike CBC, it detects changes to ciphertext before producing plaintext. A corrupted backup or tampered database record fails decryption instead of producing garbage.

### Why Argon2id

Argon2id is the current OWASP-recommended algorithm for password-based key derivation. Its memory-hard design makes GPU and ASIC brute-force attacks more expensive than PBKDF2 or bcrypt.

## Platform Key Storage

| Platform | Backend |
| --- | --- |
| iOS | Keychain Services |
| macOS | Keychain Services |
| Android | Android Keystore (EncryptedSharedPreferences) |
| Web | localStorage (browser sandbox) |

Web storage is weaker than native secure storage. The encryption key is stored in localStorage, which is accessible to JavaScript running on the same origin.

## Boundaries

- No credential uploads. The optional HIBP breach check sends only the first 5 characters of a SHA-1 password hash to the Pwned Passwords API.
- No analytics, telemetry, or crash reporting.
- No cloud sync. Vault data stays on the device.
- No clipboard persistence. Passwords, password history entries, and TOTP codes clear after 30 seconds if the clipboard still contains the copied value.
- No hardcoded keys or static nonces.
- No unauthenticated ciphertext.

## Backup Security

### Device backup (`.pbb`)

Encrypted with the device key. It can only be restored on the same device, or a device with the same key. If the app is uninstalled and the key is lost, the backup becomes unreadable.

### Portable backup (`.pbbx`)

Encrypted with a key derived from a user-chosen passphrase using Argon2id. It can be restored on any device with the passphrase. Security depends on passphrase strength.

### QR entry export

Same scheme as the portable backup: Argon2id plus AES-256-GCM, applied to one entry. The passphrase is required to import on the receiving device.

## Android

- `android:allowBackup="false"` prevents Android's automatic backup from capturing the database.
- Biometric authentication uses the `USE_BIOMETRIC` permission.
- `FLAG_SECURE` blocks screenshots and task-switcher previews.

## iOS and macOS

- File sharing and document browsing are disabled in `Info.plist`.
- App sandbox is enabled with minimal entitlements.
- A privacy overlay is shown when the app moves to the background.

## Vulnerability Reporting

If you find a security issue, report it privately:

1. Open a [GitHub Security Advisory](https://github.com/gabrimatic/passes_box/security/advisories/new)
2. Include steps to reproduce, expected behavior, and impact
3. Allow up to 48 hours for an initial response

Do not open public issues for security vulnerabilities.

## Out of Scope

- Social engineering attacks
- Physical device access with an unlocked screen
- Browser extension or OS-level keyloggers
- Vulnerabilities in upstream dependencies (report those to the respective maintainers)
