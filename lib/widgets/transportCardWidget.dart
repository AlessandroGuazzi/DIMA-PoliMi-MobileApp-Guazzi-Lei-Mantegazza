import 'package:dima_project/models/transportModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Transportcardwidget extends StatelessWidget {
  const Transportcardwidget(this.transport, {super.key});

  final TransportModel transport;

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.directions_bus_outlined);
  }
}
