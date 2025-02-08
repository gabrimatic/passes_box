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
// Ensure that widget binding is initialized.
  WidgetsFlutterBinding.ensureInitialized();

// If the platform is web, set the path URL strategy.
  if (kIsWeb) {
    setPathUrlStrategy();
  }

  try {
    // Open the app's database.
    await appOpenDatabase();

    // Get the instance of shared preferences.
    appSH = await SharedPreferences.getInstance();
  } catch (e) {
    print('Failed to initialize database or shared preferences: $e');
  }

// Set the system UI overlay style.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ),
  );

// If the platform is web, remove the loader.
  if (kIsWeb) {
    html.document.getElementById("loader")?.remove();
  }

// Run the app.
  runApp(CenterTheWidget(child: PassesBoxApp()));
}
