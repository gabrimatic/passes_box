import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' hide Hmac;
import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/index.dart';
import '../../../core/models/password.dart';
import 'controller.dart';

Future<void> backup() async {
  if (await PassesDB.isEmpty() ||
      (!kIsWeb &&
          GetPlatform.isMobile &&
          !(await Permission.storage.request().isGranted))) {
    return;
  }

  final list = HomeController.to.passesList.map((e) => e.toMap()).toList();

  final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
  final secretKey = await algorithm.newSecretKeyFromBytes(encryptionKey);
  final nonce = algorithm.newNonce();
  final box = await algorithm.encrypt(
    utf8.encode(jsonEncode(list)),
    secretKey: secretKey,
    nonce: nonce,
  );
  final bytes = Uint8List.fromList(nonce + box.cipherText);

  if (kIsWeb || !GetPlatform.isMobile) {
    await FileSaver.instance.saveFile(
      name: 'PassesBox_Backup',
      bytes: bytes,
      fileExtension: 'pbb',
      mimeType: MimeType.other,
    );
  } else {
    await FileSaver.instance.saveAs(
      name: 'PassesBox_Backup',
      bytes: bytes,
      fileExtension: 'pbb',
      mimeType: MimeType.other,
    );
  }

  appPopDialog();

  appShowSnackbar(message: 'Backup file ${kIsWeb ? 'downloaded' : 'saved'}.');
}

Future<void> restore() async {
  if (!kIsWeb &&
      GetPlatform.isMobile &&
      !(await Permission.storage.request().isGranted)) {
    return;
  }

  final xfile = await openFile();
  if (xfile == null) return;

  final rawBytes = await xfile.readAsBytes();

  List<PasswordModel> list;
  try {
    final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final secretKey = await algorithm.newSecretKeyFromBytes(encryptionKey);
    final nonce = rawBytes.sublist(0, 16);
    final ciphertext = rawBytes.sublist(16);
    final box = SecretBox(ciphertext, nonce: nonce, mac: Mac.empty);
    final plainBytes = await algorithm.decrypt(box, secretKey: secretKey);
    final data = utf8.decode(plainBytes);

    final json = jsonDecode(data);
    list = <PasswordModel>[];
    for (final element in json as List) {
      list.add(
        PasswordModel.fromMap(
          element as Map<String, dynamic>,
        ),
      );
    }
  } catch (_) {
    appShowSnackbar(message: 'Invalid or incompatible backup file.');
    return;
  }

  await PassesDB.clear();
  await PassesDB.insertAll(list);

  HomeController.to.loadAll();
  appPopDialog();

  appShowSnackbar(message: 'All passwords have been restored.');
}

// PBKDF2-SHA256 key derivation
Uint8List _pbkdf2(String password, Uint8List salt,
    {int iterations = 100000, int keyLength = 32}) {
  final passwordBytes = utf8.encode(password);
  final hmac = Hmac(sha256, passwordBytes);

  final blocks = <int>[];
  var blockIndex = 1;
  while (blocks.length < keyLength) {
    var u = Uint8List.fromList(
        hmac.convert([...salt, 0, 0, 0, blockIndex]).bytes);
    final block = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < block.length; j++) {
        block[j] ^= u[j];
      }
    }
    blocks.addAll(block);
    blockIndex++;
  }
  return Uint8List.fromList(blocks.sublist(0, keyLength));
}

Future<void> exportPortable() async {
  final passphraseC = TextEditingController();
  final confirmC = TextEditingController();

  final confirmed = await Get.defaultDialog<bool>(
    title: 'Export with Passphrase',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
            'Set a passphrase to protect this backup. You will need it to restore on any device.'),
        const SizedBox(height: 12),
        TextField(
          controller: passphraseC,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: 'Passphrase', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: confirmC,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: 'Confirm passphrase', border: OutlineInputBorder()),
        ),
      ],
    ),
    textConfirm: 'Export',
    textCancel: 'Cancel',
    confirmTextColor: Colors.white,
    onConfirm: () => Get.back(result: true),
    onCancel: () => Get.back(result: false),
  );

  if (confirmed != true) return;

  if (passphraseC.text.isEmpty) {
    appShowSnackbar(message: 'Passphrase cannot be empty.');
    return;
  }
  if (passphraseC.text != confirmC.text) {
    appShowSnackbar(message: 'Passphrases do not match.');
    return;
  }

  try {
    final models = await PassesDB.selectAll();
    final jsonData = jsonEncode(models.map((m) => m.toMap()).toList());

    final random = Random.secure();
    final salt =
        Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));

    final key = _pbkdf2(passphraseC.text, salt);

    final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final secretKey = await algorithm.newSecretKeyFromBytes(key);
    final nonce = algorithm.newNonce();
    final box = await algorithm.encrypt(
      utf8.encode(jsonData),
      secretKey: secretKey,
      nonce: nonce,
    );

    // Format: version(1) + salt(16) + iv(16) + ciphertext
    final output = Uint8List(1 + 16 + 16 + box.cipherText.length);
    output[0] = 1; // version
    output.setRange(1, 17, salt);
    output.setRange(17, 33, nonce);
    output.setRange(33, output.length, box.cipherText);

    await FileSaver.instance.saveFile(
      name: 'passesbox_portable_${DateTime.now().millisecondsSinceEpoch}',
      bytes: output,
      fileExtension: 'pbbx',
      mimeType: MimeType.other,
    );

    appShowSnackbar(message: 'Portable backup exported successfully.');
  } catch (e) {
    appShowSnackbar(message: 'Export failed: $e');
  }
}

Future<void> restorePortable() async {
  try {
    const typeGroup = XTypeGroup(
      label: 'PassesBox backup',
      extensions: ['pbbx'],
      mimeTypes: ['application/octet-stream'],
    );
    final xfile = await openFile(acceptedTypeGroups: [typeGroup]);
    if (xfile == null) return;

    final rawBytes = await xfile.readAsBytes();
    if (rawBytes.length < 34) {
      appShowSnackbar(message: 'Invalid backup file.');
      return;
    }

    final passphraseC = TextEditingController();
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Enter Passphrase',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'Enter the passphrase used when this backup was created.'),
          const SizedBox(height: 12),
          TextField(
            controller: passphraseC,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Passphrase', border: OutlineInputBorder()),
          ),
        ],
      ),
      textConfirm: 'Restore',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirmed != true) return;

    final version = rawBytes[0];
    if (version != 1) {
      appShowSnackbar(message: 'Unsupported backup version.');
      return;
    }

    final salt = rawBytes.sublist(1, 17);
    final ivBytes = rawBytes.sublist(17, 33);
    final ciphertext = rawBytes.sublist(33);

    final key = _pbkdf2(passphraseC.text, salt);

    String jsonData;
    try {
      final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
      final secretKey = await algorithm.newSecretKeyFromBytes(key);
      final box = SecretBox(ciphertext, nonce: ivBytes, mac: Mac.empty);
      final plainBytes = await algorithm.decrypt(box, secretKey: secretKey);
      jsonData = utf8.decode(plainBytes);
    } catch (_) {
      appShowSnackbar(message: 'Wrong passphrase or corrupted file.');
      return;
    }

    final list = (jsonDecode(jsonData) as List)
        .map((e) => PasswordModel.fromMap(e as Map<String, dynamic>))
        .toList();

    await PassesDB.clear();
    await PassesDB.insertAll(list);

    HomeController.to.loadAll();
    appShowSnackbar(
        message: 'Portable backup restored: ${list.length} entries.');
    Get.back();
  } catch (e) {
    appShowSnackbar(message: 'Restore failed: $e');
  }
}

Future<void> importCsv() async {
  try {
    const typeGroup = XTypeGroup(
      label: 'CSV',
      extensions: ['csv'],
      mimeTypes: ['text/csv'],
    );
    final xfile = await openFile(acceptedTypeGroups: [typeGroup]);
    if (xfile == null) return;

    final csvString = await xfile.readAsString();

    final rows = CsvDecoder().convert(csvString);
    if (rows.isEmpty) {
      appShowSnackbar(message: 'CSV file is empty.');
      return;
    }

    final header =
        rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
    int titleIdx =
        header.indexWhere((h) => h == 'title' || h == 'name' || h == 'site');
    int usernameIdx = header.indexWhere(
        (h) => h == 'username' || h == 'login' || h == 'email' || h == 'user');
    int passwordIdx =
        header.indexWhere((h) => h == 'password' || h == 'pass');
    int urlIdx =
        header.indexWhere((h) => h == 'url' || h == 'website' || h == 'uri');
    int notesIdx = header
        .indexWhere((h) => h == 'notes' || h == 'note' || h == 'comment');

    final dataRows = titleIdx >= 0 ? rows.skip(1).toList() : rows;
    if (titleIdx < 0) {
      titleIdx = 0;
      usernameIdx = 1;
      passwordIdx = 2;
      urlIdx = 3;
      notesIdx = 4;
    }

    final models = <PasswordModel>[];
    for (final row in dataRows) {
      String? getValue(int idx) {
        if (idx < 0 || idx >= row.length) return null;
        final v = row[idx]?.toString().trim() ?? '';
        return v.isEmpty ? null : v;
      }

      final pw = getValue(passwordIdx);
      if (pw == null) continue;
      models.add(PasswordModel(
        title: getValue(titleIdx) ?? 'Imported',
        username: getValue(usernameIdx),
        password: pw,
        url: getValue(urlIdx),
        notes: getValue(notesIdx),
        imageName: 'web',
      ));
    }

    if (models.isEmpty) {
      appShowSnackbar(message: 'No valid entries found in CSV.');
      return;
    }

    final confirmed = await Get.defaultDialog<bool>(
      title: 'Import CSV',
      content: Text('Found ${models.length} entries. Import all?'),
      textConfirm: 'Import',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirmed != true) return;

    await PassesDB.insertAll(models);
    HomeController.to.loadAll();
    appShowSnackbar(message: 'Imported ${models.length} entries from CSV.');
    Get.back();
  } catch (e) {
    appShowSnackbar(message: 'Import failed: $e');
  }
}

// Check a single password against the HIBP k-anonymity API.
// Returns the breach count (0 if not found or on network error).
Future<int> checkHibp(String password) async {
  final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
  final prefix = hash.substring(0, 5);
  final suffix = hash.substring(5);

  try {
    final response = await http
        .get(
          Uri.parse('https://api.pwnedpasswords.com/range/$prefix'),
          headers: {'Add-Padding': 'true'},
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return 0;

    for (final line in response.body.split('\n')) {
      final parts = line.trim().split(':');
      if (parts.length == 2 && parts[0].toUpperCase() == suffix) {
        return int.tryParse(parts[1]) ?? 1;
      }
    }
    return 0;
  } catch (_) {
    return 0;
  }
}
