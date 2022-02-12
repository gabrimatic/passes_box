import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

double get appGetWidth => (kIsWeb && Get.width > 600) ? 600 : Get.width;
final localAuth = LocalAuthentication();
late SharedPreferences appSH;

String get kKey {
  const keyList = [
    115,
    73,
    56,
    74,
    48,
    77,
    98,
    53,
    65,
    106,
    52,
    106,
    74,
    100,
    53,
    80,
    118,
    53,
    78,
    103,
    57,
    85,
    55,
    53,
    54,
    102,
    113,
    53,
    108,
    76,
    105,
    73,
  ];
  final list = Uint8List.fromList(keyList);
  return String.fromCharCodes(list);
}
