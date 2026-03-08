import 'package:flutter/material.dart';

enum PasswordStrength { weak, fair, strong, veryStrong }

class PasswordStrengthUtil {
  static double score(String password) {
    if (password.isEmpty) return 0.0;

    double score = 0.0;

    // Length scoring (up to 0.4)
    final len = password.length;
    if (len >= 8) score += 0.1;
    if (len >= 12) score += 0.1;
    if (len >= 16) score += 0.1;
    if (len >= 20) score += 0.1;

    // Character variety (up to 0.4)
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSymbol = password.contains(RegExp(r'[^a-zA-Z0-9]'));

    if (hasLower) score += 0.1;
    if (hasUpper) score += 0.1;
    if (hasDigit) score += 0.1;
    if (hasSymbol) score += 0.1;

    // No repeated characters (up to 0.1)
    final uniqueRatio = password.split('').toSet().length / password.length;
    score += uniqueRatio * 0.1;

    // Entropy bonus (up to 0.1): penalize sequential patterns
    var hasSequential = false;
    for (int i = 0; i < password.length - 2; i++) {
      final a = password.codeUnitAt(i);
      final b = password.codeUnitAt(i + 1);
      final c = password.codeUnitAt(i + 2);
      if (b - a == 1 && c - b == 1) {
        hasSequential = true;
        break;
      }
    }
    if (!hasSequential) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  static PasswordStrength evaluate(String password) {
    final s = score(password);
    if (s < 0.3) return PasswordStrength.weak;
    if (s < 0.5) return PasswordStrength.fair;
    if (s < 0.75) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  static Color color(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  static String label(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }
}
