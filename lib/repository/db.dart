import 'package:hive_flutter/hive_flutter.dart';

import '../core/models/password.dart';

const appBoxName = 'passesBox';
late Box appBox;

Future<void> appOpenDatabase() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordModelAdapter());
  appBox = await Hive.openBox(appBoxName);
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
