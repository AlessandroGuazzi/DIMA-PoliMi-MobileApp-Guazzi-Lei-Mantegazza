import 'package:flutter/material.dart';
import '../services/googlePlacesService.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../utils/screenSize.dart';

class CitySearchWidget extends StatefulWidget {
  final List<Country> selectedCountries;
  final Function(String) onCitySelected;

  const CitySearchWidget(
      {super.key,
      required this.selectedCountries,
      required this.onCitySelected});

  @override
  _CitySearchWidgetState createState() => _CitySearchWidgetState();
}

class _CitySearchWidgetState extends State<CitySearchWidget> {
  TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: ScreenSize.screenHeight(context) * 0.9,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(150, 15, 150, 15),
              child: Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(100)), // Rounded edges
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Icon(
                  Icons.location_city,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TypeAheadField(

                    //to modify textfield
                    builder: (context, controller, focusNode) {
                      return SearchBar(
                        controller: controller,
                        focusNode: focusNode,
                        hintText: 'Search cities...',
                        leading: Icon(Icons.search),
                        backgroundColor:
                            Theme.of(context).searchBarTheme.backgroundColor,
                      );
                    },

                    //to modify the list
                    itemBuilder: (context, String suggestions) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(suggestions),
                          ),
                          Divider(
                            color: Theme.of(context).dividerColor,
                            height: 1,
                            thickness: 1,
                          )
                        ],
                      );
                    },

                    //to modify the decoration box
                    decorationBuilder: (context, child) {
                      return Container(
                        child: child,
                      );
                    },
                    emptyBuilder: (context) => const Center(
                        child: Text('Ricerca supportata da Google')),
                    errorBuilder: (context, error) => const Center(
                        child:
                            Text('Nessuna città corrisponde alla tua ricerca')),
                    onSelected: (value) {
                      widget.onCitySelected(value);
                      Navigator.pop(context);
                    },
                    suggestionsCallback: (String query) async {
                      String trimQuery = query.trim();
                      List<String> cities = [];

                      if (trimQuery != '') {
                        List<String> countryCodes = widget.selectedCountries
                            .map((country) => country.countryCode)
                            .toList();
                        cities = await GooglePlacesService()
                            .searchCities(query, countryCodes);
                      }

                      /*
                      cities = [
                        "New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
                        "London", "Manchester", "Birmingham", "Liverpool", "Glasgow",
                        "Paris", "Marseille", "Lyon", "Toulouse", "Nice",
                        "Berlin", "Hamburg", "Munich", "Cologne", "Frankfurt",
                        "Madrid"];
                        */

                      return cities;
                    })),
          ],
        ));
  }
}
