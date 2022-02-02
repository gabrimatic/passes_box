import 'package:flutter/foundation.dart';

import '../../../core/index.dart';
import '../../home/view/page.dart';

class SplashPage extends StatefulWidget {
  static const name = '/';

  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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
                  )
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

/* -------------------------------------------------------------------------- */
/*                                   @CODES                                   */
/* -------------------------------------------------------------------------- */
  @override
  void initState() {
    super.initState();
    _config();
  }

  void _config() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      timer.cancel();
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    final auth = kIsWeb || !GetPlatform.isMobile
        ? false
        : appSH.getBool('auth') ?? false;
    if (!auth) {
      Get.offAllNamed(HomePage.name);
      return;
    }

    final didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate to access passwords.',
      biometricOnly: true,
    );
    if (didAuthenticate) {
      Get.offAllNamed(HomePage.name);
    }
  }
}
