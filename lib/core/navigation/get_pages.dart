import '../../src/about/page/about_page.dart';
import '../../src/home/controller/home_controller.dart';
import '../../src/home/view/page.dart';
import '../../src/splash/view/page.dart';
import '../index.dart';

class AppPages {
  static var getPages = [
    GetPage(
      name: SplashPage.name,
      page: () => SplashPage(),
    ),
    GetPage(
      name: HomePage.name,
      page: () => HomePage(),
      binding: BindingsBuilder.put(() => HomeController()),
    ),
    GetPage(
      name: AboutPage.name,
      page: () => AboutPage(),
    ),
  ];
}
