import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
  In this class we define all theme-related properties of widgets
 */
class MyThemeData {
  static Color primaryColor = const Color(0xFF2C58A8);
  static Color secondaryColor = const Color(0xFF4AACC8);
  static Color backgroundColor = const Color(0xFFF5F5F5);
  static Color dividerColor = const Color(0xFFE0E0E0);
  static Color white = CupertinoColors.white;
  static Color black = CupertinoColors.black;

  static ThemeData getLightTheme({required bool isTablet}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      secondaryHeaderColor: secondaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: white,
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        iconTheme: IconThemeData(
          color: white,
          size: isTablet ? 24 : 20,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
          height: 70,
          backgroundColor: white,
          indicatorColor: primaryColor.withAlpha(10),
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(
              color: black,
              fontWeight: FontWeight.w500,
            ),
          ),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          iconTheme:
              WidgetStateProperty.all(IconThemeData(color: primaryColor))),
      bottomAppBarTheme: BottomAppBarThemeData(
        height: 65,
        color: white,
        elevation: 4,
        shape: const CircularNotchedRectangle(),
      ),
      cardTheme: CardThemeData(
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
        color: black,
        opacity: 0.9,
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIconColor: Colors.grey[700],
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primaryColor,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
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
          fontSize: isTablet ? 24 : 21,
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
        elevation: WidgetStateProperty.all(1),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme({required bool isTablet}) {
    Color white = CupertinoColors.white;
    Color black = CupertinoColors.black;
    Color dividerColor = CupertinoColors.systemGrey5;
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      secondaryHeaderColor: secondaryColor,
      scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
      cardColor: black,
      dividerColor: CupertinoColors.systemGrey5,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CupertinoColors.darkBackgroundGray,
        selectedItemColor: primaryColor,
        unselectedItemColor: CupertinoColors.systemGrey4,
        selectedIconTheme: IconThemeData(size: isTablet ? 30 : 28),
        unselectedIconTheme: IconThemeData(size: isTablet ? 26 : 24),
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: CupertinoColors.darkBackgroundGray, // matches backgroundColor
        elevation: 4,
        shape: CircularNotchedRectangle(),
      ),
      cardTheme: CardThemeData(
        color: black,
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
          foregroundColor: CupertinoColors.white,
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
        color: white,
        opacity: 0.9,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: black,
        filled: true,
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
        prefixIconColor: CupertinoColors.systemGrey3,
        labelStyle: TextStyle(color: CupertinoColors.systemGrey3),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: isTablet ? 36 : 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
          color: white,
        ),
        headlineLarge: TextStyle(
          fontSize: isTablet ? 28 : 24,
          fontWeight: FontWeight.w700,
          color: white,
        ),
        headlineMedium: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleLarge: TextStyle(
          fontSize: isTablet ? 22 : 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleMedium: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        bodyLarge: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: CupertinoColors.systemGrey4,
        ),
        bodyMedium: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.normal,
          color: CupertinoColors.systemGrey3,
        ),
        bodySmall: TextStyle(
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w400,
          color: CupertinoColors.systemGrey2,
        ),
        labelLarge: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: white,
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(black),
        elevation: WidgetStateProperty.all(1),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        overlayColor: WidgetStateProperty.all(CupertinoColors.systemGrey),
      ),
    );
  }
}