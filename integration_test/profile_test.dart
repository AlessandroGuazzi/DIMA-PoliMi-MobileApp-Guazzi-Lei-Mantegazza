import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dopo il login si accede alla ProfilePage', (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 1500));

    // ✅ Login
    final emailFieldFinder = find.byKey(const Key('emailField'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(emailFieldFinder);
    await tester.enterText(emailFieldFinder, 'leo@mail.com');
    await tester.pumpAndSettle();

    final passwordFieldFinder = find.byKey(const Key('passwordField'));
    await tester.ensureVisible(passwordFieldFinder);
    await tester.enterText(passwordFieldFinder, '123456');
    await tester.pumpAndSettle();

    final submitButtonFinder = find.byKey(const Key('submitButton'));
    await tester.ensureVisible(submitButtonFinder);
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(milliseconds: 2500));

    // ✅ Navigazione verso la ProfilePage
    await tester.pumpAndSettle();
    final profileButton = find.byKey(const Key('profileButton'));
    await tester.ensureVisible(profileButton);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 1500));


    // ✅ Verifica che la ProfilePage sia caricata
    final profileNameFinder = find.text('Leo Lei'); // O cambia con un Key specifico
    await tester.pumpAndSettle();
    await tester.ensureVisible(profileNameFinder);
    expect(profileNameFinder, findsOneWidget, reason: 'Il tuo nome deve essere visibile');


    // Apri il bottom sheet delle impostazioni
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Tocca “Modifica Profilo”
    final editProfileTile = find.byKey(const Key('Modifica Profilo'));
    await tester.ensureVisible(editProfileTile);
    await tester.tap(editProfileTile);
    await tester.pumpAndSettle();



    // Cambia nome
    final nameFieldFinder = find.byKey(const Key('nameField'));
    expect(nameFieldFinder, findsOneWidget);
    await tester.enterText(nameFieldFinder, 'Leonardo');
    await tester.pumpAndSettle();

    // Cambia cognome
    final surnameFieldFinder = find.byKey(const Key('surnameField'));
    expect(surnameFieldFinder, findsOneWidget);
    await tester.enterText(surnameFieldFinder, 'Modificato');
    await tester.pumpAndSettle();

    // Premi salva
    final saveButton = find.byKey(const Key('saveButton'));
    await Future.delayed(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // ✅ Gestione del dialog di conferma
    final confirmButtonFinder = find.text('CONFERMA');
    await tester.pumpAndSettle();
    final annullaButtonFinder = find.text('ANNULLA');
    expect(confirmButtonFinder, findsOneWidget, reason: 'Il dialog di conferma deve comparire');
    expect(annullaButtonFinder, findsOneWidget, reason: 'Il tasto per annullare il salvataggio delle modifiche deve esserci');
    await tester.tap(confirmButtonFinder);
    await tester.pumpAndSettle();

    // (Opzionale) Attendi che salvataggio + navigazione avvengano
    await Future.delayed(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // (Opzionale) Verifica che il nome aggiornato sia visibile nella ProfilePage
    expect(find.text('Leonardo Modificato'), findsWidgets);
    // ATTENZIONE:
    // NOTA CHE QUESTO TEST PASSA SOLO SE NOME E COGNOME SONO INIZIALMENTE LEO LEI


    // ✅ Logout
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    final logoutTile = find.byKey(const Key('Logout'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(logoutTile);
    await tester.tap(logoutTile);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(milliseconds: 1000));

    // ✅ Verifica che siamo tornati alla LoginPage
    final loginTitleFinder = find.text('Welcome'); // O un Key come 'loginPage'
    await tester.pumpAndSettle();
    expect(loginTitleFinder, findsOneWidget, reason: 'Dopo il logout bisogna tornare alla pagina di login');

    // (Opzionale) Verifica che i campi email/password siano presenti
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('submitButton')), findsOneWidget);

  });



}
