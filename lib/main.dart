import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/lock_service.dart';
import 'core/values/values.dart';
import 'core/widgets/widgets.dart';
import 'repository/db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await appOpenDatabase();
  appSH = await SharedPreferences.getInstance();

  Get.put(LockService(), permanent: true);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ),
  );

  runApp(const CenterTheWidget(child: PassesBoxApp()));
}
