import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/myTripsPage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
  });

  Future<void> pumpTestableWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MyTripsPage(
          databaseService: mockDatabaseService,
        ),
      ),
    );
  }

  group('Future builder tests', () {
    testWidgets('shows loading indicator while waiting for trips',
        (tester) async {
      //define mocked behaviour
      when(mockDatabaseService.getHomePageTrips()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1), () => []),
      );

      await pumpTestableWidget(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows empty message when no trips', (tester) async {
      when(mockDatabaseService.getHomePageTrips()).thenAnswer((_) async => []);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('Pianifica il tuo primo viaggio'), findsOneWidget);
    });

    testWidgets('shows upcoming trips', (tester) async {
      final trips = [
        TripModel(
            id: '1',
            title: 'Paris',
            endDate: DateTime.now().add(const Duration(days: 5))),
      ];

      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => trips);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('I tuoi viaggi'), findsOneWidget);
      expect(find.text('Viaggi passati'), findsNothing);
      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows past trips', (tester) async {
      final trips = [
        TripModel(
            id: '1',
            title: 'Paris',
            endDate: DateTime.now().subtract(const Duration(days: 5))),
      ];

      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => trips);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('Viaggi passati'), findsOneWidget);
      expect(find.text('I tuoi viaggi'), findsNothing);
      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows both upcoming and past trips', (tester) async {
      final trips = [
        TripModel(
            id: '1',
            title: 'Paris',
            endDate: DateTime.now().subtract(const Duration(days: 5))),
        TripModel(
            id: '2',
            title: 'Rome',
            endDate: DateTime.now().add(const Duration(days: 5))),
      ];

      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => trips);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('Viaggi passati'), findsOneWidget);
      expect(find.text('I tuoi viaggi'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Rome'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) => Future.error(Exception('Database error')));

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Errore:'), findsOneWidget);
    });
  });

  group('Tablet layout tests', () {
    testWidgets('renders tablet layout', (tester) async {
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;
      // Set window width above 600 for tablet
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;

      final trips = [
        TripModel(
            id: '1',
            title: 'Paris',
            endDate: DateTime.now().subtract(const Duration(days: 5))),
        TripModel(
            id: '2',
            title: 'Rome',
            endDate: DateTime.now().add(const Duration(days: 5))),
      ];

      final activities = [
        AttractionModel(
          id: '1',
          tripId: '1',
          type: 'attraction',

        ),
        FlightModel(
          id: '2',
          tripId: '1',
          type: 'flight',
        ),
      ];

      //mock db behaviour
      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => trips);
      when(mockDatabaseService.getTripActivities(any))
          .thenAnswer((_) async => activities);
      when(mockDatabaseService.loadTrip(any)).thenAnswer((_) async => trips[0]);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(TripCardWidget), findsNWidgets(2));
      expect(find.text('Seleziona un viaggio'), findsOneWidget);

      //simulate click on one of the trips
      await tester.tap(find.widgetWithText(TripCardWidget, 'Paris'));
      await tester.pumpAndSettle();

      expect(find.byType(TripPage), findsOneWidget);
      expect(find.textContaining('Paris'), findsNWidgets(2));
      expect(find.text('Rome'), findsOneWidget);
      expect(find.text('Seleziona un viaggio'), findsNothing);

      addTearDown(() {
        // Restore original values after test
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });
    });
  });
}
