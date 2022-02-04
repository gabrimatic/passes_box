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

final _key = Key.fromUtf8('sI8J0Mb5Aj4jJd5Pv5Ng9U756fq5lLiI');
final _iv = IV.fromLength(16);
final _encrypter = Encrypter(AES(_key));

Future<void> backup() async {
  if (appBox.values.isEmpty ||
      (!kIsWeb &&
          GetPlatform.isMobile &&
          !(await Permission.storage.request().isGranted))) {
    return;
  }

  final list = HomeController.to.passesList.map((e) => e.toMap()).toList();

  final encrypted = _encrypter.encrypt(
    jsonEncode(list),
    iv: _iv,
  );

  if (kIsWeb || !GetPlatform.isMobile) {
    await FileSaver.instance.saveFile(
      'PassesBox_Backup.pbb',
      encrypted.bytes,
      '',
      mimeType: MimeType.OTHER,
    );
  } else {
    await FileSaver.instance.saveAs(
      'PassesBox_Backup.pbb',
      encrypted.bytes,
      '',
      MimeType.OTHER,
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

  String data = '';
  if (kIsWeb) {
    data = _encrypter.decrypt(
      Encrypted(file.files.first.bytes!),
      iv: _iv,
    );
  } else {
    final fileObj = file.files.first.bytes == null
        ? File(file.files.first.path!)
        : File.fromRawPath(file.files.first.bytes!);

    data = _encrypter.decrypt(
      Encrypted(fileObj.readAsBytesSync()),
      iv: _iv,
    );
  }

  final json = jsonDecode(data);
  final list = <PasswordModel>[];

  (json as List).forEach((element) {
    list.add(
      PasswordModel.fromMap(
        element as Map<String, dynamic>,
      ),
    );
  });

  await appBox.clear();

  await PassesDB.insertAll(list);

  HomeController.to.loadAll();
  appPopDialog();

  appShowSnackbar(message: 'All passwords have successfully restored!');
}
