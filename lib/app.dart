import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passes_box/view/splash.dart';

import 'core/values/colors.dart';

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
            SplashPage(),
        title: 'Passes Box',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: appColor2,
          primaryColor: appColor3,
          primaryColorDark: appColor4,
        ),
      );
}
