import 'package:dima_project/screens/authenticationPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/main.dart' as app;
import 'package:integration_test/integration_test.dart';

import 'integration_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  //dummy test to ensure that we are logged out
  testWidgets('User logs out', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    if (find.byType(AuthPage).evaluate().isEmpty) {
      await IntegrationTestHelper().performLogout(tester);
    }
    ;
    await tester.pumpAndSettle();
  });

  testWidgets('ExplorerPage visualizza e interagisce con i viaggi pubblici',
      (WidgetTester tester) async {
    await IntegrationTestHelper().performLogin(tester);

    //Ricerca di un viaggio, nome del viaggio hardcoded: 'Integration test'
    final searchBar = find.byKey(const Key('searchBar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(searchBar);
    await tester.pumpAndSettle();
    await tester.enterText(searchBar, 'Integration tes');
    await tester.pumpAndSettle();

    //Trova la prima trip card
    final tripCardFinder = find
        .byWidgetPredicate(
          (widget) =>
              widget.key is ValueKey<String> &&
              (widget.key as ValueKey<String>).value.startsWith('tripCard_'),
        )
        .first;
    expect(tripCardFinder, findsOneWidget);

    // Estrai l'ID del viaggio dalla trip card per usarlo come chiave per il salvataggio
    final ValueKey<String> tripCardValueKey =
        tester.widget<Card>(tripCardFinder).key as ValueKey<String>;
    final String tripId = tripCardValueKey.value.split('_').last;

    //Salvataggio di un viaggio, incremento e decremento del counter
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

    //Valore iniziale
    final initialText = tester.widget<Text>(saveCounter).data!;
    final initialValue = int.tryParse(initialText) ?? 0;

    //Salva
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final updatedText = tester.widget<Text>(saveCounter).data!;
    final updatedValue = int.tryParse(updatedText) ?? 0;
    expect(updatedValue, initialValue + 1);

    //Rimuovi salvataggio
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final finalText = tester.widget<Text>(saveCounter).data!;
    final finalValue = int.tryParse(finalText) ?? 0;
    expect(finalValue, initialValue);

    await tester.enterText(searchBar, '');
    await tester.pumpAndSettle();

    await IntegrationTestHelper().performLogout(tester);
  });

  //-----------ORDINARE I VIAGGI-----------------
  testWidgets('ExplorerPage ordina i viaggi per popolarita',
      (WidgetTester tester) async {
    await IntegrationTestHelper().performLogin(tester);

    final searchBar = find.byKey(const Key('searchBar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(searchBar);
    await tester.pumpAndSettle();
    expect(
        searchBar, findsOneWidget);
    await tester.ensureVisible(searchBar);
    await tester.pumpAndSettle();

    // Trova l'icona del filtro all'interno della SearchBar e tappala
    final filterIconFinder = find.descendant(
      of: searchBar,
      matching: find.byIcon(Icons.filter_alt_outlined),
    );
    expect(filterIconFinder, findsOneWidget);

    await tester.tap(filterIconFinder);
    await tester
        .pumpAndSettle();

    await Future.delayed(const Duration(milliseconds: 1500));

    //Verifica che il bottom sheet sia visibile e trovi l'opzione "Più popolari"
    expect(find.text('Ordina Per'),
        findsOneWidget);
    final sortByPopularFinder = find.text('Più popolari');
    expect(sortByPopularFinder,
        findsOneWidget);

    await tester.pumpAndSettle();

    //Tappa l'opzione "Più popolari"
    await tester.tap(sortByPopularFinder);
    await tester
        .pumpAndSettle();

    //Verifica che il bottom sheet sia stato chiuso
    expect(find.text('Ordina Per'),
        findsNothing);

    // Assicurati che la lista dei viaggi sia visibile dopo l'ordinamento
    expect(find.byKey(const Key('tripList')), findsOneWidget);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(milliseconds: 2000));
    // Fine DEBUGGING

    //Verifica l'ordine degli elementi dopo il sorting per popolarità
    // Trova tutti i TripCardWidget presenti
    final Finder allTripCardsFinder = find.byWidgetPredicate(
      (widget) => widget is TripCardWidget,
    );

    await tester.pumpAndSettle();

    await Future.delayed(const Duration(milliseconds: 1000));

    //Assicurati che ci siano almeno due trip card per poter confrontare
    expect(allTripCardsFinder, findsAtLeastNWidgets(2));

    //Recupera i TripCardWidget e i loro contatori di salvataggio
    final TripCardWidget firstTripCard =
        tester.widget<TripCardWidget>(allTripCardsFinder.at(0));
    final int firstTripSaveCounter = firstTripCard.trip.saveCounter ?? 0;

    final TripCardWidget secondTripCard =
        tester.widget<TripCardWidget>(allTripCardsFinder.at(1));
    final int secondTripSaveCounter = secondTripCard.trip.saveCounter ?? 0;

    //Asserisci che il contatore del primo viaggio sia maggiore o uguale al secondo
    expect(firstTripSaveCounter, greaterThanOrEqualTo(secondTripSaveCounter),
        reason:
            'Il primo viaggio dovrebbe avere un contatore di salvataggi >= del secondo dopo l\'ordinamento per popolarità.');

    //Per ora, ci assicuriamo che la lista sia ancora presente e visibile.
    expect(find.byKey(const Key('tripList')), findsOneWidget);

    await IntegrationTestHelper().performLogout(tester);
  });
}
