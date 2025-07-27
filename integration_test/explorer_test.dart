import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      testWidgets('ExplorerPage visualizza e interagisce con i viaggi pubblici', (WidgetTester tester) async {
            app.main();

            // ✅ Login
            await tester.pumpAndSettle(); // Attende che l'app si avvii e si stabilizzi
            final emailFieldFinder = find.byKey(const Key('emailField'));
            await tester.pumpAndSettle();
            await tester.ensureVisible(emailFieldFinder);
            await tester.pumpAndSettle(); // Attende che il campo sia completamente visibile e stabile

            await tester.enterText(emailFieldFinder, 'leo@mail.com');
            await tester.pumpAndSettle();
            await tester.enterText(find.byKey(const Key('passwordField')), '123456');
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('submitButton')));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(milliseconds: 1000));


            // ✅ Ricerca di un viaggio, esempio : "Andora"
            final searchBar = find.byKey(const Key('searchBar'));
            await tester.pumpAndSettle();
            await tester.ensureVisible(searchBar);
            await tester.pumpAndSettle();
            await tester.enterText(searchBar, 'Andora');
            await tester.pumpAndSettle();

            // ✅ Trova la prima trip card
            final tripCardFinder = find.byWidgetPredicate(
                      (widget) =>
                  widget.key is ValueKey<String> &&
                      (widget.key as ValueKey<String>).value.startsWith('tripCard_'),
            ).first;
            expect(tripCardFinder, findsOneWidget);

            // Accedi direttamente al valore della ValueKey per ottenere la stringa completa, poi estrai l'ID.
            final ValueKey<String> tripCardValueKey = tester.widget<Card>(tripCardFinder).key as ValueKey<String>;
            final String tripId = tripCardValueKey.value.split('_').last;

            // ✅ Salvataggio di un viaggio, incremento e decremento del counter
            await tester.ensureVisible(find.byKey(Key('tripCard_$tripId')));
            await tester.pumpAndSettle();

            final saveButtonKey = Key('saveButton_$tripId');
            final saveCounterKey = Key('saveCounter_$tripId');
            final saveButton = find.byKey(saveButtonKey);
            final saveCounter = find.byKey(saveCounterKey);
            expect(saveButton, findsOneWidget);
            expect(saveCounter, findsOneWidget);
            await tester.ensureVisible(saveButton);
            await tester.pumpAndSettle();

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

            await tester.enterText(searchBar, ''); // Inserisci una stringa vuota
            await tester.pumpAndSettle();
      });
            

      //-----------ORDINARE I VIAGGI-----------------
      testWidgets('ExplorerPage ordina i viaggi per popolarità', (WidgetTester tester) async {
            app.main();
            // ✅ Login
            await tester.pumpAndSettle(); // Attende che l'app si avvii e si stabilizzi
            final emailFieldFinder = find.byKey(const Key('emailField'));
            await tester.pumpAndSettle();
            await tester.ensureVisible(emailFieldFinder);
            await tester.pumpAndSettle(); // Attende che il campo sia completamente visibile e stabile

            await tester.enterText(emailFieldFinder, 'leo@mail.com');
            await tester.pumpAndSettle();
            await tester.enterText(find.byKey(const Key('passwordField')), '123456');
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('submitButton')));
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(milliseconds: 1000));

            // ✅ Trova la SearchBar e l'icona del filtro
            final searchBar = find.byKey(const Key('searchBar'));
            await tester.pumpAndSettle();
            await tester.ensureVisible(searchBar);
            await tester.pumpAndSettle();
            expect(searchBar, findsOneWidget); // Assicurati che la searchBar sia presente
            await tester.ensureVisible(searchBar);
            await tester.pumpAndSettle();

            // Trova l'icona del filtro all'interno della SearchBar e tappala
            final filterIconFinder = find.descendant(
                  of: searchBar,
                  matching: find.byIcon(Icons.filter_alt_outlined),
            );
            expect(filterIconFinder, findsOneWidget); // Verifica che l'icona esista

            await tester.tap(filterIconFinder);
            await tester.pumpAndSettle(); // Attende che il bottom sheet di ordinamento si apra

            await Future.delayed(const Duration(milliseconds: 1500));

            // ✅ Verifica che il bottom sheet sia visibile e trovi l'opzione "Più popolari"
            expect(find.text('Ordina Per'), findsOneWidget); // Verifica che il titolo del modal sia presente
            final sortByPopularFinder = find.text('Più popolari');
            expect(sortByPopularFinder, findsOneWidget); // Verifica che l'opzione "Più popolari" esista

            await tester.pumpAndSettle();

            // ✅ Tappa l'opzione "Più popolari"
            await tester.tap(sortByPopularFinder);
            await tester.pumpAndSettle(); // Attende che il modal si chiuda e la lista si riordini

            // ✅ Verifica che il bottom sheet sia stato chiuso
            expect(find.text('Ordina Per'), findsNothing); // Il titolo del modal non dovrebbe più essere visibile

            // Assicurati che la lista dei viaggi sia visibile dopo l'ordinamento
            expect(find.byKey(const Key('tripList')), findsOneWidget);
            await tester.pumpAndSettle();

            await Future.delayed(const Duration(milliseconds: 2000));
            // Fine DEBUGGING

            // ✨ Verifica l'ordine degli elementi dopo il sorting per popolarità
            // Trova tutti i TripCardWidget presenti
            final Finder allTripCardsFinder = find.byWidgetPredicate(
                      (widget) => widget is TripCardWidget,
            );

            await tester.pumpAndSettle();

            await Future.delayed(const Duration(milliseconds: 1000));

            // Assicurati che ci siano almeno due trip card per poter confrontare
            expect(allTripCardsFinder, findsAtLeastNWidgets(2));

            // Recupera i TripCardWidget e i loro contatori di salvataggio
            final TripCardWidget firstTripCard = tester.widget<TripCardWidget>(allTripCardsFinder.at(0));
            final int firstTripSaveCounter = firstTripCard.trip.saveCounter ?? 0;

            final TripCardWidget secondTripCard = tester.widget<TripCardWidget>(allTripCardsFinder.at(1));
            final int secondTripSaveCounter = secondTripCard.trip.saveCounter ?? 0;

            // Asserisci che il contatore del primo viaggio sia maggiore o uguale al secondo
            expect(firstTripSaveCounter, greaterThanOrEqualTo(secondTripSaveCounter),
                reason: 'Il primo viaggio dovrebbe avere un contatore di salvataggi >= del secondo dopo l\'ordinamento per popolarità.');

            // Per ora, ci assicuriamo che la lista sia ancora presente e visibile.
            expect(find.byKey(const Key('tripList')), findsOneWidget);
      });
}

