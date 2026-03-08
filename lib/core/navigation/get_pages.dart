import '../../src/about/page/about_page.dart';
import '../../src/home/controller/controller.dart';
import '../../src/home/view/page.dart';
import '../../src/qr/qr_import_page.dart';
import '../../src/qr/qr_scan_page.dart';
import '../../src/recycle_bin/page.dart';
import '../../src/splash/view/page.dart';
import '../index.dart';

class AppPages {
  static var getPages = [
    GetPage(
      name: SplashPage.name,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: HomePage.name,
      page: () => const HomePage(),
      binding: BindingsBuilder.put(() => HomeController()),
    ),
    GetPage(
      name: AboutPage.name,
      page: () => const AboutPage(),
    ),
    GetPage(
      name: QrScanPage.name,
      page: () => const QrScanPage(),
    ),
    GetPage(
      name: RecycleBinPage.name,
      page: () => const RecycleBinPage(),
    ),
    GetPage(
      name: QrImportPage.name,
      page: () => const QrImportPage(),
    ),
  ];
}
