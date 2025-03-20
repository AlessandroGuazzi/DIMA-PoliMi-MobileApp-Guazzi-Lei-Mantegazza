import 'package:dima_project/models/attractionModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Attractioncardwidget extends StatelessWidget {
  const Attractioncardwidget(this.attraction, {super.key});

  final AttractionModel attraction;

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.add_a_photo_outlined);
  }
}
