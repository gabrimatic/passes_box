import 'core/index.dart';
import 'src/splash/view/page.dart';

class PassesBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => HomeCubit()..loadAll(),
        child: GetMaterialApp(
          home: SplashPage(),
          title: 'PassesBox',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'raleway',
            primarySwatch: Colors.deepPurple,
            accentColor: appColor2,
            primaryColor: appColor3,
            primaryColorDark: appColor4,
          ),
        ),
      );
}
