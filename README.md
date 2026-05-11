# PassesBox

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-green.svg)](https://github.com/gabrimatic/passes_box/releases/latest)
[![Platform: iOS](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)](https://github.com/gabrimatic/passes_box/releases/latest)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://github.com/gabrimatic/passes_box/releases/latest)
[![Platform: Web](https://img.shields.io/badge/Platform-Web-orange.svg)](https://github.com/gabrimatic/passes_box)
[![Flutter 3.x+](https://img.shields.io/badge/Flutter-3.x%2B-54C5F8.svg)](https://flutter.dev)
[![Dart 3.x+](https://img.shields.io/badge/Dart-3.x%2B-0175C2.svg)](https://dart.dev)

PassesBox is a local password manager with AES-256-GCM encryption, biometric access on mobile, and encrypted backups for moving data when you need to.

It keeps credentials in an encrypted sembast database and runs offline by default. The optional breach check uses k-anonymity, so the app never sends a full password hash.

<p align="center">
  <img src="assets/screenshot.png" width="600" alt="PassesBox screenshot">
</p>

---

## Features

- Local vault: encrypted sembast database with AES-256-GCM authenticated encryption
- Device key: 256-bit key generated with `Random.secure()` and stored in platform secure storage
- Portable exports: passphrase-protected `.pbbx` backups and QR exports using Argon2id
- Mobile lock: biometric authentication on Android and iOS when the device supports it
- Password tools: secure generator, password history, vault health warnings, duplicate detection, and TOTP codes
- Safer entry flow: required titles, hidden password entry, URL and TOTP validation, and explicit copy actions
- Clipboard guard: copied passwords, password history entries, and TOTP codes clear after 30 seconds if unchanged
- Import and restore: device-locked `.pbb` backups, portable `.pbbx` backups, QR import, and CSV import
- Network boundary: no telemetry, no cloud sync, and no credential uploads
- Platforms: Android, iOS, macOS, and Web

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | Supported | Biometric auth available |
| iOS | Supported | Biometric auth available |
| macOS | Supported | No biometric gate on desktop |
| Web | Supported | Key stored in localStorage; no biometric gate |
| Windows | Untested / Planned | Build compiles; not officially supported |

---

## Security

PassesBox is built around a narrow security model: keep the vault local, encrypt records before they touch disk, and make backup formats explicit.

### Encryption architecture

- **Algorithm:** AES-256-GCM authenticated encryption. Every ciphertext has a 16-byte authentication tag, so tampered or corrupted data is rejected before decryption.
- **Key:** 256-bit key generated once with `Random.secure()`, stored in platform secure storage
- **Nonce:** 12 random bytes per operation, unique per record
- **Database:** sembast with a custom `SembastCodec`. Every record is AES-GCM encrypted before writing to disk.
- **Device backup (`.pbb`):** AES-GCM encrypted with the same device key; not portable across devices.
- **Portable backup (`.pbbx`):** AES-GCM encrypted with a key derived from a user passphrase via Argon2id (m=4096 KiB, t=3, p=1). Restorable on any device.
- **QR export (`pbbentry2:`):** Same Argon2id + AES-GCM scheme as the portable backup, per-entry.

No hardcoded keys. No static nonces. No unauthenticated ciphertext. No plaintext vault records at rest.

PassesBox also keeps secret handling explicit in the UI. Saving a credential does not copy the password automatically, imports normalize URLs and TOTP secrets, restore flows ask before replacing the vault, and the home screen surfaces weak, reused, and old passwords.

### Key storage by platform

| Platform | Storage mechanism |
|----------|------------------|
| iOS | Keychain via `flutter_secure_storage` |
| macOS | Keychain via `flutter_secure_storage` |
| Android | Android Keystore via `flutter_secure_storage` |
| Web | `localStorage` (browser-managed) |

> **Backup portability:** A `.pbb` file created on one device can only be restored on that device. Use a `.pbbx` portable backup when moving to a new device.

---

## Downloads

| Platform | Link |
|----------|------|
| Android | [GitHub Releases](https://github.com/gabrimatic/passes_box/releases/latest) |
| macOS | [GitHub Releases](https://github.com/gabrimatic/passes_box/releases/latest) |
| Windows | [GitHub Releases](https://github.com/gabrimatic/passes_box/releases/latest) |
| Web | [Build from source](#building-from-source). Run locally with `flutter run -d chrome` |

---

## Building From Source

```bash
git clone https://github.com/gabrimatic/passes_box.git
cd passes_box
flutter pub get
flutter run
```

### Platform Build Commands

| Platform | Command |
|----------|---------|
| Android | `flutter build apk --release` |
| iOS | `flutter build ios --release` |
| macOS | `flutter build macos --release` |
| Web | `flutter build web --release` |

---

## Architecture

<details>
<summary>Project structure</summary>

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── models/
│   │   └── password.dart          # PasswordModel
│   ├── navigation/
│   │   ├── get_pages.dart
│   │   └── navigation.dart
│   ├── services/
│   │   ├── clipboard_service.dart
│   │   ├── lock_service.dart
│   │   └── password_generator_service.dart
│   ├── utils/
│   │   ├── credential_policy.dart # validation and vault health checks
│   │   ├── csv_import_parser.dart
│   │   ├── passphrase.dart
│   │   └── password_strength.dart
│   ├── values/
│   │   ├── colors.dart
│   │   ├── strings.dart
│   │   └── values.dart
│   └── widgets/
│       └── widgets.dart
├── repository/
│   ├── db.dart                    # AES codec, PassesDB, key management
│   ├── db_factory_io.dart         # sembast factory for native
│   └── db_factory_web.dart        # sembast_web factory
└── src/
    ├── splash/
    │   └── view/page.dart         # biometric auth gate
    ├── home/
    │   ├── controller/
    │   │   ├── controller.dart    # GetX controller, CRUD
    │   │   └── io.dart            # backup / restore logic
    │   ├── dialogs/
    │   │   └── dialogs.dart       # password entry, settings, delete
    │   └── view/
    │       └── page.dart
    └── about/
        └── page/about_page.dart
```

</details>

---

## Troubleshooting

<details>
<summary>Biometric authentication not working</summary>

Biometric auth is only available on Android and iOS. On macOS and Web it is disabled by design. Make sure the device has at least one enrolled fingerprint or Face ID profile. The app checks `localAuth.isDeviceSupported()` at runtime and skips the auth gate when the device reports no support.

</details>

<details>
<summary>Backup restore fails or produces garbled data</summary>

`.pbb` files are encrypted with the device key at the time of export. Restoring on a different device, or after reinstalling the app, will fail with "Invalid or incompatible backup file." Use a passphrase-protected `.pbbx` backup to move data between devices.

</details>

<details>
<summary>Imported CSV entries are missing optional fields</summary>

PassesBox imports rows that contain a password. Optional URL and TOTP fields are normalized before saving, and unsafe or malformed optional fields are skipped instead of being stored. The importer understands common Chrome, Bitwarden, 1Password, and generic column names.

</details>

<details>
<summary>Web storage limitations</summary>

On Web, the encryption key is stored in `localStorage`. Clearing browser storage or switching browsers can make existing data inaccessible. Export a backup before clearing site data.

</details>

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

[MIT](LICENSE)

---

Created by [Soroush Yousefpour](https://gabrimatic.info)

<a href="https://www.buymeacoffee.com/gabrimatic" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee"></a>
