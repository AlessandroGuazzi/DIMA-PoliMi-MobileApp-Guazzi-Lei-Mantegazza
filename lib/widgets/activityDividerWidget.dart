import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';

class activityDivider extends StatelessWidget {
  const activityDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenSize.screenHeight(context) * 0.06,
      child: VerticalDivider(
        width: ScreenSize.screenWidth(context) * 0.03,
        thickness: 2.5,
      ),
    );
  }
}
