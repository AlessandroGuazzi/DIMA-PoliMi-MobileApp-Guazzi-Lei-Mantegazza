import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransportForm extends StatefulWidget {
  const TransportForm({super.key, required this.trip, this.transport});

  final TripModel trip;
  final TransportModel? transport; // aggiunto per gestire modifica

  @override
  State<TransportForm> createState() => _TransportFormState();
}

class _TransportFormState extends State<TransportForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController departurePlaceController = TextEditingController();
  final TextEditingController arrivalPlaceController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  String? _selectedType;
  num? cost;

  //final List<String> _transportTypes = ['Bus', 'Train', 'Car', 'Ferry'];
  final Map<String, IconData> _transportIcons = {
    'Bus': Icons.directions_bus,
    'Train': Icons.train,
    'Car': Icons.directions_car,
    'Ferry': Icons.directions_boat,
  };


  @override
  void initState() {
    super.initState();
    final t = widget.transport;
    if (t != null) {
      departurePlaceController.text = t.departurePlace!;
      arrivalPlaceController.text = t.arrivalPlace!;
      _departureDate = t.departureDate;
      _departureTime = TimeOfDay.fromDateTime(t.departureDate!);
      _selectedType = t.transportType;
      if (t.expenses != null) {
        costController.text = t.expenses.toString();
        cost = t.expenses ?? 0;
      }
    }
  }

  @override
  void dispose() {
    departurePlaceController.dispose();
    arrivalPlaceController.dispose();
    costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: departurePlaceController,
              decoration: const InputDecoration(labelText: "Departure Place"),
              validator: (value) => value!.isEmpty ? "Enter departure place" : null,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: arrivalPlaceController,
              decoration: const InputDecoration(labelText: "Arrival Place"),
              validator: (value) => value!.isEmpty ? "Enter arrival place" : null,
            ),
            const SizedBox(height: 20),

            // Date Picker
            GestureDetector(
              onTap: _selectDepartureDate,
              child: AbsorbPointer(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Departure Date",
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'Select date',
                  ),
                  controller: TextEditingController(
                    text: _departureDate != null
                        ? DateFormat('dd/MM/yy').format(_departureDate!)
                        : '',
                  ),
                  validator: (_) => _departureDate == null ? "Select a date" : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Picker
            GestureDetector(
              onTap: _selectDepartureTime,
              child: AbsorbPointer(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Departure Time",
                    prefixIcon: Icon(Icons.access_time),
                    hintText: 'Select time',
                  ),
                  controller: TextEditingController(
                    text: _departureTime != null ? _departureTime!.format(context) : '',
                  ),
                  validator: (_) => _departureTime == null ? "Select a time" : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _transportIcons.keys.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_transportIcons[type], size: 20),
                      const SizedBox(width: 8),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: "Transport Type",
                //prefixIcon: Icon(Icons.directions_transit),
              ),
              validator: (value) => value == null ? "Select a transport type" : null,
              onChanged: (value) => setState(() {
                _selectedType = value;
              }),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cost (optional)",
                prefixIcon: Icon(Icons.euro),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final costValue = double.tryParse(value);
                  if (costValue == null || costValue < 0) {
                    return "Enter a valid positive number";
                  }
                  cost = costValue;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _submitForm,
              child: const Text("Save Transport"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDepartureDate() async {
    final now = DateTime.now();
    final startDate = widget.trip.startDate ?? now;
    final endDate = widget.trip.endDate ?? DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: now.isBefore(startDate)
          ? startDate
          : now.isAfter(endDate)
          ? endDate
          : now,
      firstDate: startDate,
      lastDate: endDate,
    );
    if (picked != null) {
      setState(() => _departureDate = picked);
    }
  }

  Future<void> _selectDepartureTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _departureTime = pickedTime);
    }
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final departureDateTime = combineDateAndTime(_departureDate!, _departureTime!);
      final double? cost = costController.text.isNotEmpty
          ? double.tryParse(costController.text)
          : null;

      final transport = TransportModel(
        tripId: widget.trip.id,
        departurePlace: departurePlaceController.text,
        arrivalPlace: arrivalPlaceController.text,
        departureDate: departureDateTime,
        expenses: cost,
        transportType: _selectedType!,
        type: 'transport'
      );

      final db = DatabaseService();

      if (widget.transport == null) {
        db.createActivity(transport).then((_) => Navigator.pop(context, true));
      } else {
        final oldCost = widget.transport!.expenses ?? 0;
        final newCost = transport.expenses ?? 0;
        final diff = (newCost - oldCost).abs();
        final isAdd = newCost > oldCost;

        db.updateActivity(widget.transport!.id! ,transport, diff, isAdd).then((_) => Navigator.pop(context, true));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
    }
  }
}
