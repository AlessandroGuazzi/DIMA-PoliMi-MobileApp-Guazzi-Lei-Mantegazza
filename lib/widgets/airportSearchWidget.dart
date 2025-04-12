import 'package:dima_project/models/airportModel.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AirportSearchWidget extends StatefulWidget {
  final Function(Airport) onAirportSelected; // callback quando selezioni un aeroporto

  const AirportSearchWidget({super.key, required this.onAirportSelected});

  @override
  State<AirportSearchWidget> createState() => _AirportSearchWidgetState();
}

class _AirportSearchWidgetState extends State<AirportSearchWidget> {
  List<Airport> _airports = [];
  List<Airport> _filteredAirports = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  Future<void> _loadAirports() async {
    final String response = await rootBundle.loadString('assets/airports.json');
    //print('JSON Loaded: $response');  // Stampa il contenuto del JSON

    final List<dynamic> data = json.decode(response);
    //print('Decoded Data: $data');  // Stampa la lista decodificata

    final List<Airport> airports = [];
    for (var value in data) {
      if (value['iata'] != null && value['name'] != null && value['iata'] != '') {
        airports.add(Airport.fromJson(value));
      }
    }

    setState(() {
      _airports = airports;
      _filteredAirports = airports;
    });
  }

  void _onSearchChanged(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredAirports = _airports.where((airport) {
        return airport.name.toLowerCase().contains(lower) ||
            airport.iata.toLowerCase().contains(lower) ||
            airport.iso.toLowerCase().contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // <-- importante!
      children: [
        TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Cerca aeroporto',
            prefixIcon: Icon(Icons.flight_takeoff),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: ScreenSize.screenHeight(context)*0.5,
          child: _filteredAirports.isEmpty
              ? const Center(child: Text('Nessun risultato'))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredAirports.length,
            itemBuilder: (context, index) {
              final airport = _filteredAirports[index];
              return ListTile(
                leading: const Icon(Icons.flight),
                title: Text('${airport.name}'),
                subtitle: Text('${airport.iata} -  ${airport.iso}'),
                onTap: () {
                  widget.onAirportSelected(airport);
                  _controller.text = '${airport.name} (${airport.iata})';
                  FocusScope.of(context).unfocus(); // chiude la tastiera
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
