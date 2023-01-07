import 'package:flutter/material.dart';

const primaryColor = Color(0x0FF2C43B8);
const secondaryColor = Color(0xFFF45737);
const tertiaryColor = Color(0xFFB5A7B8);
const backgroundColor = Color(0xFFF5F5F5);
const cardColor = Color(0xFFE9E9EB);

class AppTheme {
  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: secondaryColor,
          onSecondary: Colors.white,
          background: backgroundColor,
          primaryContainer: cardColor,
          tertiary: tertiaryColor),
      iconTheme: const IconThemeData(color: tertiaryColor),
      inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFF0F5),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondaryColor),
              borderRadius: BorderRadius.zero),
          border: InputBorder.none));
}
