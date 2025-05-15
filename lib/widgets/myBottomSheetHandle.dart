import 'package:flutter/material.dart';

class MyBottomSheetHandle extends StatelessWidget {
  const MyBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(200, 15, 200, 15),
      child: Container(
        height: 5,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: const BorderRadius.all(Radius.circular(100)), // Rounded edges
        ),
      ),
    );
  }
}
