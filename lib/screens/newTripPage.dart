import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/homePage.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
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
  final TextEditingController activitiesController = TextEditingController();

  String title = "";
  List<Country> _selectedCountries = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Trip"),
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
                    labelText: 'Trip Title',
                    hintText: 'Enter the trip title',
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
                      return 'Please enter a title';
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
                    hintText: 'Countries',
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
                    if (value == null || value.isEmpty) {
                      return 'Please pick countries';
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
                    : SizedBox(
                        height: 1,
                      ),

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
                    hintText: 'When are you going?',
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
                      return "Please select a date range";
                    }
                    return null;
                  },
                  onTap: () => _selectDateRange(context),
                ),
                SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Create Trip'),
                  style: Theme.of(context).elevatedButtonTheme.style
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCountriesSelected(List<Country> selectedCountries) {
    //TODO:filter countries so no duplicates

    setState(() {
      _selectedCountries.addAll(selectedCountries);
      print(
          'Selected Countries: ${selectedCountries.map((c) => c.name).toList()}');
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
        return CountryPickerWidget(onCountriesSelected: _onCountriesSelected);
      },
    );
  }

  void _submitForm() async {

    //query db to get user info first
    UserModel? currentUser = await DatabaseService().getUserByUid(AuthService().currentUser!.uid);
    Map<String, dynamic> creatorInfo = {
      'id': 'null',
      'username': 'null',
      'profilePic': 'assets/profile.png'
    };
    if (currentUser != null) {
      creatorInfo = {
        'id': currentUser.id,
        'username': currentUser.username,
        'profilePic': currentUser.profilePic
      };
    }

    //insert in db
    if (_selectedCountries.isNotEmpty) {
      List<Map<String, dynamic>> countriesMap = _selectedCountries.map((country) => {
        'name': country.name,
        'flag': country.flagEmoji,
      }).toList();
      final trip = TripModel(
          title: titleController.text,
          creatorInfo: creatorInfo,
          nations: countriesMap,
          startDate: _startDate,
          endDate: _endDate
      );
      DatabaseService().createTrip(trip);
      Navigator.pop(context);
    }
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
}
