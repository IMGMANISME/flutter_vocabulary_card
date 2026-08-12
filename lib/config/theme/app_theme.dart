import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final textTheme = GoogleFonts.dmSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: brightness,
        primary: colors.actionFillEnd,
        secondary: colors.accent,
        surface: colors.panel,
      ),
      scaffoldBackgroundColor: colors.pageTop,
      textTheme: textTheme.apply(
        bodyColor: colors.ink,
        displayColor: colors.ink,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
