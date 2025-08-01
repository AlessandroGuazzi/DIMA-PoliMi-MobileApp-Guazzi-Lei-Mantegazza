import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/widgets/activity_widgets/accommodationActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/activityDividerWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AccommodationCardWidget displays and expands correctly', (WidgetTester tester) async {
    final accommodation = AccommodationModel(
      name: 'Hotel Roma',
      address: 'Via Nazionale, 1',
      checkIn: DateTime(2025, 6, 1, 14, 30),
      checkOut: DateTime(2025, 6, 2, 10, 0),
      expenses: 120.00,
      contacts: {
        'Email': 'info@hotelroma.it',
        'Telefono': '+39 06 1234567',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccommodationActivityCard(accommodation),
        ),
      ),
    );

    // Verifica i dati principali
    expect(find.text('Hotel Roma'), findsOneWidget);
    expect(find.textContaining('CheckIn: 14:30'), findsOneWidget);
    expect(find.textContaining('CheckOut: 10:00'), findsOneWidget);

    expect(find.byIcon(Icons.hotel), findsOneWidget);
    expect(find.byType(activityDivider), findsOneWidget);



    // I dettagli non dovrebbero essere visibili inizialmente
    expect(find.text('Dettagli Extra:'), findsNothing);
    expect(find.text('Via Nazionale, 1'), findsNothing);
    expect(find.text('Costo: €120.00'), findsNothing);
    expect(find.text('Contatti:'), findsNothing);

    // Espandi il widget
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    // Verifica che i dettagli siano ora visibili
    expect(find.text('Dettagli Extra:'), findsOneWidget);
    expect(find.text('Via Nazionale, 1'), findsOneWidget);
    expect(find.text('Costo: €120.00'), findsOneWidget);
    expect(find.text('Contatti:'), findsOneWidget);
    expect(find.text('Email: info@hotelroma.it'), findsOneWidget);
    expect(find.text('Telefono: +39 06 1234567'), findsOneWidget);


    //Simula di nuovo il tap per chiudere
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    // I dettagli non dovrebbero essere più visibili
    expect(find.text('Dettagli Extra:'), findsNothing);
    expect(find.text('Via Nazionale, 1'), findsNothing);
  });
}
