import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:eusc_freaks/router.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EuscFreaks());
}

class EuscFreaks extends StatelessWidget {
  const EuscFreaks({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      primaryColor: Colors.black,
      primarySwatch: Colors.grey,
      backgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(secondary: Colors.black),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.grey[200],
      errorColor: Colors.red[400],
      primaryColorDark: Colors.black,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 55,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: Colors.black);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black,
        minLeadingWidth: 5,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.grey,
      primaryColorDark: Colors.grey[100],
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.dark(secondary: Colors.white),
      backgroundColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey[900],
      errorColor: Colors.red[400],
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.black,
        elevation: 0,
        height: 55,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
    );

    return ProviderScope(
      child: QueryBowlScope(
        bowl: QueryBowl(),
        child: AdaptiveTheme(
          light: theme,
          dark: darkTheme,
          initial: AdaptiveThemeMode.system,
          builder: (light, dark) => MaterialApp.router(
            title: 'Eusc Freaks',
            theme: light,
            darkTheme: dark,
            routerConfig: routerConfig,
          ),
        ),
      ),
    );
  }
}
