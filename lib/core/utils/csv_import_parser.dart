import 'package:csv/csv.dart';

import '../models/password.dart';
import 'credential_policy.dart';

class CsvImportParser {
  static List<PasswordModel> parse(String csvString) {
    final rows = CsvDecoder().convert(csvString);
    if (rows.isEmpty) return [];

    final header =
        rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
    var titleIdx = _findHeader(
      header,
      ['title', 'name', 'site', 'login_title'],
    );
    var usernameIdx = _findHeader(
      header,
      ['username', 'login', 'email', 'user', 'login_username'],
    );
    var passwordIdx = _findHeader(
      header,
      ['password', 'pass', 'login_password'],
    );
    var urlIdx = _findHeader(
      header,
      ['url', 'website', 'uri', 'login_uri'],
    );
    var notesIdx = _findHeader(
      header,
      ['notes', 'note', 'comment'],
    );
    var totpIdx = _findHeader(
      header,
      ['totp', 'otp', 'login_totp', 'totpsecret', 'totp_secret', '2fa secret'],
    );
    var categoryIdx = _findHeader(
      header,
      ['category', 'type', 'folder'],
    );

    final hasHeader = [
      titleIdx,
      usernameIdx,
      passwordIdx,
      urlIdx,
      notesIdx,
      totpIdx,
      categoryIdx,
    ].any((index) => index >= 0);
    final dataRows = hasHeader ? rows.skip(1).toList() : rows;
    if (!hasHeader) {
      titleIdx = 0;
      usernameIdx = 1;
      passwordIdx = 2;
      urlIdx = 3;
      notesIdx = 4;
      totpIdx = 5;
      categoryIdx = -1;
    }

    final models = <PasswordModel>[];
    for (final row in dataRows) {
      String? getValue(int index) {
        if (index < 0 || index >= row.length) return null;
        final value = row[index]?.toString().trim() ?? '';
        return value.isEmpty ? null : value;
      }

      final password = getValue(passwordIdx);
      if (password == null) continue;

      models.add(
        PasswordModel(
          title: getValue(titleIdx) ?? 'Imported',
          username: getValue(usernameIdx),
          password: password,
          url: CredentialPolicy.normalizeUrl(getValue(urlIdx)),
          notes: getValue(notesIdx),
          totpSecret: CredentialPolicy.normalizeTotpSecret(getValue(totpIdx)),
          imageName: _categoryFromImport(getValue(categoryIdx)),
        ),
      );
    }

    return models;
  }

  static int _findHeader(List<String> header, List<String> names) {
    return header.indexWhere(names.contains);
  }

  static String _categoryFromImport(String? input) {
    final value = input?.toLowerCase().trim() ?? '';
    if (value.contains('bank')) return 'bank';
    if (value.contains('card') || value.contains('payment')) return 'card';
    if (value.contains('mail')) return 'email';
    if (value.contains('social')) return 'social';
    if (value.contains('wifi') || value.contains('wi-fi')) return 'wifi';
    return 'web';
  }
}
