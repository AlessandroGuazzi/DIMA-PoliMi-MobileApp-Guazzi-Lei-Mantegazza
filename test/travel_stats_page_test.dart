import 'package:countries_world_map/countries_world_map.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/travelStatsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

void main() {
  late MockDatabaseService mockService;

  setUp(() {
    mockService = MockDatabaseService();
  });

  Widget makeTestableWidget() {
    return MaterialApp(
      home: TravelStatsPage(
        databaseService: mockService,
      ),
    );
  }

  group('Future builder tests', () {
    testWidgets('Loading State shows CircularProgressIndicator',
        (tester) async {
      when(mockService.getCompletedTrips()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return <TripModel>[];
      });

      await tester.pumpWidget(makeTestableWidget());

      // Immediately after building, loading spinner is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('TravelStatsPage - Data Display', () {
    testWidgets('Displays correct data and UI elements on success',
        (tester) async {
      // Arrange
      final sampleTrips = [
        TripModel(id: 'test', title: 'Test trip', nations: [
          {'name': 'Germany', 'flag': '','code': 'dE'}, // Europe
          {'name': 'United States', 'flag': '','code': 'uS'},// North America
          {'code': 'jP'}, // Asia
          {'code': 'zA'}, // Africa
          {'code': 'aU'}, // Oceania
          {'code': 'bR'}, // South America
        ]),
      ];

      when(mockService.getCompletedTrips())
          .thenAnswer((_) async => sampleTrips);

      await tester.pumpWidget(makeTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('La Tua Mappa del Mondo'), findsOneWidget);
      expect(find.textContaining('Continenti Esplorati'), findsOneWidget);

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Europa'), findsOneWidget);
      expect(find.text('Asia'), findsOneWidget);
      expect(find.text('Africa'), findsOneWidget);
      expect(find.text('America Settentrionale'), findsOneWidget);
      expect(find.text('America Meridionale'), findsOneWidget);
      expect(find.text('Oceania'), findsOneWidget);

      expect(find.text('6'), findsWidgets); // 6 countries visited

      expect(find.byType(SimpleMap), findsOneWidget);

      final mapWidget = tester.widget<SimpleMap>(find.byType(SimpleMap));
      final coloredMap = mapWidget.colors;

      if (coloredMap != null) {
        expect(coloredMap.containsKey('de'), true);
        expect(coloredMap.containsKey('us'), true);
        expect(coloredMap.containsKey('jp'), true);
        expect(coloredMap.containsKey('za'), true);
        expect(coloredMap.containsKey('au'), true);
        expect(coloredMap.containsKey('br'), true);
      }
    });
  });
}
