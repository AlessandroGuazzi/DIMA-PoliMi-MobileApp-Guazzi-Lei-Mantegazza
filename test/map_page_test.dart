import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/mapPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpTestableWidget(WidgetTester tester, TripModel trip) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(
          trip: trip,
        ),
      ),
    );
  }

  testWidgets(
      'calculates center of cities correctly for initial camera position',
      (WidgetTester tester) async {
    final cities = [
      {'name': 'A', 'lat': 10.0, 'lng': 20.0},
      {'name': 'B', 'lat': 30.0, 'lng': 40.0},
    ];

    final trip = TripModel(cities: cities);

    await pumpTestableWidget(tester, trip);
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(MapPage)) as dynamic;
    final position = state.initializeCameraPosition();

    expect(position.target.latitude, 20.0);
    expect(position.target.longitude, 30.0);
    expect(position.zoom, 5);
  });

  testWidgets('map display marker for each city in the trip', (WidgetTester tester) async {
    final cities = [
      {'name': 'A', 'lat': 10.0, 'lng': 20.0},
      {'name': 'B', 'lat': 30.0, 'lng': 40.0},
    ];

    final trip = TripModel(cities: cities);

    await pumpTestableWidget(tester, trip);
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(MapPage)) as dynamic;
    final markers = state.initializeMarkers();

    expect(markers.length, 2);
    expect(markers.first.markerId.value, 'A');
    expect(markers.first.position.latitude, 10.0);
    expect(markers.first.position.longitude, 20.0);
    expect(markers.last.markerId.value, 'B');
    expect(markers.last.position.latitude, 30.0);
    expect(markers.last.position.longitude, 40.0);
  });

  testWidgets('openDetails shows correct city info in dialog', (WidgetTester tester) async {
    final city = {'name': 'Rome', 'lat': 41.9028, 'lng': 12.4964};
    final trip = TripModel(cities: [city]);

    await pumpTestableWidget(tester, trip);
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(MapPage)) as dynamic;
    state.openDetails(city);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Rome'), findsOneWidget);
    expect(find.text('Latitude: 41.9028'), findsOneWidget);
    expect(find.text('Longitude: 12.4964'), findsOneWidget);
    expect(find.text('Chiudi'), findsOneWidget);

    await tester.tap(find.text('Chiudi'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
