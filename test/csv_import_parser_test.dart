import 'package:flutter_test/flutter_test.dart';
import 'package:passes_box/core/utils/csv_import_parser.dart';

void main() {
  test('parses Bitwarden-style login columns with TOTP and folder', () {
    final entries = CsvImportParser.parse('''
folder,favorite,type,name,notes,fields,reprompt,login_uri,login_username,login_password,login_totp
Banking,false,login,Example Bank,Main account,,,example.com,soroush,secret,JBSWY3DPEHPK3PXP
''');

    expect(entries, hasLength(1));
    expect(entries.single.title, 'Example Bank');
    expect(entries.single.username, 'soroush');
    expect(entries.single.password, 'secret');
    expect(entries.single.url, 'https://example.com');
    expect(entries.single.totpSecret, 'JBSWY3DPEHPK3PXP');
    expect(entries.single.imageName, 'bank');
  });

  test('skips rows without passwords and drops invalid optional fields', () {
    final entries = CsvImportParser.parse('''
title,username,password,url,totp
No Password,soroush,,https://example.com,JBSWY3DPEHPK3PXP
Bad Optional,soroush,secret,javascript:alert(1),not-valid!
''');

    expect(entries, hasLength(1));
    expect(entries.single.title, 'Bad Optional');
    expect(entries.single.url, isNull);
    expect(entries.single.totpSecret, isNull);
  });

  test('detects headers even when a title column is missing', () {
    final entries = CsvImportParser.parse('''
login_uri,login_username,login_password
https://example.com,soroush,secret
''');

    expect(entries, hasLength(1));
    expect(entries.single.title, 'Imported');
    expect(entries.single.username, 'soroush');
    expect(entries.single.password, 'secret');
    expect(entries.single.url, 'https://example.com');
  });
}
