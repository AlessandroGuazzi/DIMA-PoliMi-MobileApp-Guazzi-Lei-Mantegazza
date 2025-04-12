import 'package:dima_project/widgets/airportSearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';

class FlightForm extends StatefulWidget {
  final TripModel trip;

  const FlightForm({super.key, required this.trip});

  @override
  State<FlightForm> createState() => _FlightFormState();
}

class _FlightFormState extends State<FlightForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController departureAirportController = TextEditingController();
  final TextEditingController arrivalAirportController = TextEditingController();
  final TextEditingController flightCompanyController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController expensesController = TextEditingController();

  DateTime? _departureDate;
  TimeOfDay? _departureTime;

  late String departureIata;
  late String departureName;

  late String arrivalIata;
  late String arrivalName;

  @override
  void dispose() {
    departureAirportController.dispose();
    arrivalAirportController.dispose();
    flightCompanyController.dispose();
    durationController.dispose();
    expensesController.dispose();
    super.dispose();
  }


  void _showAirportSearchDialog(TextEditingController controller, bool isDeparture) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isDeparture ? "Select Departure Airport" : "Select Arrival Airport"),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: AirportSearchWidget(
                onAirportSelected: (airport) {
                  controller.text = '${airport.name} (${airport.iata})';
                  if (isDeparture) {
                    departureIata = airport.iata;
                    departureName = airport.name;
                  } else {
                    arrivalIata = airport.iata;
                    arrivalName = airport.name;
                  }
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /*TextFormField(
              controller: departureAirportController,
              decoration: const InputDecoration(labelText: "Departure Airport"),
              validator: (value) => value!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: arrivalAirportController,
              decoration: const InputDecoration(labelText: "Arrival Airport"),
              validator: (value) => value!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),*/

            TextFormField(
              controller: departureAirportController,
              decoration: const InputDecoration(labelText: "Departure Airport"),
              validator: (value) => value!.isEmpty ? "Required" : null,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode()); // Nasconde la tastiera
                _showAirportSearchDialog(departureAirportController, true); // Mostra il dialogo per la scelta aeroporto
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: arrivalAirportController,
              decoration: const InputDecoration(labelText: "Arrival Airport"),
              validator: (value) => value!.isEmpty ? "Required" : null,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode()); // Nasconde la tastiera
                _showAirportSearchDialog(arrivalAirportController, false); // Mostra il dialogo per la scelta aeroporto
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: flightCompanyController,
              decoration: const InputDecoration(labelText: "Flight Company"),
            ),
            const SizedBox(height: 16),

            // Departure Date
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _departureDate != null
                    ? "${DateFormat('dd/MM/yy').format(_departureDate!)}"
                    : '',
              ),
              decoration: const InputDecoration(
                labelText: "Departure Date",
                prefixIcon: Icon(Icons.calendar_today),
              ),

              onTap: () => _pickDate(context),
              validator: (_) => _departureDate == null ? "Select a date" : null,
            ),
            const SizedBox(height: 16),

            // Departure Time
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _departureTime != null ? _departureTime!.format(context) : '',
              ),
              decoration: const InputDecoration(
                labelText: "Departure Time",
                prefixIcon: Icon(Icons.access_time),
              ),
              //initialValue: _departureTime != null ? _departureTime!.format(context) : '',
              onTap: () => _pickTime(context),
              validator: (_) => _departureTime == null ? "Select a time" : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: durationController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Duration (in hours)"),
              validator: (value) {
                if (value == null || value.isEmpty) return "Required";
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) return "Enter a valid positive number";
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: expensesController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Expenses (optional)", prefixIcon: Icon(Icons.euro)),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _submitForm,
              child: const Text("Save Flight"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final startDate = widget.trip.startDate ?? DateTime(2000);
    final endDate = widget.trip.endDate ?? DateTime(2100);

    // Clamp initialDate between startDate and endDate
    final initialDate = now.isBefore(startDate)
        ? startDate
        : now.isAfter(endDate)
        ? endDate
        : now;

    final picked = await showDatePicker(
      context: context,
      firstDate: startDate,
      lastDate: endDate,
      initialDate: initialDate,
    );

    if (picked != null) {
      setState(() => _departureDate = picked);
    }
  }


  //TODO NON MOSTRA IL TIME PICKED
  Future<void> _pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _departureTime = pickedTime;
      });
    }
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final departureDateTime = combineDateAndTime(_departureDate!, _departureTime!);
      final durationHours = double.parse(durationController.text);
      final arrivalDateTime = departureDateTime.add(Duration(minutes: (durationHours * 60).toInt()));

      final flight = FlightModel(
        tripId: widget.trip.id,
        departureAirPort: {
          'name': departureName,
          'iata': departureIata,
        },
        arrivalAirPort: {
          'name': arrivalName,
          'iata': arrivalIata,
        },
        flightCompany: flightCompanyController.text,
        departureDate: departureDateTime,
        arrivalDate: arrivalDateTime,
        duration: durationHours,
        expenses: expensesController.text.isNotEmpty ? double.tryParse(expensesController.text) : null,
        type: 'flight',
      );

      DatabaseService()
          .createActivity(flight)
          .then((_) => Navigator.pop(context, true));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
    }
  }
}
