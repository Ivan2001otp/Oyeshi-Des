import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.green[800]!,
        secondary: Colors.amber[700]!,
        surface: Colors.white,
        background: Colors.grey[50]!,
      ));

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        background: Colors.black,
        surface: Colors.grey[900]!,
        secondary: Colors.amber[300]!,
        primary: Colors.green[300]!),
  );

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
