import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/values/colors.dart';
import 'repository/db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appOpenDatabase();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: appColor4,
    ),
  );
  runApp(PassesBoxApp());
}
