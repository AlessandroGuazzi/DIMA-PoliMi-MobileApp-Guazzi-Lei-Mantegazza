import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/services/databaseService.dart';

class AttractionForm extends StatefulWidget {
  final TripModel trip;
  const AttractionForm({super.key, required this.trip});

  @override
  State<AttractionForm> createState() => _AttractionFormState();
}

class _AttractionFormState extends State<AttractionForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> attractionTypes = [
    'Museo',
    'Ristorante',
    'Concerto',
    'Stadio',
    'Parco Naturale',
    'Monumento',
    'Montagna',
    'Altro'
  ];
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Name
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
              validator: (value) => value!.isEmpty ? "Enter a name" : null,
            ),
            const SizedBox(height: 20),

            // Activity Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: attractionTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(iconSelector(type)),
                      SizedBox(width: ScreenSize.screenWidth(context) * 0.02,),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: "Activity Type",
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) => value == null ? "Select an activity type" : null,
              onChanged: (value) => setState(() {
                _selectedType = value;
              }),
            ),
            const SizedBox(height: 20),

            // Address
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address (optional)"),
            ),
            const SizedBox(height: 20),

            // Cost
            TextFormField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cost (optional)",
                prefixIcon: Icon(Icons.euro),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return "Enter a valid cost";
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Start Date
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

            // Selezione orario inizio
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _startTime != null ? _startTime!.format(context) : '',
              ),
              decoration: InputDecoration(
                hintText: 'Start Time',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () => _selectTime(context, isStartTime: true),
            ),
            const SizedBox(height: 20),

            // Selezione orario fine
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _endTime != null ? _endTime!.format(context) : '',
              ),
              decoration: InputDecoration(
                hintText: 'End Time',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () => _selectTime(context, isStartTime: false),
            ),
            const SizedBox(height: 20),



            // Description
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description (optional)"),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _submitForm,
              child: const Text("Save Attraction"),
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


  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }



  DateTime combine(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final attraction = AttractionModel(
        name: nameController.text,
        tripId: widget.trip.id,
        attractionType: _selectedType!,
        address: addressController.text.isNotEmpty ? addressController.text : null,
        cost: costController.text.isNotEmpty ? double.tryParse(costController.text) ?? 0 : 0,
        startDate: combine(_startDate!, _startTime!),
        endDate: combine(_endDate!, _endTime!),
        description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
        type: "attraction",
      );

      DatabaseService()
          .createActivity(attraction)
          .then((_) => Navigator.pop(context, true));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
    }
  }

  // Scelta icona
  IconData iconSelector(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'museo':
        return Icons.museum;
      case 'ristorante':
        return Icons.restaurant;
      case 'concerto':
        return Icons.music_note;
      case 'stadio':
        return Icons.stadium;
      case 'parco naturale':
        return Icons.park;
      case 'monumento':
        return Icons.account_balance;
      case 'montagna':
        return Icons.terrain;
      default:
        return Icons.photo;
    }
  }


}
