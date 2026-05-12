import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/values/colors.dart';
import '../../core/utils/credential_policy.dart';
import '../../core/models/password.dart';
import '../../core/navigation/navigation.dart';

Future<void> showQrExportDialog(PasswordModel model) async {
  final passphraseC = TextEditingController();
  String? qrData;
  String? errorMsg;
  var obscurePassphrase = true;

  await Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code, color: appColor3),
                  const SizedBox(width: 8),
                  const Text('Export as QR',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close), onPressed: appPopDialog),
                ],
              ),
              const Divider(),
              if (qrData == null) ...[
                const Text(
                    'Set a passphrase to encrypt the QR code. The recipient will need it to import.'),
                const SizedBox(height: 12),
                TextField(
                  controller: passphraseC,
                  obscureText: obscurePassphrase,
                  decoration: const InputDecoration(
                    labelText: 'Passphrase',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassphrase
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      tooltip: obscurePassphrase
                          ? 'Show passphrase'
                          : 'Hide passphrase',
                      onPressed: () => setState(
                        () => obscurePassphrase = !obscurePassphrase,
                      ),
                    ),
                  ),
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(errorMsg!,
                      style: const TextStyle(color: appDanger, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Generate QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor2,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final passphraseIssue =
                          CredentialPolicy.validateExportPassphrase(
                        passphraseC.text,
                      );
                      if (passphraseIssue != null) {
                        setState(() => errorMsg = passphraseIssue);
                        return;
                      }
                      try {
                        final data =
                            await _encryptEntry(model, passphraseC.text);
                        setState(() {
                          qrData = data;
                          errorMsg = null;
                        });
                      } catch (e) {
                        setState(() => errorMsg = 'Encryption failed.');
                      }
                    },
                  ),
                ),
              ] else ...[
                const Text(
                    'Scan this QR code in PassesBox on another device to import this entry.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Center(
                  child: QrImageView(
                    data: qrData!,
                    version: QrVersions.auto,
                    size: 220,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => qrData = null),
                  child: const Text('Change passphrase'),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
    backgroundColor: appSurface,
    shape: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
  );
}

Future<String> _encryptEntry(PasswordModel model, String passphrase) async {
  final json = jsonEncode({
    'title': model.title,
    'username': model.username,
    'password': model.password,
    'imageName': model.imageName,
    'url': model.url,
    'notes': model.notes,
    'totpSecret': model.totpSecret,
  });

  final random = Random.secure();
  final salt =
      Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));

  final key = await _argon2id(passphrase, salt);
  final algorithm = AesGcm.with256bits();
  final secretKey = await algorithm.newSecretKeyFromBytes(key);
  final nonce = algorithm.newNonce();
  final box = await algorithm.encrypt(
    utf8.encode(json),
    secretKey: secretKey,
    nonce: nonce,
  );

  // Encode: salt(16) + nonce(12) + mac(16) + ciphertext as base64
  final combined = Uint8List(16 + 12 + 16 + box.cipherText.length);
  combined.setRange(0, 16, salt);
  combined.setRange(16, 28, nonce);
  combined.setRange(28, 44, box.mac.bytes);
  combined.setRange(44, combined.length, box.cipherText);

  return 'pbbentry2:${base64.encode(combined)}';
}

// Argon2id key derivation — memory-hard, GPU/ASIC resistant.
// m=4096 KiB, t=3 iterations, p=1 lane; produces a 32-byte key.
Future<Uint8List> _argon2id(String password, Uint8List salt) async {
  final argon2 = Argon2id(
    parallelism: 1,
    memory: 4096,
    iterations: 3,
    hashLength: 32,
  );
  final derived = await argon2.deriveKey(
    secretKey: SecretKeyData(utf8.encode(password)),
    nonce: salt,
  );
  return Uint8List.fromList(await derived.extractBytes());
}
