import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/services/googlePlacesService.dart';
import 'package:dima_project/utils/PlacesType.dart';
import 'package:dima_project/utils/responsive.dart';
import 'package:dima_project/widgets/placesSearchWidget.dart';
import 'package:dima_project/widgets/countryPickerWidget.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

import '../models/userModel.dart';
import '../utils/screenSize.dart';

class UpsertTripPage extends StatefulWidget {
  final TripModel? trip;
  final bool? isUpdate;
  final DatabaseService databaseService;
  final AuthService authService;
  final GooglePlacesService googlePlacesService;

  UpsertTripPage(
      {super.key,
      this.trip,
      this.isUpdate,
      databaseService,
      authService,
      googlePlacesService})
      : databaseService = databaseService ?? DatabaseService(),
        authService = authService ?? AuthService(),
        googlePlacesService = googlePlacesService ?? GooglePlacesService();

  @override
  State<UpsertTripPage> createState() => _UpsertTripPageState();
}

class _UpsertTripPageState extends State<UpsertTripPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController countriesController = TextEditingController();
  TextEditingController citiesController = TextEditingController();
  TextEditingController datesController = TextEditingController();
  TextEditingController newStartDateController = TextEditingController();
  TextEditingController newEndDateController = TextEditingController();

  String title = "";
  List<Country> _selectedCountries = [];
  List<Map<String, dynamic>> _selectedCities = [];
  List<Map<String, dynamic>> _alreadySelectedCities = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool isLoading = false;
  DateTime? _newStartDate;
  DateTime? _newEndDate;

  @override
  void initState() {
    //meaning that we are in update mode
    if (widget.trip != null) {
      //initialize title
      titleController.text = widget.trip!.title ?? '';
      //initialize countries
      if (widget.trip!.nations != null && widget.trip!.nations!.isNotEmpty) {
        _selectedCountries = widget.trip!.nations!
            .map((nation) => Country.parse(nation['code'].toUpperCase()))
            .whereType<Country>()
            .toList();
      }

      //initialize cities
      if (widget.trip!.cities != null && widget.trip!.cities!.isNotEmpty) {
        _alreadySelectedCities = widget.trip!.cities!;
      }

      //initialize dates
      _startDate = widget.trip!.startDate;
      _newStartDate = _startDate;
      _endDate = widget.trip!.endDate;
      _newEndDate = _endDate;
      if (_newStartDate != null) {
        newStartDateController.text =
            DateFormat('dd/MM/yy').format(_newStartDate!);
      }
      if (_newEndDate != null) {
        newEndDateController.text = DateFormat('dd/MM/yy').format(_newEndDate!);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
          color: Colors.white,
          child: const Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: widget.isUpdate == null || !widget.isUpdate!
              ? const Text("Crea un nuovo viaggio!")
              : const Text("Modifica il tuo viaggio!"),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).secondaryHeaderColor
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              elevation: 8,
              child: ResponsiveLayout(
                  mobileLayout: _buildMobileLayout(),
                  tabletLayout: _buildTabletLayout()),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMobileLayout() {
    if (widget.isUpdate == null || !widget.isUpdate!) {
      //code for insertion
      return _insertionForm();
    } else {
      //code for update
      return _updateForm();
    }
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildMobileLayout(),
            )),
        Expanded(
            flex: 3,
            child: Center(
                child: SizedBox(
                    height: ScreenSize.screenHeight(context) * 0.7,
                    width: ScreenSize.screenHeight(context) * 0.7,
                    child: Image.asset('assets/trip_illustration.png')))),
      ],
    );
  }

  Widget _insertionForm() {
    return Padding(
      padding: const EdgeInsets.all(16), // Padding for all sides
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              !ScreenSize.isTablet(context)
                  ? Image.asset('assets/trip_illustration.png', height: 150, width: 150)
                  : const SizedBox(width: 0, height: 0),
              SizedBox(height: 16),
              // Title input
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titolo',
                  hintText: 'Inserisci il titolo del viaggio',
                  prefixIcon: Icon(Icons.title),
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
                            backgroundColor: Theme.of(context).cardColor,
                            label: Text('${country.flagEmoji} ${country.name}'),
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
                            backgroundColor: Theme.of(context).cardColor,
                            label: Text(city['name'] ?? 'null'),
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
                controller: datesController,
                decoration: InputDecoration(
                  hintText: 'Quando partirai?',
                  prefixIcon: Icon(Icons.date_range),
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
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text('Crea il viaggio'),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _updateForm() {
    return Padding(
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci un titolo';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // City search input
              TextFormField(
                controller: citiesController,
                enabled: _selectedCountries.isEmpty ? false : true,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Aggiungi tappe',
                  prefixIcon: const Icon(Icons.location_city),
                ),
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
                            backgroundColor: Theme.of(context).cardColor,
                            label: Text(city['name'] ?? 'null'),
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

              //start date input
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _newStartDate != null
                      ? DateFormat('dd/MM/yy').format(_newStartDate!)
                      : '',
                ),
                decoration: InputDecoration(
                  labelText: 'Quando partirai?',
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: (value) {
                  if (_newStartDate == null) {
                    return "Per favore seleziona una data di partenza precedente a quella iniziale";
                  }
                  return null;
                },
                onTap: () => _selectStartDate(context),
              ),
              SizedBox(
                height: 16,
              ),

              //end date input
              TextFormField(
                readOnly: true,
                controller: newEndDateController,
                decoration: InputDecoration(
                  labelText: 'Quando tornerai?',
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: (value) {
                  if (_newEndDate == null) {
                    return "Per favore seleziona una data di fine";
                  }
                  return null;
                },
                onTap: () => _selectEndDate(context),
              ),
              SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text('Salva modifiche'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCountriesSelected(List<Country> selectedCountries) {
    List<Country> newSelection = List.from(_selectedCountries);

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
      builder: (BuildContext context) {
        return CountryPickerWidget(
            selectedCountries: _selectedCountries,
            onCountriesSelected: _onCountriesSelected,
            isUserNationality: false);
      },
    );
  }

  void _onCitySelected(Map<String, String> city) {
    setState(() {
      // Check if the city with the same place_id already exists
      bool exists = _selectedCities.any(
              (existingCity) => existingCity['place_id'] == city['place_id']) ||
          _alreadySelectedCities.any(
              (existingCity) => existingCity['place_id'] == city['place_id']);

      if (!exists) {
        _selectedCities.add(city);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Questa tappa è già nel tuo itinerario'),
            margin: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    });
  }

  void _openCitiesSearch() async {
    List<String> selectedCountryCodes =
        _selectedCountries.map((country) => country.countryCode).toList();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PlacesSearchWidget(
          selectedCountryCodes: selectedCountryCodes,
          onPlaceSelected: _onCitySelected,
          type: PlacesType.cities,
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
        datesController.text =
            "${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}";
      });
    }
  }

  Future<void> _selectStartDate(
    BuildContext context,
  ) async {
    DateTime? newStartDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: _startDate ?? DateTime.now(),
      initialDate: _newStartDate ?? DateTime.now(),
    );
    if (newStartDate != null) {
      setState(() {
        _newStartDate = newStartDate;
        newStartDateController.text =
            DateFormat('dd/MM/yy').format(_newStartDate!);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? newEndDate = await showDatePicker(
      context: context,
      firstDate: _endDate ?? DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: _newEndDate ?? DateTime.now(),
    );
    if (newEndDate != null) {
      setState(() {
        _newEndDate = newEndDate;
        newEndDateController.text = DateFormat('dd/MM/yy').format(_newEndDate!);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      //since the process has multiple async operation update ui to show loading
      setState(() {
        isLoading = true;
      });

      if (widget.isUpdate == null || !widget.isUpdate!) {
        //TODO: current user can be handled better
        //code for insertion
        UserModel? currentUser = await widget.databaseService
            .getUserByUid(widget.authService.currentUser!.uid);
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
        List<Map<String, dynamic>> citiesMap =
            await reformatCitiesWithCoordinates();

        //retrieve image Reference from google
        String imageRef = await widget.googlePlacesService
            .getCountryImageRef(countriesMap.first['name']);

        final trip = TripModel(
          title: titleController.text,
          creatorInfo: creatorInfo,
          nations: countriesMap,
          cities: citiesMap,
          startDate: _startDate,
          endDate: _endDate,
          timestamp: Timestamp.now(),
          imageRef: imageRef,
        );
        widget.databaseService
            .createTrip(trip)
            .then((value) => Navigator.pop(context, true));
      } else {
        //code for update
        final citiesMap = await reformatCitiesWithCoordinates();
        if (widget.trip != null) {
          final updatedTrip = TripModel(
            id: widget.trip!.id,
            creatorInfo: widget.trip!.creatorInfo,
            title: titleController.text.trim(),
            nations: widget.trip!.nations,
            cities: List.from(_alreadySelectedCities)..addAll(citiesMap),
            startDate: _newStartDate,
            endDate: _newEndDate,
            activities: widget.trip!.activities,
            expenses: widget.trip!.expenses,
            isConfirmed: widget.trip!.isConfirmed,
            isPast: widget.trip!.isPast,
            isPrivate: widget.trip!.isPrivate,
            saveCounter: widget.trip!.saveCounter,
            timestamp: widget.trip!.timestamp,
            imageRef: widget.trip!.imageRef,
          );
          widget.databaseService.updateTrip(updatedTrip).then((_) =>
              {if (context.mounted) Navigator.pop(context, updatedTrip)});
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Per favore compila tutti i campi correttamente!')));
    }
  }

  Future<List<Map<String, dynamic>>> reformatCitiesWithCoordinates() async {
    List<Map<String, dynamic>> citiesMap = [];
    for (var city in _selectedCities) {
      String placeId = city['place_id'] ?? 'null';
      if (placeId.isNotEmpty) {
        try {
          // Fetch coordinates using placeId
          Map<String, double> coordinates =
              await widget.googlePlacesService.getCoordinates(placeId);
          citiesMap.add({
            'name': city['name'],
            'place_id': placeId,
            'lat': coordinates['lat'],
            'lng': coordinates['lng'],
          });
        } catch (e) {
          print("Error fetching coordinates for ${city['name']}: $e");
        }
      }
    }
    return citiesMap;
  }

  //methods for testing purposes
  @visibleForTesting
  void simulateCountrySelection(List<Country> countries) {
    _onCountriesSelected(countries);
  }

  @visibleForTesting
  void simulateCitySelection(List<Map<String, String>> cities) {
    for (var city in cities) {
      _onCitySelected(city);
    }
  }

  @visibleForTesting
  void simulateDateSelection(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }
}
