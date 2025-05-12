import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
  In this class we define all theme-related properties of widgets
 */
class MyThemeData {
  static Color primaryColor = CupertinoColors.systemBlue;
  static Color secondaryColor = CupertinoColors.systemTeal;
  static Color backgroundColor = CupertinoColors.extraLightBackgroundGray;
  static Color dividerColor = CupertinoColors.lightBackgroundGray;
  static Color white = CupertinoColors.white;

  static ThemeData appTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    secondaryHeaderColor: secondaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: white,
    dividerColor: dividerColor,

    appBarTheme:  AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: white,
    ),

    bottomNavigationBarTheme:  BottomNavigationBarThemeData(
      backgroundColor: white, // Background of the navigation bar
      selectedItemColor: primaryColor, // Active icon/text color
      unselectedItemColor: dividerColor, // Inactive icon/text color
      selectedIconTheme: IconThemeData(size: 28, color: primaryColor), // Size of selected icon
      unselectedIconTheme: IconThemeData(size: 24), // Size of unselected icon
      showSelectedLabels: true,
      type: BottomNavigationBarType.fixed, // Prevent shifting animation
    ),

    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor, // Button color
      textTheme: ButtonTextTheme.primary,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor, // Color of the FAB
      foregroundColor: white, // Icon/text color
      elevation: 6, // Shadow depth
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),

    iconTheme: IconThemeData(
      size: 20,
      color: primaryColor,
      opacity:0.9,
    ),

    //theme for input fields
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: primaryColor,
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
      backgroundColor: WidgetStateProperty.all(white),
      // Wrap color in MaterialStateProperty.all
      elevation: WidgetStateProperty.all(2.0),
      // Shadow/elevation
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0), // Rounded corners
        ),
      ),
      overlayColor:
          WidgetStateProperty.all(dividerColor), // Hover effect color
    ),
  );
}
