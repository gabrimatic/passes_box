import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

import '../core/models/password.dart';
import 'db_factory_io.dart' if (dart.library.js_interop) 'db_factory_web.dart';

const _dbName = 'passes_box.db';
const _storeName = 'passwords';
const _keyStorageKey = 'passes_box_encryption_key';

late Database _db;
late List<int> _encryptionKeyBytes;

final _store = intMapStoreFactory.store(_storeName);

List<int> get encryptionKey => _encryptionKeyBytes;

class VaultOpenException implements Exception {
  final String message;
  final Object cause;

  const VaultOpenException(this.message, this.cause);

  @override
  String toString() => message;
}

// AES-256-GCM codec — authenticated encryption, 12-byte nonce, 16-byte tag.
// Record format: nonce(12) + mac(16) + ciphertext, base64-encoded.
class _AesGcmCodec extends AsyncContentCodecBase {
  final List<int> _keyBytes;
  final _algorithm = AesGcm.with256bits();

  _AesGcmCodec(this._keyBytes);

  @override
  Future<String> encodeAsync(Object? input) async {
    final secretKey = await _algorithm.newSecretKeyFromBytes(_keyBytes);
    final nonce = _algorithm.newNonce();
    final box = await _algorithm.encrypt(
      utf8.encode(jsonEncode(input)),
      secretKey: secretKey,
      nonce: nonce,
    );
    final combined = Uint8List(12 + 16 + box.cipherText.length);
    combined.setRange(0, 12, nonce);
    combined.setRange(12, 28, box.mac.bytes);
    combined.setRange(28, combined.length, box.cipherText);
    return base64.encode(combined);
  }

  @override
  Future<Object?> decodeAsync(String encoded) async {
    final secretKey = await _algorithm.newSecretKeyFromBytes(_keyBytes);
    final combined = base64.decode(encoded);
    final nonce = combined.sublist(0, 12);
    final mac = Mac(combined.sublist(12, 28));
    final ciphertext = combined.sublist(28);
    final box = SecretBox(ciphertext, nonce: nonce, mac: mac);
    final plainBytes = await _algorithm.decrypt(box, secretKey: secretKey);
    return jsonDecode(utf8.decode(plainBytes));
  }
}

Future<String> _databasePath() async {
  if (kIsWeb) return _dbName;

  final dir = await getApplicationDocumentsDirectory();
  return '${dir.path}/$_dbName';
}

Future<void> appOpenDatabase() async {
  try {
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

    _encryptionKeyBytes = base64.decode(storedKey);
    if (_encryptionKeyBytes.length != 32) {
      throw const FormatException('Invalid vault key length');
    }

    final dbPath = await _databasePath();
    final codec = SembastCodec(
      signature: 'passes_box_gcm',
      codec: _AesGcmCodec(_encryptionKeyBytes),
    );
    _db = await getDbFactory().openDatabase(dbPath, codec: codec);
  } catch (e) {
    throw VaultOpenException(
      'This local vault could not be opened safely.',
      e,
    );
  }
}

Future<void> resetLocalVaultStorage() async {
  const secureStorage = FlutterSecureStorage();
  try {
    await _db.close();
  } catch (_) {}

  await getDbFactory().deleteDatabase(await _databasePath());
  await secureStorage.delete(key: _keyStorageKey);
}

class PassesDB {
  static Future<int> insert(PasswordModel model) async {
    model.createdAt = DateTime.now();
    model.updatedAt = DateTime.now();
    return await _store.add(_db, model.toMap());
  }

  static Future<void> insertAll(List<PasswordModel> models) async {
    final now = DateTime.now();
    await _db.transaction((txn) async {
      for (final model in models) {
        model.createdAt ??= now;
        model.updatedAt ??= model.createdAt ?? now;
        await _store.add(txn, model.toMap());
      }
    });
  }

  static Future<void> update(PasswordModel model) async {
    if (model.key == null) return;
    await _store.record(model.key!).put(_db, model.toMap());
  }

  static Future<void> updateWithHistory(
    PasswordModel model, {
    String? oldPassword,
  }) async {
    if (model.key == null) return;
    if (oldPassword != null &&
        oldPassword.isNotEmpty &&
        oldPassword != model.password) {
      final history = List<String>.from(model.passwordHistory ?? []);
      history.insert(0, oldPassword);
      if (history.length > 5) history.removeLast();
      model.passwordHistory = history;
    }
    model.updatedAt = DateTime.now();
    await _store.record(model.key!).put(_db, model.toMap());
  }

  static Future<void> delete(PasswordModel model) async {
    if (model.key == null) return;
    await _store.record(model.key!).delete(_db);
  }

  static Future<void> softDelete(PasswordModel model) async {
    if (model.key == null) return;
    model.isDeleted = true;
    model.deletedAt = DateTime.now();
    await _store.record(model.key!).put(_db, model.toMap());
  }

  static Future<void> restore(PasswordModel model) async {
    if (model.key == null) return;
    model.isDeleted = false;
    model.deletedAt = null;
    await _store.record(model.key!).put(_db, model.toMap());
  }

  static Future<void> permanentDelete(PasswordModel model) async {
    if (model.key == null) return;
    await _store.record(model.key!).delete(_db);
  }

  static Future<List<PasswordModel>> selectAll() async {
    final records = await _store.find(_db);
    return records
        .map((r) => PasswordModel.fromMap(r.value, key: r.key))
        .where((m) => !m.isDeleted)
        .toList();
  }

  static Future<List<PasswordModel>> selectDeleted() async {
    final records = await _store.find(_db);
    return records
        .map((r) => PasswordModel.fromMap(r.value, key: r.key))
        .where((m) => m.isDeleted)
        .toList();
  }

  static Future<void> purgeExpiredDeleted() async {
    final records = await _store.find(_db);
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await _db.transaction((txn) async {
      for (final r in records) {
        final model = PasswordModel.fromMap(r.value, key: r.key);
        if (model.isDeleted &&
            model.deletedAt != null &&
            model.deletedAt!.isBefore(cutoff)) {
          await _store.record(r.key).delete(txn);
        }
      }
    });
  }

  static Future<bool> isEmpty() async {
    final count = await _store.count(_db);
    return count == 0;
  }

  static Future<void> clear() async {
    await _store.delete(_db);
  }
}
