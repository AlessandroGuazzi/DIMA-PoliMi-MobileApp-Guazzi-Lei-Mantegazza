import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/homePage.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/services/googlePlacesService.dart';
import 'package:dima_project/utils/PlacesType.dart';
import 'package:dima_project/widgets/placesSearchWidget.dart';
import 'package:dima_project/widgets/countryPickerWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

import '../models/userModel.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController countriesController = TextEditingController();
  final TextEditingController citiesController = TextEditingController();

  String title = "";
  List<Country> _selectedCountries = [];
  List<Map<String, String>> _selectedCities = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Crea un nuovo viaggio!"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding for all sides
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Title input
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titolo',
                    hintText: 'Inserisci il titolo del viaggio',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Per favore inserisci un titolo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Countries picker input
                TextFormField(
                  controller: countriesController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Che nazioni visiterai?',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (_selectedCountries.isEmpty) {
                      return 'Per favore seleziona almeno una nazione';
                    }
                    return null;
                  },
                  onTap: () {
                    _openCountryPicker();
                  },
                ),

                _selectedCountries.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _selectedCountries.map((country) {
                            return Chip(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              label:
                                  Text('${country.flagEmoji} ${country.name}'),
                              onDeleted: () {
                                setState(() {
                                  _selectedCountries.remove(country);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox(),

                SizedBox(height: 16),

                // City search input
                TextFormField(
                  controller: citiesController,
                  enabled: _selectedCountries.isEmpty ? false : true,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Che città visiterai?',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (_selectedCities.isEmpty) {
                      return 'Per favore inserisci almeno una città';
                    }
                    return null;
                  },
                  onTap: () {
                    _openCitiesSearch();
                  },
                ),

                _selectedCities.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _selectedCities.map((city) {
                            return Chip(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              label: Text(city['place_name'] ?? 'null'),
                              onDeleted: () {
                                setState(() {
                                  _selectedCities.remove(city);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox(),

                SizedBox(height: 16),

                // dates input
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _startDate != null && _endDate != null
                        ? "${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}"
                        : '',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Quando partirai?',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
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
                SizedBox(height: 32),

                // Submit button
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
                  child: Text('Crea il viaggio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCountriesSelected(List<Country> selectedCountries) {
    List<Country> newSelection = List.from(_selectedCountries);
    print('length: ${_selectedCountries.length}');
    //to avoid duplicates & maximum 5 countries due to google api limit
    for (Country country in selectedCountries) {
      if (!newSelection.contains(country) && newSelection.length < 5) {
        newSelection.add(country);
      }
    }
    setState(() {
      _selectedCountries = newSelection;
    });
  }

  void _openCountryPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CountryPickerWidget(_selectedCountries,
            onCountriesSelected: _onCountriesSelected);
      },
    );
  }

  void _onCitySelected(Map<String, String> city) {
    setState(() {
      // Check if the city with the same place_id already exists
      bool exists = _selectedCities.any((existingCity) =>
      existingCity['place_id'] == city['place_id']);

      if (!exists) {
        _selectedCities.add(city);
      }
    });
  }

  void _openCitiesSearch() async {
    List<String> selectedCountryCodes = _selectedCountries.map((country) => country.countryCode).toList();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PlacesSearchWidget(
          selectedCountryCodes: selectedCountryCodes,
          onPlaceSelected: _onCitySelected, type: PlacesType.cities,
        );
      },
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      barrierColor: Theme.of(context).primaryColor,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      UserModel? currentUser =
          await DatabaseService().getUserByUid(AuthService().currentUser!.uid);
      Map<String, dynamic> creatorInfo = {};
      if (currentUser != null) {
        creatorInfo = {
          'id': currentUser.id,
          'username': currentUser.username,
          'profilePic': currentUser.profilePic
        };
      }

      // Insert data into DB

      //first create the right map to insert for countries
      List<Map<String, dynamic>> countriesMap = _selectedCountries
          .map((country) => {
                'name': country.name,
                'flag': country.flagEmoji,
                'code': country.countryCode[0].toLowerCase() +
                    country.countryCode.substring(1),
              })
          .toList();
      //same for cities
      List<Map<String, dynamic>> citiesMap = [];
      for (var city in _selectedCities) {
        String placeId = city['place_id'] ?? '';
        if (placeId.isNotEmpty) {
          try {
            // Fetch coordinates using placeId
            Map<String, double> coordinates = await GooglePlacesService().getCoordinates(placeId);
            citiesMap.add({
              'name': city['place_name'],
              'lat': coordinates['lat'],
              'lng': coordinates['lng'],
            });
          } catch (e) {
            print("Error fetching coordinates for ${city['place_name']}: $e");
          }
        }
      }

      final trip = TripModel(
          title: titleController.text,
          creatorInfo: creatorInfo,
          nations: countriesMap,
          cities: citiesMap,
          startDate: _startDate,
          endDate: _endDate);
      DatabaseService()
          .createTrip(trip)
          .then((value) => Navigator.pop(context, true));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Per favore compila tutti i campi correttamente!')));
    }
  }
}
