import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme - Fresh, Clean, Organic
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF22C55E),      // Vibrant green
      onPrimary: Colors.white,
      secondary: Color(0xFFF59E0B),    // Warm amber
      onSecondary: Colors.white,
      tertiary: Color(0xFF3B82F6),     // Calm blue
      surface: Color(0xFFF8FAFC),      // Soft grey-white
      onSurface: Color(0xFF0F172A),    // Dark navy
      // background: Color(0xFFF7FEE7),   // Soft mint
      // onBackground: Color(0xFF1E293B), // Slate
      error: Color(0xFFEF4444),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7FEE7),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Color(0xFF0F172A),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Colors.white,
    ),
  );

  // Dark Theme - Deep, Premium, Cosmic
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF86EFAC),      // Soft mint green
      onPrimary: Color(0xFF0F172A),    // Dark navy
      secondary: Color(0xFFFCD34D),    // Soft amber
      onSecondary: Color(0xFF0F172A),
      tertiary: Color(0xFF93C5FD),     // Soft blue
      surface: Color(0xFF0F172A),      // Dark navy
      onSurface: Color(0xFFF1F5F9),    // Light grey
      // background: Color(0xFF0A0F1E),   // Deep cosmic
      // onBackground: Color(0xFFE2E8F0), // Light slate
      error: Color(0xFFF87171),
      onError: Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0F1E),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Color(0xFFF1F5F9),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF86EFAC),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: const Color(0xFF1E293B),
    ),
  );

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}