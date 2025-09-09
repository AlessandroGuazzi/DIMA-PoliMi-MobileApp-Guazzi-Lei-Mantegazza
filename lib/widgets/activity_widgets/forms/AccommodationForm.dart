import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/CurrencyService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/CountryToCurrency.dart';
import 'package:dima_project/utils/PlacesType.dart';
import 'package:dima_project/widgets/search_bottom_sheets/placesSearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccommodationForm extends StatefulWidget {
  AccommodationForm({
    super.key,
    required this.trip,
    this.accommodation,
    databaseService,
    currencyService,
  })  : databaseService = databaseService ?? DatabaseService(),
        currencyService = currencyService ?? CurrencyService();

  final DatabaseService databaseService;
  final CurrencyService currencyService;
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
  TimeOfDay _checkInTime = const TimeOfDay(hour: 15, minute: 00);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 11, minute: 00);
  num? cost;
  String _selectedCurrency = 'EUR';
  late List<String> _currencies;

  @override
  void initState() {
    super.initState();
    final activity = widget.accommodation;

    //intialize list of currencies
    _currencies = CountryToCurrency().initializeCurrencies(widget.trip.nations);

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
              key: const Key('nameField'),
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
              key: const Key('addressField'),
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
              key: const Key('datesField'),
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
                      labelText: 'Check-in',
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
                      labelText: 'Check-out',
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
              key: const Key('costField'),
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
                        child: CountryToCurrency()
                            .formatPopularCurrencies(currency),
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
              key: const Key('add_button'),
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
        initialTime: isCheckIn ? _checkInTime : _checkOutTime);

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
    setState(() {
      titleController.text = accommodation['name'] ?? '';
      addressController.text = accommodation['other_info'] ?? '';
    });
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('Form submitted');
      //convert currency to 'EUR' for consistency
      if (_selectedCurrency != 'EUR' && cost != null) {
        try {
          num currencyExchange =
              await widget.currencyService.getExchangeRate(_selectedCurrency, 'EUR');
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
      print('Name after: ${titleController.text}');

      final updatedAccommodation = AccommodationModel(
        id: widget.accommodation?.id,
        name: titleController.text,
        tripId: widget.trip.id,
        checkIn: combineDateAndTime(_startDate!, _checkInTime),
        checkOut: combineDateAndTime(_endDate!, _checkOutTime),
        address:
            addressController.text.isNotEmpty ? addressController.text : null,
        expenses: cost != null ? double.parse(cost!.toStringAsFixed(2)) : null,
        contacts: null,
        type: 'accommodation',
      );
      final db = widget.databaseService;
      if (widget.accommodation == null) {
        db
            .createActivity(updatedAccommodation)
            .then((_) => Navigator.pop(context, true));
      } else {
        final oldCost = widget.accommodation!.expenses ?? 0;
        final newCost = updatedAccommodation.expenses ?? 0;
        final diff = (newCost - oldCost).abs();
        final isAdd = newCost > oldCost;

        db
            .updateActivity(
                widget.accommodation!.id!, updatedAccommodation, diff, isAdd)
            .then((_) => Navigator.pop(context, true));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Per favore compila tutti i campi correttamente!')));
    }
  }





  //methods necessary for testing purposes
  @visibleForTesting
  set startDate(DateTime? value) {
    setState(() {
      _startDate = value;
    });
  }

  @visibleForTesting
  set endDate(DateTime? value) {
    setState(() {
      _endDate = value;
    });
  }
}
