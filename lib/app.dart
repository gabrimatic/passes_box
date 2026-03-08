import 'package:flutter/foundation.dart';

import 'core/index.dart';
import 'core/navigation/get_pages.dart';
import 'src/splash/view/page.dart';

class PassesBoxApp extends StatefulWidget {
  const PassesBoxApp({super.key});

  @override
  State<PassesBoxApp> createState() => _PassesBoxAppState();
}

class _PassesBoxAppState extends State<PassesBoxApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb && GetPlatform.isMobile) {
      LockService.to.resetTimer();
    }
    ever(LockService.to.isLocked, (locked) {
      if (locked) {
        Get.offAllNamed(SplashPage.name);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb && GetPlatform.isMobile) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        LockService.to.lock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PassesBox',
      initialRoute: SplashPage.name,
      getPages: AppPages.getPages,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'raleway',
        colorSchemeSeed: Colors.deepPurple,
        primaryColor: appColor3,
        primaryColorDark: appColor4,
      ),
    );
  }
}
