import 'package:flutter/cupertino.dart';

class ScreenSize {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static isTablet(BuildContext context) => MediaQuery.of(context).size.shortestSide >= 600 ? true : false;
}