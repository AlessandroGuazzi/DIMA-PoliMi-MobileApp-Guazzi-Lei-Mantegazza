import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/activity_widgets/AccommodationForm.dart';
import 'package:dima_project/widgets/activity_widgets/AttractionForm.dart';
import 'package:dima_project/widgets/activity_widgets/FlightForm.dart';
import 'package:dima_project/widgets/activity_widgets/TransportForm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateActivityPage extends StatefulWidget {
  CreateActivityPage({
    super.key, required this.type, required this.trip, databaseService}
      ) : databaseService = databaseService ?? DatabaseService();

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
        title: Text("Create ${widget.type}"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: switch (widget.type) {
          'flight' => FlightForm(trip: widget.trip, databaseService: widget.databaseService), //questo aggiunto solo per il test
          'accommodation' => AccommodationForm(trip: widget.trip),
          'transport' => TransportForm(trip: widget.trip),
          'attraction' => AttractionForm(trip: widget.trip),
          _ => Center(child: Text("Invalid type: ${widget.type}")),
        },
      ),
    );
  }

}
