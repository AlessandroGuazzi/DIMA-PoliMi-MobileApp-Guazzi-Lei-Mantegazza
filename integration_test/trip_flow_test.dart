import 'package:dima_project/screens/myTripsPage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Trip Flow Tests', () {
    setUp(() async {
      // Could add setup logic if needed
    });

    testWidgets('User creates a trip', (WidgetTester tester) async {
      await performLogin(tester);
      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //tap on add trip button
      final addTripButton = find.byType(FloatingActionButton);
      await tester.ensureVisible(addTripButton);
      await tester.tap(addTripButton);
      await tester.pumpAndSettle();

      //fill form
      ///title
      final titleField = find.byKey(const Key('titleField'));
      await tester.enterText(titleField, 'Test Trip');
      await tester.pumpAndSettle();

      ///countries
      final countriesField = find.byKey(const Key('countriesField'));
      await tester.ensureVisible(countriesField);
      await tester.tap(countriesField);
      await tester.pumpAndSettle();

      //find search bar and enter 'Italy + United States'
      final countrySearchBar = find.byType(SearchBar);

      await tester.enterText(countrySearchBar, 'United State');
      await tester.pumpAndSettle();
      await tester.tap(find.text('United States'));
      await tester.pumpAndSettle();

      await tester.enterText(countrySearchBar, 'Ital');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Italy'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();


      ///cities
      final citiesField = find.byKey(const Key('citiesField'));
      await tester.ensureVisible(citiesField);
      await tester.tap(citiesField);
      await tester.pumpAndSettle();

      //find search bar and enter 'Rome'
      final citySearchBar = find.byType(SearchBar);

      await tester.enterText(citySearchBar, 'Rom');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Roma'));
      await tester.pumpAndSettle();

      await tester.enterText(citySearchBar, 'New Yor');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('New York'));
      await tester.pumpAndSettle();

      ///dates
      final datesField = find.byKey(const Key('datesField'));
      await tester.ensureVisible(datesField);
      await tester.tap(datesField);
      await tester.pumpAndSettle();

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final nextWeek = tomorrow.add(const Duration(days: 7));
      await tester.tap(find.text('${tomorrow.day}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('${nextWeek.day}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      ///submit
      final submitButton = find.byKey(const Key('submitButton'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      //assert that we are in myTripsPage and trip is visible
      expect(find.byType(MyTripsPage), findsOneWidget);
      expect(find.text('Test Trip'), findsOneWidget);
    });

    testWidgets('User adds an activity to a trip', (WidgetTester tester) async {
      await performLogin(tester);
      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created test
      final testTrip = find.text('Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.tap(testTrip);
      await tester.pumpAndSettle();

      //tap on add activity button
      final addActivityButton = find.byKey(const Key('newActivityButton'));
      await tester.ensureVisible(addActivityButton);
      await tester.tap(addActivityButton);
      await tester.pumpAndSettle();

      //tap on flight button
      final flightButton = find.widgetWithText(ListTile, 'Volo');
      await tester.ensureVisible(flightButton);
      await tester.tap(flightButton);
      await tester.pumpAndSettle();

      //fill form
      ///departure airport
      final departureAirportField = find.byKey(const Key('departureAirportField'));
      await tester.ensureVisible(departureAirportField);
      await tester.tap(departureAirportField);
      await tester.pumpAndSettle();

      ///departure date
      final departureDateField = find.byKey(const Key('departureDateField'));
      await tester.ensureVisible(departureDateField);
      await tester.tap(departureDateField);
      await tester.pumpAndSettle();

    });

    testWidgets('User edits activity details', (WidgetTester tester) async {
      await performLogin(tester);

      // TODO: Navigate to existing activity
      // TODO: Edit fields and save
      // TODO: Verify changes are visible
    });

    testWidgets('User removes an activity from a trip', (WidgetTester tester) async {
      await performLogin(tester);

      // TODO: Navigate to activity
      // TODO: Tap delete/remove
      // TODO: Confirm activity is gone
    });

    testWidgets('User modifies trip details', (WidgetTester tester) async {
      await performLogin(tester);

      // TODO: Navigate to trip
      // TODO: Tap "Edit Trip"
      // TODO: Change title/dates/etc.
      // TODO: Confirm changes
    });

    testWidgets('User opens map of a trip', (WidgetTester tester) async {
      await performLogin(tester);

      // TODO: Open trip
      // TODO: Tap "Map"
      // TODO: Check map is shown (find map widget or screen title)
    });

    testWidgets('User adds trip to calendar', (WidgetTester tester) async {
      await performLogin(tester);

      // TODO: Open trip
      // TODO: Tap "Add to calendar"
      // TODO: Verify integration or confirmation dialog
    });

    testWidgets('User checks expenses and changes currency', (WidgetTester tester) async {
      await performLogin(tester);

      // TODO: Open trip -> expenses
      // TODO: Change currency from dropdown or settings
      // TODO: Assert updated display
    });

    testWidgets('User deletes a trip', (WidgetTester tester) async {
      await performLogin(tester);

      // TODO: Navigate to trip
      // TODO: Tap delete
      // TODO: Confirm deletion and check trip is gone
    });
  });
}

Future<void> performLogin(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Assumes AuthPage is shown
  final emailField = find.byKey(const Key('emailField'));
  final passwordField = find.byKey(const Key('passwordField'));
  final submitButton = find.byKey(const Key('submitButton'));

  await tester.enterText(emailField, 'test@example.com');
  await tester.enterText(passwordField, 'password');

  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));
}