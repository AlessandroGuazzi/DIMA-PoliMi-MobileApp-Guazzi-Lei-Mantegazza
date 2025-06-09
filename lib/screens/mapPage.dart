import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/tripModel.dart';

class MapPage extends StatefulWidget {
  final TripModel trip;

  const MapPage({super.key, required this.trip});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(),
      body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: initializeCameraPosition(),
          markers: initializeMarkers()),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> initializeMarkers() {
    List<Map<String, dynamic>> cities = widget.trip.cities ?? [];
    Set<Marker> markers = <Marker>{};
    if (cities.isNotEmpty) {
      for (var city in cities) {
        markers.add(Marker(
            markerId: MarkerId(city['name']),
            position: LatLng(city['lat'], city['lng']),
            infoWindow: InfoWindow(
                title: city['name'],
                snippet: "Click for details",
                onTap: () {
                  openDetails(city);
                })));
      }
    }
    return markers;
  }


  CameraPosition initializeCameraPosition() {
    List<Map<String, dynamic>> cities = widget.trip.cities ?? [];

    if (cities.isEmpty) {
      return const CameraPosition(target: LatLng(0, 0), zoom: 1);
    }

    double minLat = cities.first['lat'];
    double maxLat = cities.first['lat'];
    double minLng = cities.first['lng'];
    double maxLng = cities.first['lng'];

    //iterate all cities to find the one with limit coordinates
    for (var city in cities) {
      if (city['lat'] < minLat) minLat = city['lat'];
      if (city['lat'] > maxLat) maxLat = city['lat'];
      if (city['lng'] < minLng) minLng = city['lng'];
      if (city['lng'] > maxLng) maxLng = city['lng'];
    }

    LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    return CameraPosition(target: center, zoom: 5);
  }

  void openDetails(Map<String, dynamic> city) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(city['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Latitude: ${city['lat']}"),
              Text("Longitude: ${city['lng']}"),
              // Add more details here if available
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Chiudi"),
            ),
          ],
        );
      },
    );
  }
}
