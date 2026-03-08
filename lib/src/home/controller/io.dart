import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/index.dart' hide Key;
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

  final iv = IV.fromSecureRandom(16);
  final encrypter = Encrypter(AES(encryptionKey));
  final encrypted = encrypter.encrypt(jsonEncode(list), iv: iv);
  final bytes = Uint8List.fromList(iv.bytes + encrypted.bytes);

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

  final file = await FilePicker.platform.pickFiles();

  if (file == null || file.files.isEmpty) {
    return;
  }

  Uint8List rawBytes;
  if (kIsWeb) {
    rawBytes = file.files.first.bytes!;
  } else {
    if (file.files.first.bytes != null) {
      rawBytes = file.files.first.bytes!;
    } else {
      rawBytes = await File(file.files.first.path!).readAsBytes();
    }
  }

  List<PasswordModel> list;
  try {
    final iv = IV(Uint8List.fromList(rawBytes.sublist(0, 16)));
    final ciphertext = Encrypted(Uint8List.fromList(rawBytes.sublist(16)));
    final encrypter = Encrypter(AES(encryptionKey));
    final data = encrypter.decrypt(ciphertext, iv: iv);

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
