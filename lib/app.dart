import 'package:flutter/foundation.dart';

import 'core/index.dart';
import 'core/navigation/get_pages.dart';
import 'src/startup/vault_recovery_page.dart';
import 'src/splash/view/page.dart';

class PassesBoxApp extends StatefulWidget {
  final VaultOpenException? startupIssue;

  const PassesBoxApp({super.key, this.startupIssue});

  @override
  State<PassesBoxApp> createState() => _PassesBoxAppState();
}

class _PassesBoxAppState extends State<PassesBoxApp>
    with WidgetsBindingObserver {
  late final Worker _lockWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb && GetPlatform.isMobile) {
      LockService.to.resetTimer();
    }
    _lockWorker = ever(LockService.to.isLocked, (locked) {
      if (locked) {
        Get.offAllNamed(SplashPage.name);
      }
    });
  }

  @override
  void dispose() {
    _lockWorker.dispose();
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
    final startupIssue = widget.startupIssue;
    final pages = startupIssue == null
        ? AppPages.getPages
        : AppPages.getPages
            .where((page) => page.name != SplashPage.name)
            .toList();

    return Listener(
      onPointerDown: (_) => _recordActivity(),
      onPointerMove: (_) => _recordActivity(),
      child: GetMaterialApp(
        title: 'PassesBox',
        initialRoute: startupIssue == null ? SplashPage.name : null,
        home: startupIssue == null
            ? null
            : VaultRecoveryPage(issue: startupIssue),
        getPages: pages,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'raleway',
          scaffoldBackgroundColor: appBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: appColor2,
            brightness: Brightness.light,
          ).copyWith(
            primary: appColor2,
            secondary: appColor3,
            surface: appSurface,
            error: appDanger,
          ),
          primaryColor: appColor3,
          primaryColorDark: appColor4,
          appBarTheme: const AppBarTheme(
            backgroundColor: appBackground,
            foregroundColor: appTextPrimary,
            elevation: 0,
            centerTitle: false,
          ),
          bottomAppBarTheme: const BottomAppBarThemeData(
            color: appSurface,
            elevation: 0,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: appSurface,
            surfaceTintColor: appSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          cardTheme: CardThemeData(
            color: appSurface,
            elevation: 0,
            surfaceTintColor: appSurface,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: appBorder),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: appSurface,
            selectedColor: appSurfaceMuted,
            side: const BorderSide(color: appBorder),
            labelStyle: const TextStyle(color: appTextPrimary),
            secondaryLabelStyle: const TextStyle(color: appColor3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: appColor2,
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: appSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: appBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: appBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: appColor2, width: 1.4),
            ),
          ),
        ),
      ),
    );
  }

  void _recordActivity() {
    if (!kIsWeb && GetPlatform.isMobile) {
      LockService.to.resetTimer();
    }
  }
}
