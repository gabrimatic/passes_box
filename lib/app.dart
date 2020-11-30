import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passes_box/view/home.dart';

class PassesBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetMaterialApp(
      home:
          /*MultiBlocProvider(
          providers: [
            BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
            BlocProvider<AppPasswordCubit>(create: (_) => AppPasswordCubit()),
          ],
          child: HomePage(),
        ),*/
          HomePage());
}
