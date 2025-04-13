import 'package:flutter/material.dart';

/*
  In this class we define all theme-related properties of widgets
 */
class MyThemeData {
  static ThemeData appTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6200EE),
    secondaryHeaderColor: const Color(0xFF03DAC6),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: const Color(0xFFFFFFFF),
    dividerColor: Colors.grey.shade300,

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6200EE),
      foregroundColor: Colors.white,
    ),

    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF6200EE), // Button color
      textTheme: ButtonTextTheme.primary,
    ),

    iconTheme: IconThemeData(
      size: 20,
      color: const Color(0xFF6200EE),
      opacity:0.9,
    ),

    //theme for input fields
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Color(0xFF6200EE),
          width: 2,
        ),
      ),
      prefixIconColor: Colors.grey[700], // optional
      labelStyle: TextStyle(color: Colors.grey[700]), // optional
    ),

    //theme for text
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        // Page titles
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.0,
      ),
      headlineLarge: const TextStyle(
        // Section headers
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: const TextStyle(
        // Card titles / prominent info
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: const TextStyle(
        // Regular headers or list titles
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: const TextStyle(
        // Medium emphasis titles
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: const TextStyle(
        // Primary body text
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodyMedium:  TextStyle(
        // Secondary body or muted info
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.grey[800],
        //height: 1.5,
      ),
      bodySmall: TextStyle(
        // Captions or helper text
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
      ),
      labelLarge: TextStyle(
        // Button text or tags
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),

    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      // Wrap color in MaterialStateProperty.all
      elevation: WidgetStateProperty.all(2.0),
      // Shadow/elevation
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0), // Rounded corners
        ),
      ),
      overlayColor:
          WidgetStateProperty.all(Colors.grey[300]), // Hover effect color
    ),
  );
}
