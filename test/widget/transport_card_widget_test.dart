import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/widgets/activity_widgets/transportCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TransportCardWidget displays base and expanded data', (WidgetTester tester) async {
    final transport = TransportModel(
      departurePlace: 'Rome',
      arrivalPlace: 'Florence',
      departureDate: DateTime(2025, 6, 20, 9, 15),
      duration: 120, // 2h
      transportType: 'train',
      expenses: 29.99,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Transportcardwidget(transport),
        ),
      ),
    );

    // Controlla contenuti base visibili
    expect(find.text('Rome → Florence'), findsOneWidget);
    expect(find.text('Ore partenza: 09:15'), findsOneWidget);

    // Dettagli extra non visibili inizialmente
    expect(find.textContaining('Durata'), findsNothing);
    expect(find.textContaining('Costo'), findsNothing);

    // Espandi i dettagli
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    // Ora i dettagli devono essere visibili
    expect(find.text('Durata: 2h 0m'), findsOneWidget);
    expect(find.text('Costo: €29.99'), findsOneWidget);
    expect(find.text('Tipo: train'), findsOneWidget);
    expect(find.text('Destinazione: Florence'), findsOneWidget);

    //Simula di nuovo il tap per chiudere
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    // Dettagli extra non visibili inizialmente
    expect(find.textContaining('Durata'), findsNothing);
    expect(find.textContaining('Costo'), findsNothing);
  });
}
