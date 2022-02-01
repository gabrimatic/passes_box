import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/index.dart' hide Key;
import '../../../core/models/password.dart';
import 'home_controller.dart';

final _key = Key.fromUtf8('sI8J0Mb5Aj4jJd5Pv5Ng9U756fq5lLiI');
final _iv = IV.fromLength(16);
final _encrypter = Encrypter(AES(_key));

Future<void> backup() async {
  await Permission.storage.shouldShowRequestRationale;
  if (!(await Permission.storage.request().isGranted)) {
    return;
  }

  final list = HomeController.to.passesList.map((e) => e.toMap()).toList();

  final encrypted = _encrypter.encrypt(
    jsonEncode(list),
    iv: _iv,
  );

  final res = await FileSaver.instance.saveAs(
    'PassesBox_Backup.pbb',
    encrypted.bytes,
    '',
    MimeType.OTHER,
  );

  appPopDialog();

  appShowSnackbar(message: 'Backup file saved in the $res directory.');
}

Future<void> restore() async {
  if (!(await Permission.storage.request().isGranted)) {
    return;
  }

  final file = await FilePicker.platform.pickFiles();

  if (file == null || file.files.isEmpty || file.files.first.path!.isEmpty) {
    return;
  }

  final decrepted = _encrypter.decrypt(
    Encrypted(
      File(file.files.first.path!).readAsBytesSync(),
    ),
    iv: _iv,
  );

  final json = jsonDecode(decrepted);
  final list = <PasswordModel>[];

  (json as List).forEach((element) {
    list.add(
      PasswordModel.fromMap(
        element as Map<String, dynamic>,
      ),
    );
  });

  await PassesDB.deleteAll();

  for (var i = 0; i < list.length; i++) {
    await PassesDB.insert(list[i]);
  }
  HomeController.to.addAll(list);
  appPopDialog();

  appShowSnackbar(message: 'All passwords have successfully restored!');
}
