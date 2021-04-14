import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../core/models/password.dart';

const appDBName = 'passesDB.db';
late Database appDB;

Future<void> appOpenDatabase() async {
  appDB = await openDatabase(
    join(await getDatabasesPath(), appDBName),
    onCreate: (database, _) async {
      await database.execute(PassesDB.createSQL);
    },
    version: 1,
  );
}

class PassesDB {
  static const _tableName = 'passwordsTB';
  static const createSQL =
      'CREATE TABLE "$_tableName" ("id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "title" TEXT NOT NULL, "imageName" TEXT NOT NULL, "username"	TEXT NOT NULL, "password"	TEXT NOT NULL);';

  static Future<int> insert(PasswordModel model) => appDB.insert(
        _tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  static Future<int> update(PasswordModel model) => appDB.update(
        _tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
        where: 'id = ?',
        whereArgs: [model.id],
      );

  static Future<PasswordModel> select(num id) async {
    final row = await appDB.query(_tableName, where: 'id = ?', whereArgs: [id]);
    return (row.isEmpty || row.first.isEmpty)
        ? PasswordModel()
        : PasswordModel.fromMap(row.first);
  }

  static Future<List<PasswordModel>> selectAll() async {
    final list = <PasswordModel>[];
    (await appDB.query(_tableName)).forEach(
      (element) => list.add(
        PasswordModel.fromMap(element),
      ),
    );
    return list;
  }

  static Future<int> getCount() async => (await appDB.query(_tableName)).length;

  static Future<int> deleteAll() => appDB.delete(_tableName);

  static Future<int> delete(int id) => appDB.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
}

/*import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:passes_box/core/models/password.dart';

Box<String> appGroupBox;
Box<PasswordModel> appPasswordBox;

class PassesDB {
  static Future<void> config() async {
    if (!kIsWeb) {
      var appDir = await getApplicationDocumentsDirectory();
      var path = appDir.path;
      Hive.init(path);
    }

    Hive.registerAdapter(PasswordModelAdapter());
    await Hive.openBox<PasswordModel>('passwordBox');
    await Hive.openBox<String>('groupBox');

    appPasswordBox = Hive.box<PasswordModel>('passwordBox');

    appGroupBox = Hive.box<String>('groupBox');
    if (!appGroupBox.containsKey('default')) appGroupBox.put(1, 'default');
  }

  Future<void> groupInsert(String title) async {
    await appGroupBox.add(title);
  }

  Future<void> groupDelete(String title) async {
    await appGroupBox.delete(title);
  }

  List<String> groupSelectAll() => appGroupBox.values.toList();

  void groupDeleteAll() {
    appPasswordBox.deleteFromDisk();
    appGroupBox.deleteFromDisk();
  }

  void passwordInsert(PasswordModel model) {
    appPasswordBox.put(model.title, model);
  }

  void passwordDelete(String title) {
    appPasswordBox.delete(title);
  }

  List<PasswordModel> passwordSelectByGroup(String groupTitle) =>
      appPasswordBox.values
          .where((element) => element.group == groupTitle)
          .toList();

  void passwordDeleteByGroup(String groupTitle) {
    appPasswordBox.deleteAll(
        appGroupBox.values.where((element) => element == groupTitle));
  }
}
*/
