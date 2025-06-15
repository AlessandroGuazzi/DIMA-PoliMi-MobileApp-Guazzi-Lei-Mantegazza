import 'package:dima_project/utils/CountryToCurrency.dart';
import 'package:dima_project/utils/PlacesType.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/services/databaseService.dart';

import '../../services/CurrencyService.dart';
import '../placesSearchWidget.dart';


//TODO: gestire valuta in modifica
class AttractionForm extends StatefulWidget {
  final TripModel trip;
  final AttractionModel? attraction; //per la modifica
  final DatabaseService databaseService;

  AttractionForm({
    super.key, required this.trip, this.attraction, databaseService
  }) : databaseService = databaseService ?? DatabaseService();

  @override
  State<AttractionForm> createState() => _AttractionFormState();
}

class _AttractionFormState extends State<AttractionForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final Map<PlacesType, String> activityTypes = {
    PlacesType.museum: 'Museo',
    PlacesType.restaurant: 'Ristorante',
    PlacesType.stadium: 'Stadio',
    PlacesType.park: 'Parco Naturale',
    PlacesType.zoo: 'Zoo',
    PlacesType.church: 'Chiesa',
    PlacesType.movie_theater: 'Cinema',
    PlacesType.tourist_attraction: 'Attrazione turistica',
  };

  PlacesType _selectedType = PlacesType.tourist_attraction;

  num? cost;
  String _selectedCurrency = 'EUR';
  late List<String> _currencies;

  @override
  void initState() {
    super.initState();
    final attraction = widget.attraction;
    _currencies = CountryToCurrency().initializeCurrencies(widget.trip.nations);
    if (attraction != null) {
      locationController.text = attraction.name!;
      addressController.text = attraction.address ?? '';
      costController.text = attraction.expenses?.toString() ?? '';
      descriptionController.text = attraction.description ?? '';

      _selectedType = PlacesType.values.firstWhere(
        (e) => e.name == attraction.attractionType,
        orElse: () => PlacesType.tourist_attraction,
      );

      if (attraction.startDate != null) {
        _startDate = attraction.startDate;
        _startTime = TimeOfDay.fromDateTime(attraction.startDate!);
      }
      if (attraction.endDate != null) {
        _endDate = attraction.endDate;
        _endTime = TimeOfDay.fromDateTime(attraction.endDate!);
      }
    } else {
      _selectedType = PlacesType.tourist_attraction;
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
            // Activity Type
            DropdownButtonFormField2<PlacesType>(
              value: _selectedType,
              isExpanded: true,
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                )
              ),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                labelText: "Seleziona il tipo di attività",
              ),
              items: activityTypes.entries.map((type) {
                return DropdownMenuItem<PlacesType>(
                  value: type.key,
                  child: Row(
                    children: [
                      Icon(iconSelector(type.value)),
                      const SizedBox(width: 8),
                      Text(type.value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            //Location
            TextFormField(
              controller: locationController,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: "Dove?", prefixIcon: Icon(Icons.location_city)),
              onTap: () {
                _openActivityPicker();
              },
              validator: (value) =>
                  value!.isEmpty ? "Inserisci un luogo" : null,
            ),
            const SizedBox(height: 20),

            // Address
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                  labelText: "Indirizzo", prefixIcon: Icon(Icons.location_on)),
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
                hintText: 'Quando?',
                prefixIcon: Icon(Icons.date_range),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (_startDate == null || _endDate == null) {
                  return "Per favore seleziona delle date";
                }
                return null;
              },
              onTap: () => _selectDateRange(context),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // Selezione orario inizio
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text:
                          _startTime != null ? _startTime!.format(context) : '',
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Inizio',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context, isStartTime: true),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: // Selezione orario fine
                      TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _endTime != null ? _endTime!.format(context) : '',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Fine',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onTap: () => _selectTime(context, isStartTime: false),
                  ),
                )
              ],
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

            // Description
            TextFormField(
              controller: descriptionController,
              decoration:
                  const InputDecoration(labelText: "Descrizione (opzionale)"),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text('Aggiungi attività'),
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
      {required bool isStartTime}) async {
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

  void _openActivityPicker() async {
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
          type: _selectedType,
        );
      },
    );
  }

  void _onSelected(Map<String, String> activity) {
    locationController.text = activity['name'] ?? '';
    addressController.text = activity['other_info'] ?? '';
    setState(() {});
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {

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

      final updatedAttraction = AttractionModel(
        name: locationController.text,
        tripId: widget.trip.id,
        attractionType: _selectedType.name ?? '',
        address:
            addressController.text.isNotEmpty ? addressController.text : null,
        expenses: cost != null ? double.parse(cost!.toStringAsFixed(2)) : null,
        startDate:
            _startTime != null ? combine(_startDate!, _startTime!) : _startDate,
        endDate: _endTime != null ? combine(_endDate!, _endTime!) : _endDate,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        type: "attraction",
      );

      final db = widget.databaseService;
      if (widget.attraction == null) {
        db
            .createActivity(updatedAttraction)
            .then((_) => Navigator.pop(context, true));
      } else {
        final oldCost = widget.attraction!.expenses ?? 0;
        final newCost = updatedAttraction.expenses ?? 0;
        final diff = (newCost - oldCost).abs();
        final isAdd = newCost > oldCost;

        db
            .updateActivity(
                widget.attraction!.id!, updatedAttraction, diff, isAdd)
            .then((_) => Navigator.pop(context, true));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Per favore compila tutti i campi correttamente!')),
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
      case 'zoo':
        return Icons.pets;
      case 'chiesa':
        return Icons.church;
      case 'cinema':
        return Icons.movie;
      default:
        return Icons.attractions;
    }
  }
}
