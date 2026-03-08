import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_auth/otp_auth.dart';

class TotpWidget extends StatefulWidget {
  final String secret;

  const TotpWidget({super.key, required this.secret});

  @override
  State<TotpWidget> createState() => _TotpWidgetState();
}

class _TotpWidgetState extends State<TotpWidget> {
  Timer? _timer;
  String _code = '';
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    try {
      final totp = TOTP(secret: widget.secret);
      final code = totp.now();
      if (mounted) {
        setState(() {
          _code = code;
          _secondsRemaining = totp.remaining;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _code = '------');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsRemaining / 30.0;
    final isUrgent = _secondsRemaining <= 5;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: _code));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TOTP code copied'), duration: Duration(seconds: 2)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                color: isUrgent ? Colors.red : Colors.purple,
                backgroundColor: Colors.purple.shade100,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              TOTP.format(_code),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: isUrgent ? Colors.red : Colors.purple.shade800,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.copy, size: 14, color: Colors.purple.shade400),
          ],
        ),
      ),
    );
  }
}
