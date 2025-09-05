import 'package:dima_project/utils/PlacesType.dart';
import 'package:flutter/material.dart';
import '../../services/googlePlacesService.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../utils/screenSize.dart';

class PlacesSearchWidget extends StatefulWidget {
  final List<String> selectedCountryCodes;
  final Function(Map<String, String>) onPlaceSelected;
  final PlacesType type;
  final GooglePlacesService googlePlacesService;

  PlacesSearchWidget(
      {super.key,
      required this.selectedCountryCodes,
      required this.onPlaceSelected,
      required this.type,
      googlePlacesService})
      : googlePlacesService = googlePlacesService ?? GooglePlacesService();

  @override
  PlacesSearchWidgetState createState() => PlacesSearchWidgetState();
}

class PlacesSearchWidgetState extends State<PlacesSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: ScreenSize.screenHeight(context) * 0.8,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(150, 15, 150, 15),
              child: Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: const BorderRadius.all(
                      Radius.circular(100)), // Rounded edges
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
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.center,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).secondaryHeaderColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: SearchBar(
                          key: const Key('placesSearchBar'),
                          controller: controller,
                          focusNode: focusNode,
                          hintText: 'Cerca...',
                          hintStyle: WidgetStatePropertyAll(Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey)),
                          leading: const Icon(Icons.search),
                          backgroundColor:
                              Theme.of(context).searchBarTheme.backgroundColor,
                        ),
                      );
                    },

                    //to modify the list
                    itemBuilder: (context, Map<String, String> suggestions) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(suggestions['name'] ?? ''),
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
                        places = await widget.googlePlacesService
                            .searchAutocomplete(
                                query, widget.selectedCountryCodes, placeType);
                      }
                      return places;
                    })),
          ],
        ));
  }
}
