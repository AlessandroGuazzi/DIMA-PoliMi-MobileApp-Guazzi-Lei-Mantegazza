import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/CurrencyService.dart';
import '../../utils/CountryToCurrency.dart';

class TransportForm extends StatefulWidget {
  TransportForm({
    super.key, required this.trip, this.transport, databaseService
  }) : databaseService = databaseService ?? DatabaseService();

  final DatabaseService databaseService;
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
  String _selectedCurrency = 'EUR';
  late List<String> _currencies;
  Duration? _selectedDuration;
  final TextEditingController _durationController = TextEditingController();


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
    _currencies = CountryToCurrency().initializeCurrencies(widget.trip.nations);

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
      if (t.duration != null) {
        final d = Duration(minutes: t.duration!.toInt());
        _selectedDuration = d;
        _durationController.text = "${d.inHours}h ${d.inMinutes % 60}m";
      }
    }
  }

  @override
  void dispose() {
    departurePlaceController.dispose();
    arrivalPlaceController.dispose();
    costController.dispose();
    _durationController.dispose();
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

            // Costo (opzionale)
            TextFormField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Costo',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: DropdownButton<String>(
                    alignment: Alignment.center,
                    value: _selectedCurrency,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        alignment: Alignment.center,
                        value: currency,
                        child: CountryToCurrency().formatPopularCurrencies(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      }
                    },
                  ),
                ),
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

            TextFormField(
              controller: _durationController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Durata (opzionale)',
                prefixIcon: Icon(Icons.timer),
                hintText: 'Seleziona durata',
              ),
              onTap: () async {
                final duration = await showDialog<Duration>(
                  context: context,
                  builder: (_) => DurationPickerDialog(initialDuration: _selectedDuration ?? const Duration()),
                );
                if (duration != null) {
                  setState(() {
                    _selectedDuration = duration;
                    _durationController.text = "${duration.inHours}h ${duration.inMinutes % 60}m";
                  });
                }
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {

      //convert currency to 'EUR' for consistency
      if(_selectedCurrency != 'EUR' && cost != null) {
        try {
          num currencyExchange = await CurrencyService().getExchangeRate(_selectedCurrency, 'EUR');
          cost = cost! * currencyExchange;
        } catch (e) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Errore'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      }

      final departureDateTime = combineDateAndTime(_departureDate!, _departureTime!);

      final transport = TransportModel(
        tripId: widget.trip.id,
        departurePlace: departurePlaceController.text,
        arrivalPlace: arrivalPlaceController.text,
        departureDate: departureDateTime,
        expenses: cost != null ? double.parse(cost!.toStringAsFixed(2)) : null,
        duration: _selectedDuration?.inMinutes,
        transportType: _selectedType!,
        type: 'transport'
      );

      final db = widget.databaseService;

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



class DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;

  const DurationPickerDialog({Key? key, required this.initialDuration}) : super(key: key);

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late int hours;
  late int minutes;

  @override
  void initState() {
    super.initState();
    hours = widget.initialDuration.inHours;
    minutes = widget.initialDuration.inMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleziona durata'),
      content: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: hours,
              isExpanded: true,
              onChanged: (val) => setState(() => hours = val!),
              items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i h'))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<int>(
              value: minutes,
              isExpanded: true,
              onChanged: (val) => setState(() => minutes = val!),
              items: List.generate(60, (i) => DropdownMenuItem(value: i, child: Text('$i m'))),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, Duration(hours: hours, minutes: minutes)),
          child: const Text('Conferma'),
        ),
      ],
    );
  }
}

