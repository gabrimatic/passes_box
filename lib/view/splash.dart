import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passes_box/core/values/colors.dart';
import 'package:passes_box/core/values/strings.dart';

import 'home.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 1400), (timer) {
      timer.cancel();
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    final storage = new FlutterSecureStorage();
    var auth = await storage.read(key: 'auth');
    if (auth.isNullOrBlank) {
      Get.offAll(HomePage());
      return;
    }

    var localAuth = LocalAuthentication();
    bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to access passwords.');
    if (didAuthenticate) Get.offAll(HomePage());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 64),
                    child: Image.asset('assets/images/icons/logo_trans.png'),
                  ),
                  Text('Passes Box',
                      style: TextStyle(color: appColor2, fontSize: 28))
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Version $appVersion',
                    style: TextStyle(color: Colors.black45, fontSize: 13)),
              ),
            )
          ],
        ),
      );
}
