import 'dart:async';
import 'package:flutter/services.dart';

class ClipboardService {
  static Timer? _clearTimer;
  static String? _lastCopied;

  static Future<void> copyWithAutoClear(
    String text, {
    Duration delay = const Duration(seconds: 30),
  }) async {
    _lastCopied = text;
    await Clipboard.setData(ClipboardData(text: text));
    _clearTimer?.cancel();
    _clearTimer = Timer(delay, () async {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == _lastCopied) {
        await Clipboard.setData(const ClipboardData(text: ''));
        _lastCopied = null;
      }
    });
  }

  static void cancelAutoClear() {
    _clearTimer?.cancel();
    _clearTimer = null;
    _lastCopied = null;
  }
}
