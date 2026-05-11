import 'dart:math';

class PasswordGeneratorOptions {
  final int length;
  final bool useUppercase;
  final bool useLowercase;
  final bool useDigits;
  final bool useSymbols;
  final bool excludeAmbiguous;

  const PasswordGeneratorOptions({
    this.length = 16,
    this.useUppercase = true,
    this.useLowercase = true,
    this.useDigits = true,
    this.useSymbols = true,
    this.excludeAmbiguous = false,
  });
}

class PasswordGeneratorService {
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _lowercaseSafe = 'abcdefghijkmnopqrstuvwxyz';
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _uppercaseSafe = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _digits = '0123456789';
  static const _digitsSafe = '23456789';
  static const _symbols = r'!@#$%^&*()-_=+[]{};:,.?';

  static String generatePassword(
    PasswordGeneratorOptions options, {
    Random? random,
  }) {
    final rng = random ?? Random.secure();
    final requiredSets = <String>[
      if (options.useLowercase)
        options.excludeAmbiguous ? _lowercaseSafe : _lowercase,
      if (options.useUppercase)
        options.excludeAmbiguous ? _uppercaseSafe : _uppercase,
      if (options.useDigits) options.excludeAmbiguous ? _digitsSafe : _digits,
      if (options.useSymbols) _symbols,
    ];

    if (requiredSets.isEmpty) {
      throw ArgumentError('Select at least one character type.');
    }
    if (options.length < requiredSets.length) {
      throw ArgumentError(
        'Length must fit every selected character type.',
      );
    }

    final allCharacters = requiredSets.join();
    final characters = <String>[
      for (final set in requiredSets) _pick(set, rng),
      for (var i = requiredSets.length; i < options.length; i++)
        _pick(allCharacters, rng),
    ];

    _shuffle(characters, rng);
    return characters.join();
  }

  static String _pick(String characters, Random random) {
    return characters[random.nextInt(characters.length)];
  }

  static void _shuffle(List<String> values, Random random) {
    for (var i = values.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final value = values[i];
      values[i] = values[j];
      values[j] = value;
    }
  }
}
