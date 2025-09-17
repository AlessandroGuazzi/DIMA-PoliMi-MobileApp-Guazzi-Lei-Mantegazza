import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget tabletLayout;

  const ResponsiveLayout({super.key, required this.mobileLayout, required this.tabletLayout});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ScreenSize.screenWidth(context) < 700) {
          return mobileLayout;
        } else {
          return tabletLayout;
        }
      },
    );
  }
}