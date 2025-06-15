import 'package:dima_project/screens/mapPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripInfoWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/tripModel.dart';

void main() {
  Future<void> pumpTestableWidget(
      WidgetTester tester, TripModel trip, bool isMyTrip) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TripInfoWidget(trip: trip, isMyTrip: isMyTrip),
        ),
      ),
    );
  }

  group('TripInfoWidget Tests', () {
    final now = DateTime.now();
    final trip = TripModel(
      startDate: now,
      endDate: now.add(const Duration(days: 10)),
      nations: [
        {'name': 'Italia', 'flag': '🇮🇹', 'code': 'iT'}
      ],
      cities: [
        {'name': 'Roma', 'place_id': '123', 'lat': 41.89, 'lng': 12.49}
      ],
    );


    testWidgets('renders correctly (mobile)', (WidgetTester tester) async {
      await pumpTestableWidget(tester, trip, true);
      await tester.pumpAndSettle();

      expect(find.text('Il tuo viaggio'), findsOneWidget);
      expect(find.text('Panoramica del tuo viaggio'), findsOneWidget);
      expect(find.text('Dove'), findsOneWidget);
      expect(find.text('Quando'), findsOneWidget);
      expect(find.textContaining('Italia'), findsOneWidget);
      expect(find.textContaining('Roma'), findsOneWidget);
      expect(find.text('Apri mappa'), findsOneWidget);
      expect(find.text('Aggiungi al calendario'), findsOneWidget);
    });

    testWidgets('renders correctly (tablet)', (WidgetTester tester) async {
      // Arrange
      const tabletSize = Size(800, 1280);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: tabletSize),
            child: Scaffold(
              body: TripInfoWidget(trip: trip, isMyTrip: true),
            ),
          ),
        ),
      );

      expect(find.text('Il tuo viaggio'), findsOneWidget);
      expect(find.text('Panoramica del tuo viaggio'), findsOneWidget);
      expect(find.text('Dove'), findsOneWidget);
      expect(find.text('Quando'), findsOneWidget);
      expect(find.textContaining('Italia'), findsOneWidget);
      expect(find.textContaining('Roma'), findsOneWidget);
      expect(find.text('Apri mappa'), findsOneWidget);
      expect(find.text('Aggiungi al calendario'), findsOneWidget);

      expect(
        find.ancestor(
          of: find.text('Apri mappa'),
          matching: find.widgetWithText(Row, 'Dove'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('does NOT show calendar button when isMyTrip is false',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, trip, false);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Aggiungi al calendario'), findsNothing);
      expect(find.byIcon(Icons.calendar_month), findsNothing);
    });

    testWidgets('displays correct status for past trips',
        (WidgetTester tester) async {
      final pastTrip = TripModel(
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 5)),
        nations: [
          {'name': 'Italia', 'flag': '🇮🇹', 'code': 'iT'}
        ],
        cities: [
          {'name': 'Roma', 'place_id': '123', 'lat': 41.89, 'lng': 12.49}
        ],
      );

      await pumpTestableWidget(tester, pastTrip, true);
      await tester.pumpAndSettle();

      expect(find.textContaining('Viaggio concluso'), findsOneWidget);
    });

    testWidgets('displays correct status for future trips',
        (WidgetTester tester) async {
      // Future trip
      final futureTrip = TripModel(
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 10)),
        nations: [
          {'name': 'Italia', 'flag': '🇮🇹', 'code': 'iT'}
        ],
        cities: [
          {'name': 'Roma', 'place_id': '123', 'lat': 41.89, 'lng': 12.49}
        ],
      );

      final daysUntilStart =
          (futureTrip.startDate!.difference(now).inHours / 24).round();

      await pumpTestableWidget(tester, futureTrip, true);
      await tester.pumpAndSettle();

      expect(find.textContaining('Inizia tra $daysUntilStart giorni'),
          findsOneWidget);
    });
    testWidgets('displays correct status for ongoing trips',
        (WidgetTester tester) async {
      final startOngoing = now.subtract(const Duration(days: 2));
      final endOngoing = now.add(const Duration(days: 2));
      final duration = endOngoing.difference(startOngoing).inDays + 1;
      final currentDay = now.difference(startOngoing).inDays + 1;

      final ongoingTrip = TripModel(
        startDate: startOngoing,
        endDate: endOngoing,
        nations: [
          {'name': 'Italia', 'flag': '🇮🇹', 'code': 'iT'}
        ],
        cities: [
          {'name': 'Roma', 'place_id': '123', 'lat': 41.89, 'lng': 12.49}
        ],
      );

      await pumpTestableWidget(tester, ongoingTrip, true);
      await tester.pumpAndSettle();

      expect(
        find.text('$duration giorni • Giorno $currentDay di $duration'),
        findsOneWidget,
      );
    });

    testWidgets('tap on Apri mappa opens MapPage', (WidgetTester tester) async {
      await pumpTestableWidget(tester, trip, true);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apri mappa'));
      await tester.pumpAndSettle();

      expect(find.byType(MapPage), findsOneWidget);
    });

    testWidgets('buildEvent constructs correct Event object',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, trip, true);
      await tester.pumpAndSettle();

      // Retrieve the state of the TripInfoWidget after it's fully built
      final state = tester.state(find.byType(TripInfoWidget)) as dynamic;

      // Call the method you want to test
      final event = state.buildEvent(trip);

      // Assertions
      expect(event.title, 'Viaggio a Italia 🇮🇹');
      expect(event.description, 'Il mio viaggio con Simply Travel');
      expect(event.location, 'Roma');
      expect(
        event.startDate,
        trip.startDate,
      );
      expect(event.endDate,
          trip.endDate!.add(const Duration(days: 1)));
      expect(event.allDay, isTrue);
    });
  });
}
