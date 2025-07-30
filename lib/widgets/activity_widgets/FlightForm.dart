import 'package:dima_project/widgets/search_bottom_sheets/airportSearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';

import '../../services/CurrencyService.dart';
import '../../utils/CountryToCurrency.dart';

class FlightForm extends StatefulWidget {
  final TripModel trip;
  final DatabaseService databaseService;
  final FlightModel? flight; // Se è null → creazione, altrimenti modifica

  FlightForm({
    super.key,
    required this.trip,
    this.flight,
    databaseService,
  }) : databaseService = databaseService ?? DatabaseService();

  @override
  State<FlightForm> createState() => _FlightFormState();
}

class _FlightFormState extends State<FlightForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController departureAirportController = TextEditingController();
  final TextEditingController arrivalAirportController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController expensesController = TextEditingController();

  DateTime? _departureDate;
  TimeOfDay? _departureTime;

  late String departureIata;
  late String departureName;

  late String arrivalIata;
  late String arrivalName;

  num? cost;
  String _selectedCurrency = 'EUR';
  late List<String> _currencies;

  @override
  void initState() {
    super.initState();
    final flight = widget.flight;
    _currencies = CountryToCurrency().initializeCurrencies(widget.trip.nations);
    if (flight != null) {
      departureIata = flight.departureAirPort!['iata']!;
      departureName = flight.departureAirPort!['name']!;
      departureAirportController.text = '$departureName ($departureIata)';

      arrivalIata = flight.arrivalAirPort!['iata']!;
      arrivalName = flight.arrivalAirPort!['name']!;
      arrivalAirportController.text = '$arrivalName ($arrivalIata)';
      durationController.text = flight.duration.toString();
      expensesController.text = flight.expenses?.toStringAsFixed(2) ?? '';

      _departureDate = flight.departureDate;
      _departureTime = TimeOfDay.fromDateTime(flight.departureDate!);
    }
  }

  @override
  void dispose() {
    departureAirportController.dispose();
    arrivalAirportController.dispose();
    //flightCompanyController.dispose();
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

            TextFormField(
              key: const Key('departureAirportField'),
              readOnly: true,
              controller: departureAirportController,
              decoration: const InputDecoration(labelText: "Departure Airport"),
              validator: (value) => value!.isEmpty ? "Required" : null,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                _showAirportSearchDialog(departureAirportController, true);
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              key: const Key('arrivalAirportField'),
              readOnly: true,
              controller: arrivalAirportController,
              decoration: const InputDecoration(labelText: "Arrival Airport"),
              validator: (value) => value!.isEmpty ? "Required" : null,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode()); // Nasconde la tastiera
                _showAirportSearchDialog(arrivalAirportController, false); // Mostra il dialogo per la scelta aeroporto
              },
            ),
            const SizedBox(height: 16),

            /*TextFormField(
              controller: flightCompanyController,
              decoration: const InputDecoration(labelText: "Flight Company (optional)"),
            ),
            const SizedBox(height: 16),*/

            // Departure Date
            TextFormField(
              key: const Key('departureDateField'),
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
              key: const Key('departureTimeField'),
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
              key: const Key('durationField'),
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

            // Costo (opzionale)
            TextFormField(
              key: const Key('costField'),
              controller: expensesController,
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

            ElevatedButton(
              key: const Key('submitButton'),
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
      final durationHours = double.parse(durationController.text);
      final arrivalDateTime = departureDateTime.add(Duration(minutes: (durationHours * 60).toInt()));

      final updatedFlight = FlightModel(
        tripId: widget.trip.id,
        departureAirPort: {
          'name': departureName,
          'iata': departureIata,
        },
        arrivalAirPort: {
          'name': arrivalName,
          'iata': arrivalIata,
        },
        //flightCompany: flightCompanyController.text,
        departureDate: departureDateTime,
        arrivalDate: arrivalDateTime,
        duration: durationHours,
        expenses: cost != null ? double.parse(cost!.toStringAsFixed(2)) : null,
        type: 'flight',
      );

      final db = widget.databaseService;

      if (widget.flight == null) {
        // Caso: creazione
        db.createActivity(updatedFlight).then((_) => Navigator.pop(context, true));
      } else {
        // Caso: modifica
        final oldCost = widget.flight!.expenses ?? 0;
        final newCost = updatedFlight.expenses ?? 0;
        final diff = (newCost - oldCost).abs();
        final isAdd = newCost > oldCost;

        db.updateActivity(widget.flight!.id!, updatedFlight, diff, isAdd).then((_) => Navigator.pop(context, true));
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
    }
  }
}
