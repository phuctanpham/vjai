import 'package:flutter/material.dart';

/// App theme configurations for Garblo. Colours follow spec T7 › G0: forest
/// green is the one primary action colour per view (D1).
class AppTheme {
  /// accent-primary, warm light.
  static const Color primaryLight = Color(0xFF1F5A2E);

  /// accent-primary, warm dark.
  static const Color primaryDark = Color(0xFF7BC88A);

  static ThemeData get lightTheme => _theme(
        ColorScheme.fromSeed(
          seedColor: primaryLight,
          brightness: Brightness.light,
        ).copyWith(primary: primaryLight, onPrimary: const Color(0xFFFFFFFF)),
      );

  static ThemeData get darkTheme => _theme(
        ColorScheme.fromSeed(
          seedColor: primaryLight,
          brightness: Brightness.dark,
        ).copyWith(primary: primaryDark, onPrimary: const Color(0xFF000000)),
      );

  static ThemeData _theme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
