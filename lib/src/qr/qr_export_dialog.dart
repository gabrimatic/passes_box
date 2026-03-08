import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' hide Hmac;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/values/colors.dart';
import '../../core/models/password.dart';
import '../../core/navigation/navigation.dart';

Future<void> showQrExportDialog(PasswordModel model) async {
  final passphraseC = TextEditingController();
  String? qrData;
  String? errorMsg;

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
                      icon: const Icon(Icons.close),
                      onPressed: appPopDialog),
                ],
              ),
              const Divider(),
              if (qrData == null) ...[
                const Text(
                    'Set a passphrase to encrypt the QR code. The recipient will need it to import.'),
                const SizedBox(height: 12),
                TextField(
                  controller: passphraseC,
                  decoration: const InputDecoration(
                    labelText: 'Passphrase',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(errorMsg!,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 12)),
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
                      if (passphraseC.text.isEmpty) {
                        setState(() => errorMsg = 'Passphrase required.');
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
    backgroundColor: Colors.white,
    shape: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
    ),
  );
}

Future<String> _encryptEntry(PasswordModel model, String passphrase) async {
  final json = jsonEncode({
    'title': model.title,
    'username': model.username,
    'password': model.password,
    'url': model.url,
    'notes': model.notes,
    'totpSecret': model.totpSecret,
  });

  final random = Random.secure();
  final salt =
      Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));

  final key = _pbkdf2Simple(passphrase, salt);
  final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
  final secretKey = await algorithm.newSecretKeyFromBytes(key);
  final nonce = algorithm.newNonce();
  final box = await algorithm.encrypt(
    utf8.encode(json),
    secretKey: secretKey,
    nonce: nonce,
  );

  // Encode: salt(16) + iv(16) + ciphertext as base64
  final combined = Uint8List(32 + box.cipherText.length);
  combined.setRange(0, 16, salt);
  combined.setRange(16, 32, nonce);
  combined.setRange(32, combined.length, box.cipherText);

  return 'pbbentry:${base64.encode(combined)}';
}

Uint8List _pbkdf2Simple(String password, Uint8List salt) {
  final passwordBytes = utf8.encode(password);
  final hmac = Hmac(sha256, passwordBytes);
  var u =
      Uint8List.fromList(hmac.convert([...salt, 0, 0, 0, 1]).bytes);
  final block = Uint8List.fromList(u);
  for (var i = 1; i < 10000; i++) {
    u = Uint8List.fromList(hmac.convert(u).bytes);
    for (var j = 0; j < block.length; j++) {
      block[j] ^= u[j];
    }
  }
  return block;
}
