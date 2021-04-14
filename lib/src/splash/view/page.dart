import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/values/colors.dart';
import '../../../core/values/strings.dart';
import '../../home/view/home.dart';

class SplashPage extends StatefulWidget {
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
                    child: Image.asset('assets/images/icons/logo_trans.png'),
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
    Timer.periodic(const Duration(milliseconds: 1150), (timer) {
      timer.cancel();
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    const storage = FlutterSecureStorage();
    final auth = await storage.read(key: 'auth');
    if (auth == null) {
      Get.offAll(HomePage());
      return;
    }

    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate to access passwords.',
      biometricOnly: true,
    );
    if (didAuthenticate) Get.offAll(HomePage());
  }
}
