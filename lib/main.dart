import 'package:flutter/material.dart';
import 'package:ujian_projek/routes/app_routes.dart';
import 'package:ujian_projek/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          initialRoute: AppRoute.dragonballLoading,
          routes: AppRoute.routes,
        );
      },
    );
  }
}
