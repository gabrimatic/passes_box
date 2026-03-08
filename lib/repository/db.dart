import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

import '../core/models/password.dart';
import 'db_factory_io.dart' if (dart.library.html) 'db_factory_web.dart';

const _dbName = 'passes_box.db';
const _storeName = 'passwords';
const _keyStorageKey = 'passes_box_encryption_key';

late Database _db;
late Key _encryptionKey;

final _store = intMapStoreFactory.store(_storeName);

Key get encryptionKey => _encryptionKey;

class _AesCodec extends Codec<Map<String, dynamic>, String> {
  final Key _key;

  _AesCodec(Key key) : _key = key;

  @override
  Converter<String, Map<String, dynamic>> get decoder => _AesDecoder(_key);

  @override
  Converter<Map<String, dynamic>, String> get encoder => _AesEncoder(_key);
}

class _AesEncoder extends Converter<Map<String, dynamic>, String> {
  final Key _key;

  _AesEncoder(this._key);

  @override
  String convert(Map<String, dynamic> input) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(jsonEncode(input), iv: iv);
    final combined = iv.bytes + encrypted.bytes;
    return base64.encode(combined);
  }
}

class _AesDecoder extends Converter<String, Map<String, dynamic>> {
  final Key _key;

  _AesDecoder(this._key);

  @override
  Map<String, dynamic> convert(String input) {
    final combined = base64.decode(input);
    final iv = IV(Uint8List.fromList(combined.sublist(0, 16)));
    final ciphertext = Uint8List.fromList(combined.sublist(16));
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt(Encrypted(ciphertext), iv: iv);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }
}

Future<void> appOpenDatabase() async {
  const secureStorage = FlutterSecureStorage();

  String? storedKey = await secureStorage.read(key: _keyStorageKey);
  if (storedKey == null) {
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    storedKey = base64.encode(keyBytes);
    await secureStorage.write(key: _keyStorageKey, value: storedKey);
  }

  _encryptionKey = Key(base64.decode(storedKey));

  final codec = SembastCodec(
    signature: 'passes_box_aes',
    codec: _AesCodec(_encryptionKey),
  );

  String dbPath;
  if (kIsWeb) {
    dbPath = _dbName;
  } else {
    final dir = await getApplicationDocumentsDirectory();
    dbPath = '${dir.path}/$_dbName';
  }

  _db = await getDbFactory().openDatabase(dbPath, codec: codec);
}

class PassesDB {
  static Future<int> insert(PasswordModel model) async {
    return await _store.add(_db, model.toMap());
  }

  static Future<void> insertAll(List<PasswordModel> models) async {
    await _db.transaction((txn) async {
      for (final model in models) {
        await _store.add(txn, model.toMap());
      }
    });
  }

  static Future<void> update(PasswordModel model) async {
    if (model.key == null) return;
    await _store.record(model.key!).put(_db, model.toMap());
  }

  static Future<void> delete(PasswordModel model) async {
    if (model.key == null) return;
    await _store.record(model.key!).delete(_db);
  }

  static Future<List<PasswordModel>> selectAll() async {
    final records = await _store.find(_db);
    return records
        .map((r) => PasswordModel.fromMap(r.value, key: r.key))
        .toList();
  }

  static Future<bool> isEmpty() async {
    final count = await _store.count(_db);
    return count == 0;
  }

  static Future<void> clear() async {
    await _store.delete(_db);
  }
}
