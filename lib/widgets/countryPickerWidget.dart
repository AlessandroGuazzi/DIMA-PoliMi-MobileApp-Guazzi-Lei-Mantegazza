import 'package:country_picker/country_picker.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';

class CountryPickerWidget extends StatefulWidget {
  final Function(List<Country>) onCountriesSelected;

  const CountryPickerWidget({super.key, required this.onCountriesSelected});

  @override
  State<CountryPickerWidget> createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  List<Country> _selectedCountries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _allCountries = CountryService().getAll();
      _filteredCountries = List.from(_allCountries);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: ScreenSize.screenHeight(context) * 0.9,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: null,
                      icon: Icon(Icons.keyboard_backspace_rounded)),
                  Icon(
                    Icons.flag_circle_sharp,
                    color: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                      onPressed: () => _confirmCountries(), child: Text('Done'))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                hintText: 'Search countries...',
                leading: Icon(Icons.search),
                backgroundColor:
                    Theme.of(context).searchBarTheme.backgroundColor,
                onChanged: (query) {
                  _filterCountries(query.trim());
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _filteredCountries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final country = _filteredCountries[index];
                    bool isSelected;
                    _selectedCountries.contains(country)
                        ? isSelected = true
                        : isSelected = false;

                    return Column(
                      children: [
                        ListTile(
                          onTap: () => _selectCountry(country, isSelected),
                          tileColor: isSelected
                              ? Theme.of(context).highlightColor
                              : null,
                          leading: Text('${country.flagEmoji}',
                              style: Theme.of(context).textTheme.headlineSmall),
                          title: Text('${country.name}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, top: 0, right: 0, bottom: 0),
                          child: Divider(
                            color: Theme.of(context).dividerColor,
                          ),
                        )
                      ],
                    );
                  }),
            ),
          ],
        ));
  }

  _filterCountries(String query) {
    setState(() {
      _filteredCountries = _allCountries
          .where((country) =>
              country.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  _selectCountry(Country country, bool isSelected) {
    isSelected
        ? _selectedCountries.remove(country)
        : _selectedCountries.add(country);
    setState(() {});
  }

  _confirmCountries() {
    widget.onCountriesSelected(_selectedCountries);
    Navigator.pop(context);
  }
}
