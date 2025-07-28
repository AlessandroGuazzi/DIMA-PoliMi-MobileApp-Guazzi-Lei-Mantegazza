import 'package:dima_project/screens/profilePage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/main.dart' as app;
import 'package:integration_test/integration_test.dart';

import 'integration_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Modifica i dati del proprio profilo', (WidgetTester tester) async {
    await IntegrationTestHelper().performLogin(tester);

    //Navigazione verso la ProfilePage
    await tester.pumpAndSettle();
    final profileButton = find.byKey(const Key('profileButton'));
    await tester.ensureVisible(profileButton);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(ProfilePage), findsOneWidget);

    expect(find.text('New Name New Surname'), findsNothing, reason: 'Il profilo non dovrebbe essere ancora modificato');

    Future<void> changeNameSurname( String name, String surname) async {
      await tester.tap(find.byKey(const Key('settingsButton')));
      await tester.pumpAndSettle();
      // Tocca “Modifica Profilo”
      final editProfileTile = find.byKey(const Key('Modifica Profilo'));
      await tester.ensureVisible(editProfileTile);
      await tester.tap(editProfileTile);
      await tester.pumpAndSettle();

      // Cambia nome
      final nameFieldFinder = find.byKey(const Key('nameField'));
      expect(nameFieldFinder, findsOneWidget);
      await tester.enterText(nameFieldFinder, name);
      await tester.pumpAndSettle();

      // Cambia cognome
      final surnameFieldFinder = find.byKey(const Key('surnameField'));
      expect(surnameFieldFinder, findsOneWidget);
      await tester.enterText(surnameFieldFinder, surname);
      await tester.pumpAndSettle();

      // Salva
      final saveButton = find.byKey(const Key('saveButton'));
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Gestione del dialog di conferma
      final confirmButtonFinder = find.text('CONFERMA');
      await tester.pumpAndSettle();
      final annullaButtonFinder = find.text('ANNULLA');
      expect(confirmButtonFinder, findsOneWidget, reason: 'Il dialog di conferma deve comparire');
      expect(annullaButtonFinder, findsOneWidget, reason: 'Il tasto per annullare il salvataggio delle modifiche deve esserci');
      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
    }

    await changeNameSurname('New Name', 'New Surname');
    expect(find.text('New Name New Surname'), findsOneWidget);

    //ritorna a situazione iniziale
    await changeNameSurname('Test', 'Example');
    expect(find.text('Test Example'), findsOneWidget);



    await IntegrationTestHelper().performLogout(tester);

  });


  testWidgets('Cambia tema da chiaro a scuro e viceversa', (WidgetTester tester) async {

    await IntegrationTestHelper().performLogin(tester);

    // Invece di brightness, verifica il themeMode
    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);

    // Navigazione verso la ProfilePage
    await tester.pumpAndSettle();
    final profileButton = find.byKey(const Key('profileButton'));
    await tester.ensureVisible(profileButton);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 1500));

    // Apri il bottom sheet delle impostazioni
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Tocca il pulsante per cambiare tema
    final themeToggleFinder = find.byKey(const Key('Theme Settings'));
    await tester.ensureVisible(themeToggleFinder);
    await tester.tap(themeToggleFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    print('Widget theme: ${materialApp.themeMode}');
    await Future.delayed(const Duration(milliseconds: 2000));


    // Verifica che il tema sia cambiato a scuro
    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    await tester.pumpAndSettle();
    print('Widget theme: ${materialApp.themeMode}');

    // Apri il bottom sheet delle impostazioni e ricambia il tema a chiaro nuovamente
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.ensureVisible(themeToggleFinder);
    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 1500));

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
    await tester.pumpAndSettle();

    await IntegrationTestHelper().performLogout(tester);
  });

}
