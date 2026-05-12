import 'package:flutter_test/flutter_test.dart';
import 'package:passes_box/core/models/password.dart';
import 'package:passes_box/core/utils/credential_policy.dart';

void main() {
  test('normalizes bare domains to https URLs', () {
    expect(
      CredentialPolicy.normalizeUrl('example.com/login'),
      'https://example.com/login',
    );
  });

  test('rejects unsafe URL schemes', () {
    expect(CredentialPolicy.normalizeUrl('javascript:alert(1)'), isNull);
  });

  test('parses otpauth URLs into base32 TOTP secrets', () {
    expect(
      CredentialPolicy.normalizeTotpSecret(
        'otpauth://totp/Example?secret=jbswy3dpehpk3pxp&issuer=PassesBox',
      ),
      'JBSWY3DPEHPK3PXP',
    );
    expect(
      CredentialPolicy.normalizeTotpSecret(
        'OTPAUTH://totp/Example?SECRET=jbswy3dpehpk3pxp',
      ),
      'JBSWY3DPEHPK3PXP',
    );
  });

  test('validates required fields and malformed TOTP secrets', () {
    final issues = CredentialPolicy.validate(
      title: '',
      password: '',
      totpSecret: 'not valid!',
    );

    expect(issues, contains('Title is required.'));
    expect(issues, contains('Password is required.'));
    expect(issues, contains('TOTP secret is not valid.'));
  });

  test('audits weak, reused, and old passwords', () {
    final now = DateTime(2026, 5, 12);
    final issues = CredentialPolicy.audit(
      [
        PasswordModel(
          key: 1,
          title: 'Email',
          password: 'password',
          updatedAt: now.subtract(const Duration(days: 200)),
        ),
        PasswordModel(
          key: 2,
          title: 'Bank',
          password: 'password',
          updatedAt: now,
        ),
      ],
      now: now,
    );

    expect(
      issues.where((i) => i.type == CredentialIssueType.weakPassword),
      hasLength(2),
    );
    expect(
      issues.where((i) => i.type == CredentialIssueType.reusedPassword),
      hasLength(2),
    );
    expect(
      issues.where((i) => i.type == CredentialIssueType.oldPassword),
      hasLength(1),
    );
  });
}
