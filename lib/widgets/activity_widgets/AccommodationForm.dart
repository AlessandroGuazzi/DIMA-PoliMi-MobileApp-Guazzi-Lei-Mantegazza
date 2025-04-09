import 'package:dima_project/models/accomodationModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccommodationForm extends StatefulWidget {
  const AccommodationForm({super.key, required this.trip});

  final TripModel trip;
  //final String type;

  @override
  State<AccommodationForm> createState() => _AccommodationFormState();
}

class _AccommodationFormState extends State<AccommodationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  String title = "";
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  double? cost;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nome alloggio
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Accommodation Name"),
              validator: (value) => value!.isEmpty ? "Enter a name" : null,
            ),
            const SizedBox(height: 20),
        
            // Indirizzo (opzionale)
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Address (optional)"),
            ),
            const SizedBox(height: 20),
        
            // Selezione date
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _startDate != null && _endDate != null
                    ? "${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}"
                    : '',
              ),
              decoration: InputDecoration(
                hintText: 'Select dates',
                prefixIcon: Icon(Icons.date_range),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (_startDate == null || _endDate == null) {
                  return "Please select a date range";
                }
                return null;
              },
              onTap: () => _selectDateRange(context),
            ),
            const SizedBox(height: 20),
        
            // Selezione orario check-in
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _checkInTime != null ? _checkInTime!.format(context) : '',
              ),
              decoration: InputDecoration(
                hintText: 'Check-in Time',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () => _selectTime(context, isCheckIn: true),
            ),
            const SizedBox(height: 20),
        
            // Selezione orario check-out
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _checkOutTime != null ? _checkOutTime!.format(context) : '',
              ),
              decoration: InputDecoration(
                hintText: 'Check-out Time',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () => _selectTime(context, isCheckIn: false),
            ),
            const SizedBox(height: 20),
        
            // Costo (opzionale)
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
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
        
            ElevatedButton(
              onPressed: _submitForm,
              child: Text("Save Accommodation"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTime? tripStartDate = widget.trip.startDate;
    DateTime? tripEndDate = widget.trip.endDate;

    if (tripStartDate == null || tripEndDate == null) {
      return;
    }

    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
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

  Future<void> _selectTime(BuildContext context, {required bool isCheckIn}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = pickedTime;
        } else {
          _checkOutTime = pickedTime;
        }
      });
    }
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }


  void _submitForm(){
    if (_formKey.currentState?.validate() ?? false){
      final accommodation = AccommodationModel(
        name: titleController.text,
        tripId: widget.trip.id,
        checkIn: combineDateAndTime(_startDate!, _checkInTime!),
        checkOut: combineDateAndTime(_endDate! , _checkOutTime!),
        address: addressController.text.isNotEmpty ? addressController.text : null, // Se vuoto, lascia null,
        cost: cost,
        contacts: null,
        type: 'accommodation',
      );
    DatabaseService().
      createActivity(accommodation as AccommodationModel).
      then((value) => Navigator.pop(context, true));

  } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Per favore compila tutti i campi correttamente!')));
    }
  }
}
