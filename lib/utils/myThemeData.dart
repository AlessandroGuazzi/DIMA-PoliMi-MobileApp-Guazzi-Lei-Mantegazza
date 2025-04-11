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

    //theme for input fields
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Color(0xFF6200EE), // Or use Theme.of(context).primaryColor if dynamic
          width: 2,
        ),
      ),
      prefixIconColor: Colors.grey[700], // optional
      labelStyle: TextStyle(color: Colors.grey[700]), // optional
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 57, fontWeight: FontWeight.bold, color: Colors.black),
      // H1
      displayMedium: TextStyle(
          fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black),
      // H2
      displaySmall: TextStyle(
          fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
      // H3
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      // H4
      headlineMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
      // H5
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      // H6
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
      // Title
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      // Subtitle 1
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
      // Subtitle 2
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87),
      // Body 1
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87),
      // Body 2
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black54),
      // Caption
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
      // Button
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
      // Overline
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black54), // Smallest text
    ),

    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(Colors.white),  // Wrap color in MaterialStateProperty.all
      elevation: WidgetStateProperty.all(2.0),  // Shadow/elevation
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0), // Rounded corners
        ),
      ),
      overlayColor: WidgetStateProperty.all(Colors.grey[300]), // Hover effect color
    ),

  );
}
