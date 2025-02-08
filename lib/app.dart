import 'core/index.dart';
import 'core/navigation/get_pages.dart';
import 'src/splash/view/page.dart';

class PassesBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PassesBox',
      initialRoute: SplashPage.name,
      getPages: AppPages.getPages,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'raleway',
        primarySwatch: Colors.deepPurple,
        primaryColor: appColor3,
        primaryColorDark: appColor4,
      ),
    );
  }
}
