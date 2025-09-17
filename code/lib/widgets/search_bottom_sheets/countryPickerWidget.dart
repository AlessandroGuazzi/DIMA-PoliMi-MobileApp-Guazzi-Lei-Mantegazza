import 'package:country_picker/country_picker.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';

class CountryPickerWidget extends StatefulWidget {
  final Function(List<Country>) onCountriesSelected;
  final List<Country> selectedCountries;
  final bool isUserNationality;
  final CountryService countryService;

  CountryPickerWidget(
      {super.key,
      required this.selectedCountries,
      required this.onCountriesSelected,
      required this.isUserNationality,
      countryService})
      : countryService = countryService ?? CountryService();

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
      _allCountries = widget.countryService.getAll();
      _filteredCountries = List.from(_allCountries);
      _selectedCountries = widget.selectedCountries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
        height: ScreenSize.screenHeight(context) * 0.8,
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
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.flag_circle_sharp,
                      size: 30,
                    ),
                    if (!widget.isUserNationality)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _confirmCountries,
                          child: Text('Conferma', style: Theme.of(context).textTheme.bodyMedium,),
                        ),
                      ),
                  ],
                ),
              )

            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
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
                padding: const EdgeInsets.all(2), // thickness
                child: SearchBar(
                  hintText: 'Cerca una nazione...',
                  hintStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                  leading: const Icon(Icons.search),
                  backgroundColor:
                      Theme.of(context).searchBarTheme.backgroundColor,
                  onChanged: (query) {
                    _filterCountries(query.trim());
                  },
                ),
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
      if (widget.isUserNationality) {
        _confirmCountries();
      }
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
