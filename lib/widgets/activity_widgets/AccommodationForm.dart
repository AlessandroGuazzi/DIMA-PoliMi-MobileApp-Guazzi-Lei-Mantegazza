import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/PlacesType.dart';
import 'package:dima_project/widgets/placesSearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//TODO: address is not really the address yet, but probably we don't care
class AccommodationForm extends StatefulWidget {
  const AccommodationForm({super.key, required this.trip, this.accommodation});

  final AccommodationModel? accommodation; // per la modifica
  final TripModel trip;

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
  num? cost;

  @override
  void initState() {
    super.initState();
    final activity = widget.accommodation;
    if (activity != null) {
      titleController.text = activity.name ?? '';
      addressController.text = activity.address ?? '';
      costController.text = activity.expenses?.toStringAsFixed(2) ?? '';
      cost = activity.expenses ?? 0;

      _startDate = activity.checkIn;
      _endDate = activity.checkOut;

      _checkInTime = TimeOfDay.fromDateTime(activity.checkIn!);
      _checkOutTime = TimeOfDay.fromDateTime(activity.checkOut!);
    }
  }

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
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Dove dormirai?',
                prefixIcon: Icon(Icons.hotel),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Per favore inserisci un'alloggio" : null,
              onTap: () {
                _openAccommodationPicker();
              },
            ),
            const SizedBox(height: 20),

            // Indirizzo
            TextFormField(
              controller: addressController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Indirizzo',
                prefixIcon: Icon(Icons.location_on),
              ),
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
                hintText: 'Seleziona le date',
                prefixIcon: Icon(Icons.date_range),
              ),
              validator: (value) {
                if (_startDate == null || _endDate == null) {
                  return "Per favore seleziona data di arrivo e fine";
                }
                return null;
              },
              onTap: () => _selectDateRange(context),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // Selezione orario check-in
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _checkInTime != null
                          ? _checkInTime!.format(context)
                          : '',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Check-in',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context, isCheckIn: true),
                  ),
                ),
                const SizedBox(width: 20),

                // Selezione orario check-out
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _checkOutTime != null
                          ? _checkOutTime!.format(context)
                          : '',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Check-out',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context, isCheckIn: false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Costo (opzionale)
            TextFormField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Costo',
                prefixIcon: Icon(Icons.euro),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final costValue = double.tryParse(value);
                  if (costValue == null || costValue < 0) {
                    return "Per favore inserisci un costo valido";
                  }
                  cost = costValue;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Aggiungi alloggio'),
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

  Future<void> _selectTime(BuildContext context,
      {required bool isCheckIn}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isCheckIn
          ? _checkInTime ?? TimeOfDay.now()
          : _checkOutTime ?? TimeOfDay.now(),
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

  void _openAccommodationPicker() async {
    List<String> countriesCodes = widget.trip.nations
            ?.map((nation) => nation['code'].toString())
            .toList() ??
        [];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PlacesSearchWidget(
          selectedCountryCodes: countriesCodes,
          onPlaceSelected: _onSelected,
          type: PlacesType.lodging,
        );
      },
    );
  }

  void _onSelected(Map<String, String> accommodation) {
    titleController.text = accommodation['place_name'] ?? '';
    addressController.text = accommodation['other_info'] ?? '';
    setState(() {});
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedAccommodation = AccommodationModel(
        name: titleController.text,
        tripId: widget.trip.id,
        checkIn: combineDateAndTime(_startDate!, _checkInTime!),
        checkOut: combineDateAndTime(_endDate!, _checkOutTime!),
        address:
            addressController.text.isNotEmpty ? addressController.text : null,
        // Se vuoto, lascia null,
        expenses: cost,
        contacts: null,
        type: 'accommodation',
      );
      final db = DatabaseService();
      if (widget.accommodation == null) {
        db.createActivity(updatedAccommodation).then((_) => Navigator.pop(context, true));
      } else {
        final oldCost = widget.accommodation!.expenses ?? 0;
        final newCost = updatedAccommodation.expenses ?? 0;
        final diff = (newCost - oldCost).abs();
        final isAdd = newCost > oldCost;

        db.updateActivity(widget.accommodation!.id!, updatedAccommodation, diff, isAdd).then((_) => Navigator.pop(context, true));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Per favore compila tutti i campi correttamente!')));
    }
  }
}
