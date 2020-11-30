import 'package:flutter/material.dart';
import 'package:passes_box/repository/db.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appOpenDatabase();
  runApp(PassesBoxApp());
}
