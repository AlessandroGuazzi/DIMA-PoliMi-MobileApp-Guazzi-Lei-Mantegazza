import 'package:dima_project/main.dart' as app;
import 'package:dima_project/screens/authenticationPage.dart';
import 'package:dima_project/screens/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


class IntegrationTestHelper {

  Future<void> performLogin(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final submitButton = find.byKey(const Key('submitButton'));

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password');
    await tester.pumpAndSettle();

    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    // Wait until MyHomePage appear
    while (find.byType(MyHomePage).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> performLogout(WidgetTester tester) async {

    final bottomBar = find.byType(BottomAppBar);
    await tester.pumpAndSettle();
    //if bottom bar is not present
    while (!tester.any(bottomBar)) {
      //navigate back
      final backButton = find.byType(BackButtonIcon);
      await tester.ensureVisible(backButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(BottomAppBar), findsOneWidget);


    //tap on profile button
    final profileButton = find.byKey(const Key('profileButton'));
    await tester.ensureVisible(profileButton);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();
    //tap on settings button
    final settingsButton = find.byKey(const Key('settingsButton'));
    await tester.ensureVisible(settingsButton);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    //tap on logout
    final logoutButton = find.text('Log Out');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();
  }
}