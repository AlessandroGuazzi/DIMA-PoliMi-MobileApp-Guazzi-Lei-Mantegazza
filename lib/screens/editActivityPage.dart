import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/activity_widgets/FlightForm.dart';
import 'package:flutter/material.dart';

class EditActivityPage extends StatefulWidget {
  const EditActivityPage({super.key, required this.activity, required this.trip, });
  final ActivityModel activity;
  final TripModel trip;

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.activity.type}"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: switch (widget.activity.type) {
          'flight' => FlightForm(trip: widget.trip, flight: widget.activity as FlightModel),
          //'accommodation' => AccommodationForm(trip: widget.trip),
          //'transport' => TransportForm(trip: widget.trip),
          //'attraction' => AttractionForm(trip: widget.trip),
          _ => Center(child: Text("Invalid type: ${widget.activity.type}")),
        },
      ),
    );
  }
}
