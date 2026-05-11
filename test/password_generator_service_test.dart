import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:passes_box/core/services/password_generator_service.dart';

void main() {
  test('generated passwords include every selected character class', () {
    final password = PasswordGeneratorService.generatePassword(
      PasswordGeneratorOptions(
        length: 16,
        useUppercase: true,
        useLowercase: true,
        useDigits: true,
        useSymbols: true,
      ),
      random: Random(42),
    );

    expect(password.length, 16);
    expect(password, matches(RegExp(r'[A-Z]')));
    expect(password, matches(RegExp(r'[a-z]')));
    expect(password, matches(RegExp(r'[0-9]')));
    expect(password, matches(RegExp(r'[^A-Za-z0-9]')));
  });

  test('ambiguous characters are excluded when requested', () {
    final password = PasswordGeneratorService.generatePassword(
      PasswordGeneratorOptions(
        length: 64,
        useUppercase: true,
        useLowercase: true,
        useDigits: true,
        useSymbols: false,
        excludeAmbiguous: true,
      ),
      random: Random(7),
    );

    expect(password, isNot(contains(RegExp(r'[0O1Il]'))));
  });

  test('password generation rejects an empty character set', () {
    expect(
      () => PasswordGeneratorService.generatePassword(
        PasswordGeneratorOptions(
          useUppercase: false,
          useLowercase: false,
          useDigits: false,
          useSymbols: false,
        ),
        random: Random(1),
      ),
      throwsArgumentError,
    );
  });
}
