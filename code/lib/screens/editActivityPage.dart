import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/activity_widgets/forms/AccommodationForm.dart';
import 'package:dima_project/widgets/activity_widgets/forms/AttractionForm.dart';
import 'package:dima_project/widgets/activity_widgets/forms/FlightForm.dart';
import 'package:dima_project/widgets/activity_widgets/forms/TransportForm.dart';
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
        title: Text("Modifica ${translateWidgetType(widget.activity.type)}"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: switch (widget.activity.type) {
          'flight' => FlightForm(trip: widget.trip, flight: widget.activity as FlightModel),
          'accommodation' => AccommodationForm(trip: widget.trip, accommodation: widget.activity as AccommodationModel),
          'transport' => TransportForm(trip: widget.trip, transport: widget.activity as TransportModel),
          'attraction' => AttractionForm(trip: widget.trip, attraction: widget.activity as AttractionModel),
          _ => Center(child: Text("Invalid type: ${widget.activity.type}")),
        },
      ),
    );
  }

  String translateWidgetType(String? type) {
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
