import 'package:flutter/material.dart';
import 'package:spartmay/core/constants/color_constants.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primaryColor: ColorPalette.primaryGreen,
    scaffoldBackgroundColor: ColorPalette.backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorPalette.primaryGreen,
      primary: ColorPalette.primaryGreen,
      secondary: ColorPalette.secondaryGreen,
    ),
    useMaterial3: true,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black, 
        fontSize: 18, 
        fontWeight: FontWeight.bold
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorPalette.primaryGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: ColorPalette.textGrey),
      prefixIconColor: ColorPalette.textDark,
    ),
  );
}