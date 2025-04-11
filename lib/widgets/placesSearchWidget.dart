import 'package:dima_project/utils/PlacesType.dart';
import 'package:flutter/material.dart';
import '../services/googlePlacesService.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../utils/screenSize.dart';

class PlacesSearchWidget extends StatefulWidget {
  final List<String> selectedCountryCodes;
  final Function(Map<String, String>) onPlaceSelected;
  final PlacesType type;

  const PlacesSearchWidget(
      {super.key,
      required this.selectedCountryCodes,
      required this.onPlaceSelected, required this.type});

  @override
  _PlacesSearchWidgetState createState() => _PlacesSearchWidgetState();
}

class _PlacesSearchWidgetState extends State<PlacesSearchWidget> {
  TextEditingController _placesController = TextEditingController();

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
                        hintText: 'Cerca...',
                        leading: Icon(Icons.search),
                        backgroundColor:
                            Theme.of(context).searchBarTheme.backgroundColor,
                      );
                    },

                    //to modify the list
                    itemBuilder: (context, Map<String, String> suggestions) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(suggestions['place_name'] ?? ''),
                            subtitle: Text(suggestions['other_info'] ?? ''),
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
                            Text('Nessun posto corrisponde alla tua ricerca')),
                    onSelected: (place) {
                      widget.onPlaceSelected(place);
                      Navigator.pop(context);
                    },
                    suggestionsCallback: (String query) async {
                      String trimQuery = query.trim();
                      List<Map<String, String>> places = [];

                      if (trimQuery != '') {
                        String placeType = widget.type.name;
                        //this is needed due to how google places api treat cities call
                        if (placeType == 'cities') placeType = '(cities)';
                        places = await GooglePlacesService().searchAutocomplete(
                            query, widget.selectedCountryCodes, placeType);
                      }

                      /*
                      cities = [
                        "New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
                        "London", "Manchester", "Birmingham", "Liverpool", "Glasgow",
                        "Paris", "Marseille", "Lyon", "Toulouse", "Nice",
                        "Berlin", "Hamburg", "Munich", "Cologne", "Frankfurt",
                        "Madrid"];
                        */

                      return places;
                    })),
          ],
        ));
  }
}
