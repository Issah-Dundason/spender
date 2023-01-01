import 'package:flutter/material.dart';

const primaryColor = Color(0xFF4715E9);
const secondaryColor = Color(0xFFF45737);
const tertiaryColor = Color(0xFFB5A7B8);
const backgroundColor = Color(0xFFE9E9EB);

class AppTheme {
  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: secondaryColor,
          onSecondary: Colors.white,
          tertiary: tertiaryColor));
}
