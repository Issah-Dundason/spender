import 'package:flutter/material.dart';

const primaryColor = Color(0xff2c43b8);
const secondaryColor = Color(0xFFF45737);
const tertiaryColor = Color(0xFFB5A7B8);
const backgroundColor = Color(0xFFF5F5F5);
const cardColor = Color(0xFFE9E9EB);

const appBottomSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10), topRight: Radius.circular(10)));

class AppTheme {
  static final lightTheme = ThemeData(
      fontFamily: 'WorkSans',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: secondaryColor,
          onSecondary: Colors.white,
          background: backgroundColor,
          primaryContainer: cardColor,
          tertiary: tertiaryColor),
      iconTheme: const IconThemeData(color: tertiaryColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
        )
      ),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFF0F5),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: secondaryColor),
              borderRadius: BorderRadius.circular(12)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none)));
}
