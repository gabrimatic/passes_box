import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

double get appGetWidth => (kIsWeb && Get.width > 600) ? 600 : Get.width;
final localAuth = LocalAuthentication();
late SharedPreferences appSH;
