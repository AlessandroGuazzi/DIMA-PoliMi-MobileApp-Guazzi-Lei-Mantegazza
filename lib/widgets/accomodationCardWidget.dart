import 'package:dima_project/models/accomodationModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Accomodationcardwidget extends StatelessWidget {
  const Accomodationcardwidget(this.accomodation, {super.key});

  final AccommodationModel accomodation;


  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.holiday_village_outlined);
  }
}
