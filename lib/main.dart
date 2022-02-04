import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_strategy/url_strategy.dart';

import 'app.dart';
import 'core/values/colors.dart';
import 'core/values/values.dart';
import 'core/widgets/widgets.dart';
import 'repository/db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) setPathUrlStrategy();

  await appOpenDatabase();
  appSH = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: appColor4,
    ),
  );

  if (kIsWeb) {
    html.document.getElementById("loader")?.remove();
  }

  runApp(CenterTheWidget(child: PassesBoxApp()));
}
