import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/values/colors.dart';
import 'core/values/values.dart';
import 'repository/db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appOpenDatabase();
  appSH = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: appColor4,
    ),
  );

  runApp(PassesBoxApp());
}
