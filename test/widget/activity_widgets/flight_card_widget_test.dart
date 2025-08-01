import 'package:dima_project/widgets/activity_widgets/activityDividerWidget.dart';
import 'package:dima_project/widgets/activity_widgets/activityDividerWidget.dart';
import 'package:dima_project/widgets/activity_widgets/flightActivityCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/flightModel.dart';

void main() {
  testWidgets('Flightcardwidget shows basic and expanded flight info', (WidgetTester tester) async {
    // Mock FlightModel
    final flight = FlightModel(
      id: 'flight_001',
      tripId: 'trip_123',
      type: 'flight',
      departureAirPort: {'name': 'Malpensa', 'iata': 'MXP'},
      arrivalAirPort: {'name': 'Heathrow', 'iata': 'LHR'},
      departureDate: DateTime(2024, 7, 1, 8, 30),
      arrivalDate: DateTime(2024, 7, 1, 10, 45),
      duration: 2.25,
      expenses: 120.0,
    );

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlightActivityCard(flight),
        ),
      ),
    );

    //Info base visibili
    expect(find.text('MXP → LHR'), findsOneWidget);
    expect(find.textContaining('Partenza: 08:30'), findsOneWidget);
    expect(find.textContaining('Arrivo: 10:45'), findsOneWidget);

    //expect(find.byType(activityDivider), findsOneWidget);
    expect(find.byIcon(Icons.flight), findsOneWidget);

    //Dettagli extra NON visibili prima dell'espansione
    //expect(find.textContaining('Partenza: Malpensa'), findsNothing);
    //expect(find.textContaining('Arrivo: Heathrow'), findsNothing);
    //expect(find.textContaining('Costo: €120.00'), findsNothing);

    //Simula click su espansione
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    //Ora i dettagli extra DEVONO essere visibili
    expect(find.textContaining('Partenza: Malpensa'), findsOneWidget);
    expect(find.textContaining('Arrivo: Heathrow'), findsOneWidget);
    expect(find.textContaining('Costo: €120.00'), findsOneWidget);

    //Simula di nuovo il tap per chiudere
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    //I dettagli extra devono tornare invisibili
    //expect(find.textContaining('Partenza: Malpensa'), findsNothing);
  });
}
