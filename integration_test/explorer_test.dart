import 'package:dima_project/screens/authenticationPage.dart';
import 'package:dima_project/screens/explorerPage.dart';
import 'package:dima_project/screens/homePage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      testWidgets('ExplorerPage visualizza e interagisce con i viaggi pubblici', (WidgetTester tester) async {
            app.main();
            await tester.pumpAndSettle();

            // ✅ Login
            await tester.enterText(find.byKey(const Key('emailField')), 'mottola@gmail.com');
            await tester.enterText(find.byKey(const Key('passwordField')), 'mottola');
            await tester.tap(find.byKey(const Key('submitButton')));
            await tester.pumpAndSettle();

            // ✅ Ricerca per "Messico"
            final searchBar = find.byKey(const Key('searchBar'));
            await tester.enterText(searchBar, 'Messico');
            await tester.pumpAndSettle();

            // ✅ Trova la prima trip card
            final tripCard = find.byWidgetPredicate(
                      (widget) =>
                  widget.key is ValueKey<String> &&
                      (widget.key as ValueKey<String>).value.startsWith('tripCard_'),
            ).first;
            expect(tripCard, findsOneWidget);

            // 🔍 Estrai tripId dalla Key
            final tripId = (tripCard.evaluate().first.widget as Card).key.toString().split('_').last.replaceAll(')', '');


            await tester.ensureVisible(find.byKey(Key('tripCard_$tripId')));
            await tester.pumpAndSettle();

            final saveButtonKey = Key('saveButton_$tripId');
            final saveCounterKey = Key('saveCounter_$tripId');

            final saveButton = find.byKey(saveButtonKey);
            final saveCounter = find.byKey(saveCounterKey);

            expect(saveButton, findsOneWidget);
            expect(saveCounter, findsOneWidget);

            // 🧮 Valore iniziale
            final initialText = tester.widget<Text>(saveCounter).data!;
            final initialValue = int.tryParse(initialText) ?? 0;

            // 📌 Salva
            await tester.tap(saveButton);
            await tester.pumpAndSettle();

            final updatedText = tester.widget<Text>(saveCounter).data!;
            final updatedValue = int.tryParse(updatedText) ?? 0;
            expect(updatedValue, initialValue + 1);

            // 🔁 Rimuovi salvataggio
            await tester.tap(saveButton);
            await tester.pumpAndSettle();

            final finalText = tester.widget<Text>(saveCounter).data!;
            final finalValue = int.tryParse(finalText) ?? 0;
            expect(finalValue, initialValue);
      });
}

