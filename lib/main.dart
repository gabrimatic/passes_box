import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passes_box/core/values/colors.dart';
import 'package:passes_box/repository/db.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appOpenDatabase();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: appColor4));
  runApp(PassesBoxApp());
}