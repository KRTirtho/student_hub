import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:catcher/catcher.dart';
import 'package:student_hub/collections/env.dart';
import 'package:student_hub/router.dart';
import 'package:student_hub/utils/crashlytics_handler.dart';
import 'package:student_hub/utils/platform.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  final bindings = WidgetsFlutterBinding.ensureInitialized();
  await Env.configure();
  if (kIsMobile) FlutterNativeSplash.preserve(widgetsBinding: bindings);
  if (!kIsDesktop) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  CatcherOptions debugOptions = CatcherOptions(
    SilentReportMode(),
    [
      ConsoleHandler(),
      CrashlyticsHandler(),
      SnackbarHandler(const Duration(seconds: 2)),
    ],
  );

  CatcherOptions releaseOptions = CatcherOptions(
    SilentReportMode(),
    [CrashlyticsHandler()],
  );

  Catcher(
    rootWidget: const ProviderScope(child: EuscFreaks()),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class EuscFreaks extends HookConsumerWidget {
  const EuscFreaks({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final theme = ThemeData(
      useMaterial3: true,
      primaryColor: Colors.black87,
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[800],
        labelPadding: const EdgeInsets.symmetric(horizontal: 40),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black87,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            elevation: 0),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: true,
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(Colors.black87),
      ),
      listTileTheme: ListTileThemeData(
        minLeadingWidth: 5,
        iconColor: Colors.grey[800]!,
      ),
      cardTheme: const CardTheme(
        elevation: 0.5,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        elevation: 0,
        height: 55,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.black87,
        secondary: Colors.black87,
        background: Colors.white,
        onBackground: Colors.black87,
        error: Colors.red[400]!,
        inversePrimary: Colors.white,
        onPrimary: Colors.white,
        onError: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.grey[800]!,
        surface: Colors.grey[50]!,
      ).copyWith(background: Colors.white),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      primaryColor: Colors.grey[100]!,
      scaffoldBackgroundColor: Colors.black,
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.black,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(Colors.grey[100]!),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.grey[800]!,
        unselectedLabelColor: Colors.grey[100]!,
        labelPadding: const EdgeInsets.symmetric(horizontal: 40),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100]!,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100]!,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: true,
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(Colors.grey[100]!),
      ),
      listTileTheme: ListTileThemeData(
        minLeadingWidth: 5,
        iconColor: Colors.grey[100]!,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
      ),
      cardTheme: const CardTheme(elevation: 0),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.black,
        elevation: 0,
        height: 55,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.grey[100]!,
        secondary: Colors.grey[100]!,
        background: Colors.black,
        onBackground: Colors.grey[100]!,
        error: Colors.red[400]!,
        inversePrimary: Colors.black,
        onPrimary: Colors.black,
        onError: Colors.grey[100]!,
        onSecondary: Colors.black,
        onSurface: Colors.grey[100]!,
        surface: Colors.grey[900]!,
      ).copyWith(background: Colors.black),
    );

    return QueryBowlScope(
      bowl: QueryBowl(),
      child: AdaptiveTheme(
        light: theme,
        dark: darkTheme,
        initial: AdaptiveThemeMode.system,
        builder: (light, dark) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: Env.applicationDisplayName,
          theme: light,
          darkTheme: dark,
          routerConfig: ref.watch(routerConfig),
        ),
      ),
    );
  }
}
