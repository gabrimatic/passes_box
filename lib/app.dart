import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passes_box/view/home.dart';

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
            HomePage(),
        title: 'Passes Box',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: appOrangeColor,
          primaryColor: appGrayColor,
          primaryColorDark: appGrayColor,
        ),
      );
}
