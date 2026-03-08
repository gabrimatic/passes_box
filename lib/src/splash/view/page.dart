import 'package:flutter/foundation.dart';
import '../../../core/index.dart';
import '../../home/view/page.dart';

class SplashPage extends StatefulWidget {
  static const name = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  int _lockoutSecondsRemaining = 0;
  Timer? _countdownTimer;

  bool get _isLockedOut {
    if (_lockoutUntil == null) return false;
    return DateTime.now().isBefore(_lockoutUntil!);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isLockedOut) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _lockoutSecondsRemaining = 0;
          });
          _authenticate();
        }
        return;
      }
      if (mounted) {
        setState(() {
          _lockoutSecondsRemaining =
              _lockoutUntil!.difference(DateTime.now()).inSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Align(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 84,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 220,
                    ),
                  ),
                  const Text(
                    'Passes Box',
                    style: TextStyle(
                      color: appColor2,
                      fontSize: 28,
                    ),
                  ),
                  if (_lockoutSecondsRemaining > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Too many attempts. Try again in ${_lockoutSecondsRemaining}s.',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Version $appVersion',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _authenticate);
  }

  Future<void> _authenticate() async {
    if (_isLockedOut) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      if (mounted) {
        setState(() {
          _lockoutSecondsRemaining = remaining;
        });
      }
      return;
    }

    final auth = kIsWeb || !GetPlatform.isMobile
        ? false
        : appSH.getBool('auth') ?? false;
    if (!auth) {
      Get.offAllNamed(HomePage.name);
      return;
    }

    final didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate to access passwords.',
    );
    if (didAuthenticate) {
      LockService.to.unlock();
      Get.offAllNamed(HomePage.name);
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
        _failedAttempts = 0;
        if (mounted) {
          setState(() {
            _lockoutSecondsRemaining = 30;
          });
        }
        _startCountdown();
      } else {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), _authenticate);
        }
      }
    }
  }
}
