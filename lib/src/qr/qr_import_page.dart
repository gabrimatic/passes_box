import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/index.dart';
import '../../core/models/password.dart';
import '../home/controller/controller.dart';

class QrImportPage extends StatefulWidget {
  static const name = '/qr-import';
  const QrImportPage({super.key});

  @override
  State<QrImportPage> createState() => _QrImportPageState();
}

class _QrImportPageState extends State<QrImportPage> {
  bool _scanned = false;
  String? _scannedData;
  final _scanController = MobileScannerController();
  final _passphraseC = TextEditingController();
  String? _errorMsg;

  @override
  void dispose() {
    _scanController.dispose();
    _passphraseC.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    if (_scannedData == null) return;
    if (_passphraseC.text.isEmpty) {
      setState(() => _errorMsg = 'Enter the passphrase.');
      return;
    }

    try {
      final model = await _decryptEntry(_scannedData!, _passphraseC.text);
      await PassesDB.insert(model);
      HomeController.to.loadAll();
      appShowSnackbar(message: '"${model.title}" imported successfully.');
      Get.back();
    } catch (_) {
      setState(() => _errorMsg = 'Wrong passphrase or invalid QR code.');
    }
  }

  Future<PasswordModel> _decryptEntry(String qrData, String passphrase) async {
    if (!qrData.startsWith('pbbentry2:')) throw Exception('Not a PassesBox QR');

    // Format: salt(16) + nonce(12) + mac(16) + ciphertext
    final combined = base64.decode(qrData.substring(10));
    if (combined.length < 45) throw const FormatException('QR data too short');

    final salt = combined.sublist(0, 16);
    final nonce = combined.sublist(16, 28);
    final mac = Mac(combined.sublist(28, 44));
    final ciphertext = combined.sublist(44);

    final key = await _argon2id(passphrase, salt);
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKeyFromBytes(key);
    final box = SecretBox(ciphertext, nonce: nonce, mac: mac);
    final plainBytes = await algorithm.decrypt(box, secretKey: secretKey);

    final map = jsonDecode(utf8.decode(plainBytes)) as Map<String, dynamic>;
    return PasswordModel(
      title: map['title'] as String?,
      username: map['username'] as String?,
      password: map['password'] as String?,
      url: map['url'] as String?,
      notes: map['notes'] as String?,
      totpSecret: map['totpSecret'] as String?,
      imageName: map['imageName'] as String? ?? 'social',
    );
  }

  // Argon2id key derivation — memory-hard, GPU/ASIC resistant.
  Future<Uint8List> _argon2id(String password, List<int> salt) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import via QR')),
      body: _scannedData == null
          ? MobileScanner(
              controller: _scanController,
              onDetect: (capture) {
                if (_scanned) return;
                final raw = capture.barcodes.firstOrNull?.rawValue;
                if (raw != null && raw.startsWith('pbbentry2:')) {
                  _scanned = true;
                  setState(() => _scannedData = raw);
                }
              },
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: appSuccess, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                      'QR code scanned. Enter the passphrase to decrypt:',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passphraseC,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Passphrase', border: OutlineInputBorder()),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorMsg!, style: const TextStyle(color: appDanger)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Import Entry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor2,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _import,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
