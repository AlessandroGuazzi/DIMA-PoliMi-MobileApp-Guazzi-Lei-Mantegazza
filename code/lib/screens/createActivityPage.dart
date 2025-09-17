import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/activity_widgets/forms/AccommodationForm.dart';
import 'package:dima_project/widgets/activity_widgets/forms/AttractionForm.dart';
import 'package:dima_project/widgets/activity_widgets/forms/FlightForm.dart';
import 'package:dima_project/widgets/activity_widgets/forms/TransportForm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateActivityPage extends StatefulWidget {
  CreateActivityPage(
      {super.key, required this.type, required this.trip, databaseService})
      : databaseService = databaseService ?? DatabaseService();

  final DatabaseService databaseService;
  final TripModel trip;
  final String type;

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aggiungi ${translateWidgetType(widget.type)}"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: switch (widget.type) {
          'flight' => FlightForm(
              trip: widget.trip,
              databaseService:
                  widget.databaseService),
          'accommodation' => AccommodationForm(trip: widget.trip),
          'transport' => TransportForm(trip: widget.trip),
          'attraction' => AttractionForm(trip: widget.trip),
          _ => Center(child: Text("Invalid type: ${widget.type}")),
        },
      ),
    );
  }

  String translateWidgetType(String type) {
    switch (type) {
      case 'flight':
        return 'volo';
      case 'accommodation':
        return 'alloggio';
      case 'transport':
        return 'trasporto';
      case 'attraction':
        return 'attrazione';
      default:
        return 'attività';
    }
  }
}
