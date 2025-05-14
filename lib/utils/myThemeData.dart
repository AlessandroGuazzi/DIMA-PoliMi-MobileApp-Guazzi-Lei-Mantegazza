import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
  In this class we define all theme-related properties of widgets
 */
class MyThemeData {
  static Color primaryColor = CupertinoColors.activeGreen;
  static Color secondaryColor = CupertinoColors.systemPurple;
  static Color backgroundColor = CupertinoColors.extraLightBackgroundGray;
  static Color dividerColor = CupertinoColors.lightBackgroundGray;
  static Color white = CupertinoColors.white;

  static ThemeData getTheme({required bool isTablet}) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      secondaryHeaderColor: secondaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: white,
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryColor,
        unselectedItemColor: dividerColor,
        selectedIconTheme: IconThemeData(size: isTablet ? 30 : 28),
        unselectedIconTheme: IconThemeData(size: isTablet ? 26 : 24),
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 6,
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
          textStyle: TextStyle(
            fontSize: isTablet ? 18 : 14,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 18 : 12,
            horizontal: isTablet ? 32 : 20,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        size: isTablet ? 24 : 20,
        color: primaryColor,
        opacity: 0.9,
      ),
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
        prefixIconColor: Colors.grey[700],
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: isTablet ? 36 : 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineLarge: TextStyle(
          fontSize: isTablet ? 28 : 24,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontSize: isTablet ? 22 : 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.normal,
          color: Colors.grey[800],
        ),
        bodySmall: TextStyle(
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w400,
          color: Colors.grey[600],
        ),
        labelLarge: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(white),
        elevation: WidgetStateProperty.all(2.0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        overlayColor: WidgetStateProperty.all(dividerColor),
      ),
    );
  }
}
