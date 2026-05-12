import 'package:otp_auth/otp_auth.dart';

import '../models/password.dart';
import 'password_strength.dart';

enum CredentialIssueSeverity { warning, danger }

enum CredentialIssueType {
  weakPassword,
  reusedPassword,
  oldPassword,
}

class CredentialIssue {
  final CredentialIssueType type;
  final CredentialIssueSeverity severity;
  final PasswordModel model;
  final String title;
  final String detail;

  const CredentialIssue({
    required this.type,
    required this.severity,
    required this.model,
    required this.title,
    required this.detail,
  });
}

class CredentialPolicy {
  static const oldPasswordThreshold = Duration(days: 180);

  static List<String> validate({
    required String title,
    required String password,
    String? url,
    String? totpSecret,
  }) {
    final issues = <String>[];

    if (title.trim().isEmpty) {
      issues.add('Title is required.');
    }
    if (password.isEmpty) {
      issues.add('Password is required.');
    }
    if (url != null && url.trim().isNotEmpty && normalizeUrl(url) == null) {
      issues.add('URL must use http://, https://, or a bare domain.');
    }
    if (totpSecret != null &&
        totpSecret.trim().isNotEmpty &&
        normalizeTotpSecret(totpSecret) == null) {
      issues.add('TOTP secret is not valid.');
    }

    return issues;
  }

  static String? normalizeUrl(String? input) {
    final trimmed = input?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.contains(RegExp(r'\s'))) return null;

    final withScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(trimmed)
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    return uri.toString();
  }

  static String? normalizeTotpSecret(String? input) {
    final raw = input?.trim();
    if (raw == null || raw.isEmpty) return null;

    String secret;
    if (raw.toLowerCase().startsWith('otpauth://')) {
      try {
        secret = OTPUri.extractSecret(raw);
      } catch (_) {
        final uri = Uri.tryParse(raw);
        String? querySecret;
        final queryEntries = uri?.queryParameters.entries;
        if (queryEntries != null) {
          for (final entry in queryEntries) {
            if (entry.key.toLowerCase() == 'secret') {
              querySecret = entry.value;
              break;
            }
          }
        }
        if (querySecret == null || querySecret.isEmpty) return null;
        secret = querySecret;
      }
    } else {
      secret = raw;
    }

    final normalized = secret.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    if (!_isValidBase32Secret(normalized)) return null;
    return normalized;
  }

  static List<CredentialIssue> audit(
    Iterable<PasswordModel> entries, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final activeEntries = entries.where((entry) => !entry.isDeleted).toList();
    final issues = <CredentialIssue>[];

    final passwordGroups = <String, List<PasswordModel>>{};
    for (final entry in activeEntries) {
      final password = entry.password ?? '';
      if (password.isEmpty) continue;

      if (PasswordStrengthUtil.score(password) < 0.5) {
        issues.add(
          CredentialIssue(
            type: CredentialIssueType.weakPassword,
            severity: CredentialIssueSeverity.danger,
            model: entry,
            title: 'Weak password',
            detail: '"${_entryTitle(entry)}" uses a weak password.',
          ),
        );
      }

      passwordGroups.putIfAbsent(password, () => []).add(entry);

      final changedAt = entry.updatedAt ?? entry.createdAt;
      if (changedAt != null &&
          currentTime.difference(changedAt) > oldPasswordThreshold) {
        issues.add(
          CredentialIssue(
            type: CredentialIssueType.oldPassword,
            severity: CredentialIssueSeverity.warning,
            model: entry,
            title: 'Old password',
            detail: '"${_entryTitle(entry)}" has not changed in over 180 days.',
          ),
        );
      }
    }

    for (final group
        in passwordGroups.values.where((group) => group.length > 1)) {
      for (final entry in group) {
        issues.add(
          CredentialIssue(
            type: CredentialIssueType.reusedPassword,
            severity: CredentialIssueSeverity.danger,
            model: entry,
            title: 'Reused password',
            detail:
                '"${_entryTitle(entry)}" shares a password with another entry.',
          ),
        );
      }
    }

    issues.sort((a, b) {
      final severity = b.severity.index.compareTo(a.severity.index);
      if (severity != 0) return severity;
      return a.title.compareTo(b.title);
    });
    return issues;
  }

  static String? validateExportPassphrase(String passphrase) {
    if (passphrase.length < 12) {
      return 'Use at least 12 characters for this passphrase.';
    }
    if (PasswordStrengthUtil.score(passphrase) < 0.5) {
      return 'Use a stronger passphrase before exporting secrets.';
    }
    return null;
  }

  static bool _isValidBase32Secret(String secret) {
    if (secret.length < 8) return false;
    if (!RegExp(r'^[A-Z2-7]+=*$').hasMatch(secret)) return false;
    try {
      TOTP(secret: secret).now();
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _entryTitle(PasswordModel model) {
    final title = model.title?.trim();
    return title == null || title.isEmpty ? 'Untitled' : title;
  }
}
