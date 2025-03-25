import 'package:country_picker/country_picker.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';

class CountryPickerWidget extends StatefulWidget {
  final Function(List<Country>) onCountriesSelected;
  final List<Country> selectedCountries;

  const CountryPickerWidget(this.selectedCountries, {super.key, required this.onCountriesSelected});

  @override
  State<CountryPickerWidget> createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  List<Country> _selectedCountries = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _allCountries = CountryService().getAll();
      _filteredCountries = List.from(_allCountries);
      _selectedCountries = widget.selectedCountries;
    });
  }

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: ScreenSize.screenWidth(context) * 0.2,
                  ),
                  Icon(
                    Icons.flag_circle_sharp,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: ScreenSize.screenWidth(context) * 0.2,
                    child: TextButton(
                        onPressed: () => _confirmCountries(), child: Text('Done')),
                  )
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
                        Container(
                          color: isSelected
                              ? Theme.of(context).highlightColor
                              : Theme.of(context).scaffoldBackgroundColor,
                          child: ListTile(
                            onTap: () => _selectCountry(country, isSelected),
                            leading: Text('${country.flagEmoji}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            title: Text('${country.name}'),

                          ),
                        ),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          height: 1,
                          thickness: 1,
                        ),
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

    if (!isSelected && _selectedCountries.length < 5) {
      _selectedCountries.add(country);
    } else if (isSelected) {
      _selectedCountries.remove(country);
    }

    setState(() {});
  }

  _confirmCountries() {
    widget.onCountriesSelected(List.from(_selectedCountries));
    Navigator.pop(context);
  }
}
