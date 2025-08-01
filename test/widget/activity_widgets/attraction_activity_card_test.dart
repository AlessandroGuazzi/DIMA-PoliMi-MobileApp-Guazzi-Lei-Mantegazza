import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/widgets/activity_widgets/attractionActivityCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttractionActivityCard', () {
    testWidgets('renders base info and expands to show details', (WidgetTester tester) async {
      final attraction = AttractionModel(
        name: 'Colosseo',
        startDate: DateTime(2025, 6, 1, 10, 0),
        endDate: DateTime(2025, 6, 1, 12, 30),
        address: 'Piazza del Colosseo, Roma',
        attractionType: 'tourist_attraction',
        expenses: 16.5,
        description: 'Visita guidata all\'interno del Colosseo.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionActivityCard(attraction),
          ),
        ),
      );

      // Let initial animations settle
      await tester.pumpAndSettle();

      // Verifica contenuto base
      expect(find.text('Colosseo'), findsOneWidget);
      expect(find.textContaining('10:00 - 12:30'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.byIcon(Icons.attractions), findsOneWidget);

      // Dettagli extra non visibili all'inizio - REMOVE skipOffstage: true
      expect(find.textContaining('Dettagli Extra:'), findsNothing);
      expect(find.textContaining('Piazza del Colosseo'), findsNothing);
      expect(find.textContaining('€16.50'), findsNothing);
      expect(find.textContaining('Visita guidata'), findsNothing);

      // Espandi
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      // Ora i dettagli devono essere visibili
      expect(find.text('Dettagli Extra:'), findsOneWidget);
      expect(find.textContaining('Piazza del Colosseo'), findsOneWidget);
      expect(find.text('Tipo: Tourist Attraction'), findsOneWidget);
      expect(find.text('Costo: €16.50'), findsOneWidget);
      expect(find.text('Descrizione:'), findsOneWidget);
      expect(find.text('Visita guidata all\'interno del Colosseo.'), findsOneWidget);

      // Simula di nuovo il tap per chiudere
      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pumpAndSettle();

      // Dettagli extra non visibili nuovamente
      expect(find.textContaining('Dettagli Extra:'), findsNothing);
      expect(find.textContaining('Piazza del Colosseo'), findsNothing);
    });
  });
}
