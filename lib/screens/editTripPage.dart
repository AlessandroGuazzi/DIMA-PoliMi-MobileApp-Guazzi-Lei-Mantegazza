import 'package:country_picker/country_picker.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';

class EditTripPage extends StatefulWidget {
  const EditTripPage({super.key, required this.trip});

  final TripModel trip;

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.trip.title);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica viaggio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo del viaggio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci un titolo valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Salva'),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedTrip = TripModel(
        id: widget.trip.id,
        creatorInfo: widget.trip.creatorInfo,
        title: titleController.text.trim(),
        nations: widget.trip.nations,
        cities: widget.trip.cities,
        startDate: widget.trip.startDate,
        endDate: widget.trip.endDate,
        activities: widget.trip.activities,
        expenses: widget.trip.expenses,
        isConfirmed: widget.trip.isConfirmed,
        isPast: widget.trip.isPast,
        isPrivate: widget.trip.isPrivate,
        saveCounter: widget.trip.saveCounter,
        timestamp: widget.trip.timestamp,
        imageRef: widget.trip.imageRef,
      );

      DatabaseService().updateTrip(updatedTrip);

      // opzionale: tornare indietro o mostrare conferma
      Navigator.pop(context, updatedTrip);
    }
  }


}
