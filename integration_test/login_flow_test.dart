import 'package:dima_project/screens/authenticationPage.dart';
import 'package:dima_project/screens/explorerPage.dart';
import 'package:dima_project/screens/homePage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Registration with already existing credentials", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final toggleButton = find.byKey(const Key('toggleAuthMode'));
    await tester.ensureVisible(toggleButton);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nameField')), 'Test');
    await tester.enterText(find.byKey(const Key('surnameField')), 'User');
    await tester.enterText(find.byKey(const Key('usernameField')), 'test.user');
    await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');

    await tester.tap(find.byKey(const Key('birthDateField')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('${DateTime.now().day}'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nationalityField')));
    await tester.pumpAndSettle();

    //find searchBar
    final searchBar = find.byType(SearchBar);
    await tester.enterText(searchBar, 'Ital');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Italy'));
    await tester.pumpAndSettle();

    // Submit registration
    final submitButton = find.byKey(const Key('submitButton'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));


    //expect snackbar + remains on AuthPage
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(AuthPage), findsOneWidget);
  });

  testWidgets("Login with badly formatted email", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('submitButton'));

    await tester.enterText(emailField, 'bad-email');
    await tester.enterText(passwordField, 'password');

    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('The email address is badly formatted.'), findsOneWidget);
    expect(find.byType(MyHomePage), findsNothing);
    expect(find.byType(ExplorerPage), findsNothing);
  });

  testWidgets("Login with wrong credentials", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('submitButton'));

    await tester.enterText(emailField, 'wrong@example.com');
    await tester.enterText(passwordField, 'password');

    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('The supplied auth credential is incorrect, malformed or has expired.'), findsOneWidget);
    expect(find.byType(MyHomePage), findsNothing);
    expect(find.byType(ExplorerPage), findsNothing);
  });

  testWidgets("Login with correct credentials test", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('submitButton'));

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password');

    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ExplorerPage), findsOneWidget);
  });
}