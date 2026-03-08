import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/utils/passphrase.dart';
import '../../../core/utils/password_strength.dart';
import '../../../core/values/colors.dart';

class GeneratorSheet extends StatefulWidget {
  final void Function(String password) onGenerated;

  const GeneratorSheet({super.key, required this.onGenerated});

  @override
  State<GeneratorSheet> createState() => _GeneratorSheetState();
}

class _GeneratorSheetState extends State<GeneratorSheet> {
  bool _passphraseMode = false;

  // Character mode options
  int _length = 16;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useDigits = true;
  bool _useSymbols = true;
  bool _excludeAmbiguous = false;

  // Passphrase mode options
  int _wordCount = 4;
  String _separator = '-';

  String _generated = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _generated = _passphraseMode ? _generatePassphrase() : _generatePassword();
    });
  }

  String _generatePassword() {
    const lower = 'abcdefghijkmnopqrstuvwxyz';
    const lowerAmbig = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const upperAmbig = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '23456789';
    const digitsAmbig = '0123456789';
    const symbols = '@#\$&*!?';

    final charset = StringBuffer();
    if (_useLowercase) charset.write(_excludeAmbiguous ? lower : lowerAmbig);
    if (_useUppercase) charset.write(_excludeAmbiguous ? upper : upperAmbig);
    if (_useDigits) charset.write(_excludeAmbiguous ? digits : digitsAmbig);
    if (_useSymbols) charset.write(symbols);

    if (charset.isEmpty) return '';

    final chars = charset.toString();
    final random = Random.secure();
    return List.generate(_length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _generatePassphrase() {
    return PassphraseGenerator.generate(wordCount: _wordCount, separator: _separator);
  }

  @override
  Widget build(BuildContext context) {
    final strength = PasswordStrengthUtil.evaluate(_generated);
    final score = PasswordStrengthUtil.score(_generated);

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Generate Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          // Mode toggle
          Row(
            children: [
              const Text('Passphrase mode'),
              const Spacer(),
              Switch(value: _passphraseMode, onChanged: (v) { setState(() => _passphraseMode = v); _generate(); }),
            ],
          ),
          if (!_passphraseMode) ...[
            // Length slider
            Row(
              children: [
                const Text('Length: '),
                Text('$_length', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _length.toDouble(),
              min: 8, max: 64, divisions: 56,
              label: '$_length',
              onChanged: (v) { setState(() => _length = v.round()); _generate(); },
            ),
            // Charset toggles
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('A–Z'), selected: _useUppercase,
                  onSelected: (v) { setState(() => _useUppercase = v); _generate(); }),
                FilterChip(label: const Text('a–z'), selected: _useLowercase,
                  onSelected: (v) { setState(() => _useLowercase = v); _generate(); }),
                FilterChip(label: const Text('0–9'), selected: _useDigits,
                  onSelected: (v) { setState(() => _useDigits = v); _generate(); }),
                FilterChip(label: const Text('#@!'), selected: _useSymbols,
                  onSelected: (v) { setState(() => _useSymbols = v); _generate(); }),
                FilterChip(label: const Text('No ambiguous'), selected: _excludeAmbiguous,
                  onSelected: (v) { setState(() => _excludeAmbiguous = v); _generate(); }),
              ],
            ),
          ] else ...[
            // Word count slider
            Row(
              children: [
                const Text('Words: '),
                Text('$_wordCount', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _wordCount.toDouble(),
              min: 3, max: 8, divisions: 5,
              label: '$_wordCount',
              onChanged: (v) { setState(() => _wordCount = v.round()); _generate(); },
            ),
            // Separator
            Row(
              children: [
                const Text('Separator: '),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('-'), selected: _separator == '-',
                  onSelected: (_) { setState(() => _separator = '-'); _generate(); }),
                const SizedBox(width: 4),
                ChoiceChip(label: const Text('.'), selected: _separator == '.',
                  onSelected: (_) { setState(() => _separator = '.'); _generate(); }),
                const SizedBox(width: 4),
                ChoiceChip(label: const Text('_'), selected: _separator == '_',
                  onSelected: (_) { setState(() => _separator = '_'); _generate(); }),
                const SizedBox(width: 4),
                ChoiceChip(label: const Text(' '), selected: _separator == ' ',
                  onSelected: (_) { setState(() => _separator = ' '); _generate(); }),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _generated,
              style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          // Strength bar (only in password mode)
          if (!_passphraseMode) ...[
            LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(PasswordStrengthUtil.color(strength)),
            ),
            const SizedBox(height: 2),
            Text(
              PasswordStrengthUtil.label(strength),
              style: TextStyle(fontSize: 12, color: PasswordStrengthUtil.color(strength)),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                  onPressed: _generate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Use This'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor2,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    widget.onGenerated(_generated);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
