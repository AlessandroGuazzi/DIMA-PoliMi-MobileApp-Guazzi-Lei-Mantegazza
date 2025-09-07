import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(TripModel trip, bool isSaved,
      Function(bool, String) onSave, bool isHome) {
    return MaterialApp(
      home: TripCardWidget(trip, isSaved, onSave, isHome),
    );
  }

  group('TripCardWidget Tests', () {
    final sampleTrip = TripModel(
      id: 'trip1',
      title: 'Weekend in Rome',
      cities: [
        {'name': 'Rome'},
        {'name': 'Florence'},
        {'name': 'Venice'},
      ],
      startDate: DateTime(2023, 1, 1),
      endDate: DateTime(2023, 1, 5),
      imageRef: null,
      creatorInfo: {'username': 'testuser', 'id': 'user1'},
      timestamp: Timestamp.fromDate(DateTime.now()),
      saveCounter: 42,
    );

    testWidgets('Home card renders correctly ', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(sampleTrip, false, (a, b) {}, true));

      expect(find.text('Weekend in Rome'), findsOneWidget);
      expect(find.textContaining('Rome · Florence'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('Explorer card renders correctly',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(sampleTrip, false, (a, b) {}, false));

      expect(find.text('@testuser · 0 sec fa'), findsOneWidget);
      expect(find.text('Weekend in Rome'), findsOneWidget);
      expect(find.text('Rome · Florence + 1'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);
    });

    testWidgets('onSave is triggered on save button tap',
        (WidgetTester tester) async {
      bool callbackTriggered = false;
      String? receivedId;

      await tester
          .pumpWidget(buildTestableWidget(sampleTrip, false, (saved, id) {
        callbackTriggered = true;
        receivedId = id;
      }, false));

      await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
      await tester.pump();

      expect(callbackTriggered, isTrue);
      expect(receivedId, 'trip1');
    });

    testWidgets('Fallback info are displayed when null',
        (WidgetTester tester) async {
      final fallbackTrip = TripModel(); //everything is null

      //test for home card
      await tester.pumpWidget(buildTestableWidget(fallbackTrip, false, (a,b){}, true));

      expect(find.text('Titolo mancante'), findsOneWidget);
      expect(find.text('Nessun Luogo'), findsOneWidget);
      expect(find.text('No data - No data'), findsOneWidget);

      //test for explorer card
      await tester.pumpWidget(buildTestableWidget(fallbackTrip, false, (a,b){}, false));

      expect(find.text('Titolo mancante'), findsOneWidget);
      expect(find.text('Nessun Luogo'), findsOneWidget);
      expect(find.text('na'), findsOneWidget);
      expect(find.text('@no_username · no_time'), findsOneWidget);
    });
  });
}
