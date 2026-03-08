import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' hide Hmac;
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
    if (!qrData.startsWith('pbbentry:')) throw Exception('Not a PassesBox QR');
    final combined = base64.decode(qrData.substring(9));
    final salt = combined.sublist(0, 16);
    final ivBytes = combined.sublist(16, 32);
    final ciphertext = combined.sublist(32);

    final key = _pbkdf2Simple(passphrase, salt);
    final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final secretKey = await algorithm.newSecretKeyFromBytes(key);
    final box = SecretBox(ciphertext, nonce: ivBytes, mac: Mac.empty);
    final plainBytes = await algorithm.decrypt(box, secretKey: secretKey);
    final json = utf8.decode(plainBytes);

    final map = jsonDecode(json) as Map<String, dynamic>;
    return PasswordModel(
      title: map['title'] as String?,
      username: map['username'] as String?,
      password: map['password'] as String?,
      url: map['url'] as String?,
      notes: map['notes'] as String?,
      totpSecret: map['totpSecret'] as String?,
      imageName: 'social',
    );
  }

  Uint8List _pbkdf2Simple(String password, List<int> salt) {
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
                if (raw != null && raw.startsWith('pbbentry:')) {
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
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                      'QR code scanned. Enter the passphrase to decrypt:',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passphraseC,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Passphrase',
                        border: OutlineInputBorder()),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorMsg!,
                        style: const TextStyle(color: Colors.red)),
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
