import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/index.dart';
import '../core/models/password.dart';

const appBoxName = 'passesBox';
late Box appBox;

Future<void> appOpenDatabase() async {
  const secureStorage = FlutterSecureStorage();

  final containsEncryptionKey = await secureStorage.containsKey(key: kKey);
  if (!containsEncryptionKey) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: kKey,
      value: base64UrlEncode(key),
    );
  }

  final encryptionKey = base64Url.decode(
    (await secureStorage.read(key: kKey))!,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(PasswordModelAdapter());
  appBox = await Hive.openBox(
    appBoxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}

class PassesDB {
  static Future<void> insertAll(List<PasswordModel> models) async {
    await appBox.addAll(models);
    await appBox.flush();
  }

  static Future<void> insert(PasswordModel model) => appBox.add(model);

  static Future<void> update(PasswordModel model) => model.save();

  static List<PasswordModel> selectAll() =>
      appBox.values.map((e) => e as PasswordModel).toList();

  static Future<void> deleteAll() {
    return appBox.deleteFromDisk();
  }
}
