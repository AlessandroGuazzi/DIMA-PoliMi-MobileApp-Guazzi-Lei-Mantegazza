import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/activity_widgets/AccommodationForm.dart';
import 'package:dima_project/widgets/activity_widgets/AttractionForm.dart';
import 'package:dima_project/widgets/activity_widgets/FlightForm.dart';
import 'package:dima_project/widgets/activity_widgets/TransportForm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key, required this.type, required this.trip});

  final TripModel trip;
  final String type;

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();

  String title = "";
  DateTime? _startDate;
  DateTime? _endDate;



  //ActivityModel activity;
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
          'flight' => FlightForm(trip: widget.trip),
          'accommodation' => AccommodationForm(trip: widget.trip),
          'transport' => TransportForm(trip: widget.trip),
          'attraction' => AttractionForm(trip: widget.trip),
          _ => Center(child: Text("Invalid type: ${widget.type}")),
        },
      ),
    );
  }

// 🛫 Flight
  Widget createFlight(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Flight Name"),
            validator: (value) => value!.isEmpty ? "Enter a flight name" : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Salva i dati
              }
            },
            child: Text("Save Flight"),
          ),
        ],
      ),
    );
  }

// 🚗 Transport
  Widget createTransport(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: "Transport Type"),
            validator: (value) => value!.isEmpty ? "Enter a transport type" : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Company Name"),
            validator: (value) => value!.isEmpty ? "Enter a company name" : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Salva i dati
              }
            },
            child: Text("Save Transport"),
          ),
        ],
      ),
    );
  }

// 🎡 Attraction
  Widget createAttraction(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: "Attraction Name"),
            validator: (value) => value!.isEmpty ? "Enter an attraction name" : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Location"),
            validator: (value) => value!.isEmpty ? "Enter a location" : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Salva i dati
              }
            },
            child: Text("Save Attraction"),
          ),
        ],
      ),
    );
  }


  Future<void> _selectDateRange(BuildContext context) async {
    DateTime? tripStartDate = widget.trip.startDate;
    DateTime? tripEndDate = widget.trip.endDate;

    if (tripStartDate == null || tripEndDate == null) {
      return; // Evita di aprire il picker se le date del viaggio non sono definite
    }

    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      barrierColor: Theme.of(context).primaryColor,
      firstDate: tripStartDate,
      lastDate: tripEndDate,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
    }
  }

}
