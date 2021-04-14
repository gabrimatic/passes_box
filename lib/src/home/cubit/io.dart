import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/models/password.dart';
import '../../../repository/db.dart';
import 'home_cubit.dart';

final _key = Key.fromUtf8('sI8J0Mb5Aj4jJd5Pv5Ng9U756fq5lLiI');
final _iv = IV.fromLength(16);
final _encrypter = Encrypter(AES(_key));

Future<void> backup() async {
  if ((await Permission.storage.request()) != PermissionStatus.granted) {
    return;
  }

  final list = (Get.context!.read<HomeCubit>().state as HomeLoaded)
      .passesList
      .map((e) => e.toMap())
      .toList();

  final encrypted = _encrypter.encrypt(
    jsonEncode(list),
    iv: _iv,
  );

  final dir = Directory(
    join(
      (await getExternalStorageDirectory())!.path,
    ),
  )..createSync(
      recursive: true,
    );
  File(
    join(
      dir.path,
      'PassesBox_Backup.pbb',
    ),
  ).writeAsBytesSync(
    encrypted.bytes,
    mode: FileMode.writeOnly,
  );

  Get.back(
    closeOverlays: true,
  );
}

Future<void> restore() async {
  if ((await Permission.storage.request()) != PermissionStatus.granted) {
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
  Get.context!.read<HomeCubit>().addAll(list);
  Get.back(
    closeOverlays: true,
  );
}