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

    testWidgets('shows upcoming trips in the correct tab', (tester) async {
      final trips = [
        TripModel(
          id: '1',
          title: 'Paris',
          endDate: DateTime.now().add(const Duration(days: 5)),
        ),
      ];
      when(mockDatabaseService.getHomePageTrips()).thenAnswer((_) async => trips);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('I tuoi viaggi'), findsOneWidget);
      expect(find.text('Viaggi passati'), findsOneWidget);

      expect(find.text('Paris'), findsOneWidget);

      // Switch to the second tab
      await tester.tap(find.text('Viaggi passati'));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsNothing);
    });

    testWidgets('shows past trips', (tester) async {
      final trips = [
        TripModel(
          id: '1',
          title: 'Paris',
          endDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => trips);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('I tuoi viaggi'), findsOneWidget);
      expect(find.text('Viaggi passati'), findsOneWidget);

      expect(find.text('Paris'), findsNothing);

      await tester.tap(find.text('Viaggi passati'));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows both upcoming and past trips', (tester) async {
      final trips = [
        TripModel(
          id: '1',
          title: 'Paris',
          endDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        TripModel(
          id: '2',
          title: 'Rome',
          endDate: DateTime.now().add(const Duration(days: 5)),
        ),
      ];

      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => trips);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('I tuoi viaggi'), findsOneWidget);
      expect(find.text('Viaggi passati'), findsOneWidget);

      expect(find.text('Rome'), findsOneWidget);
      expect(find.text('Paris'), findsNothing);

      await tester.tap(find.text('Viaggi passati'));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Rome'), findsNothing);
    });

    testWidgets('shows error message on failure', (tester) async {
      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) => Future.error(Exception('Database error')));

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Errore:'), findsOneWidget);
    });
  });

  /*
  testWidgets('refreshes trips after returning from UpsertTripPage', (tester) async {
    final tripsBefore = [
      TripModel(id: '1', title: 'Madrid', endDate: DateTime.now().add(const Duration(days: 3))),
    ];
    final tripsAfter = [
      TripModel(id: '2', title: 'Lisbon', endDate: DateTime.now().add(const Duration(days: 6))),
    ];

    when(mockDatabaseService.getHomePageTrips())
        .thenAnswer((_) async => tripsBefore);

    await pumpTestableWidget(tester);
    await tester.pumpAndSettle();

    expect(find.text('Madrid'), findsOneWidget);

    // Setup mock return with updated list
    when(mockDatabaseService.getHomePageTrips())
        .thenAnswer((_) async => tripsAfter);

    // Simulate FAB tap and return from UpsertTripPage
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    tester.state<NavigatorState>(find.byType(Navigator)).pop(); // Simulate back
    await tester.pumpAndSettle();

    expect(find.text('Lisbon'), findsOneWidget);
    expect(find.text('Madrid'), findsNothing);
  });

   */

  group('Tablet layout tests', () {
    testWidgets('renders tablet layout and allows selecting a trip', (tester) async {
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;

      // Set tablet screen size
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;

      final trips = [
        TripModel(
          id: '1',
          title: 'Paris',
          endDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        TripModel(
          id: '2',
          title: 'Rome',
          endDate: DateTime.now().add(const Duration(days: 5)),
        ),
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

      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => trips);
      when(mockDatabaseService.getTripActivities(any))
          .thenAnswer((_) async => activities);
      when(mockDatabaseService.loadTrip(any))
          .thenAnswer((_) async => trips[0]);

      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Default tab is future → only Rome is shown
      expect(find.byType(TripCardWidget), findsOneWidget);
      expect(find.text('Rome'), findsOneWidget);
      expect(find.text('Paris'), findsNothing);
      expect(find.text('Seleziona un viaggio'), findsOneWidget);

      await tester.tap(find.text('Viaggi passati'));
      await tester.pumpAndSettle();

      expect(find.byType(TripCardWidget), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);

      // Simulate tap on Paris
      await tester.tap(find.widgetWithText(TripCardWidget, 'Paris'));
      await tester.pumpAndSettle();

      // TripPage is shown
      expect(find.byType(TripPage), findsOneWidget);
      expect(find.textContaining('Paris'), findsWidgets);
      expect(find.text('Seleziona un viaggio'), findsNothing);

      addTearDown(() {
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });
    });
  });
}
