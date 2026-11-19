import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.dark,
);

class AppTheme {
  static const Color darkBackground = Color(0xFF101419);
  static const Color darkSurface = Color(0xFF191F26);
  static const Color darkAccent = Color(0xFF8AB4F8);
  static const Color darkSecondaryText = Color(0xFF929DAA);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkAccent,
        onPrimary: darkBackground,
        secondary: darkAccent,
        surface: darkSurface,
        onSurface: Colors.white,
        onSurfaceVariant: darkSecondaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: const TextStyle(color: darkSecondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  static ThemeData light() {
    const background = Color(0xFFF3F6FA);
    const surface = Color(0xFFFFFFFF);
    const accent = Color(0xFF356AC3);
    const secondaryText = Color(0xFF5F6B78);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: accent,
        onPrimary: Colors.white,
        secondary: accent,
        surface: surface,
        onSurface: Color(0xFF17202A),
        onSurfaceVariant: secondaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Color(0xFF17202A),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 2,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: secondaryText),
      ),
    );
  }
}

class ThemeModeToggleButton extends StatelessWidget {
  const ThemeModeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Gunakan light mode' : 'Gunakan dark mode',
          onPressed: () {
            appThemeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
          style: IconButton.styleFrom(
            backgroundColor: colors.onSurface.withValues(alpha: 0.06),
            foregroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              size: 19,
            ),
          ),
        );
      },
    );
  }
}
