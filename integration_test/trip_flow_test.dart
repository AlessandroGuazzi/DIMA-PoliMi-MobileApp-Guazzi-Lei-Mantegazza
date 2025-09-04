import 'package:dima_project/screens/authenticationPage.dart';
import 'package:dima_project/screens/editActivityPage.dart';
import 'package:dima_project/screens/mapPage.dart';
import 'package:dima_project/screens/myTripsPage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:dima_project/widgets/activity_widgets/attractionActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/forms/AccommodationForm.dart';
import 'package:dima_project/widgets/activity_widgets/accommodationActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/flightActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/forms/AttractionForm.dart';
import 'package:dima_project/widgets/activity_widgets/forms/TransportForm.dart';
import 'package:dima_project/widgets/activity_widgets/transportActivityCard.dart';
import 'package:dima_project/widgets/search_bottom_sheets/placesSearchWidget.dart';
import 'package:dima_project/widgets/trip_widgets/itineraryWidget.dart';
import 'package:dima_project/widgets/trip_widgets/tripExpensesWidget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart' as app;
import 'package:flutter/material.dart';

import 'integration_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Trip Flow Tests', () {

    //dummy test to ensure that we are logged out
    testWidgets('User logs out', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      if(find.byType(AuthPage).evaluate().isEmpty) {
        await IntegrationTestHelper().performLogout(tester);
      };
      await tester.pumpAndSettle();
    });

    testWidgets('User creates a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);
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
      await insertCity(tester, 'Roma');
      await insertCity(tester, 'New York');

      ///dates
      final datesField = find.byKey(const Key('datesField'));
      await tester.ensureVisible(datesField);
      await tester.tap(datesField);
      await tester.pumpAndSettle();

      final today = DateTime.now();

      final startDay = find.text('${today.day}').first;
      await tester.ensureVisible(startDay);
      await tester.tap(startDay);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      final endDay = find.text('${today.day}').last;
      await tester.ensureVisible(endDay);
      await tester.tap(endDay);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      ///submit
      final submitButton = find.byKey(const Key('submitButton'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      //assert that we are in myTripsPage and trip is visible
      expect(find.byType(MyTripsPage), findsOneWidget);
      expect(find.text('Test Trip'), findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User adds a flight activity to a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);
      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.pumpAndSettle();
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created test
      final testTrip = find.text('Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.pumpAndSettle();
      await tester.tap(testTrip);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on add activity button
      final addActivityButton = find.byKey(const Key('newActivityButton'));
      expect(addActivityButton, findsOneWidget);
      await tester.tap(addActivityButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on flight button
      final flightButton = find.widgetWithText(ListTile, 'Volo');
      await tester.ensureVisible(flightButton);
      await tester.pumpAndSettle();
      await tester.tap(flightButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //fill form
      ///departure airport
      await insertAirport(tester, 'Fiumicino', find.byKey(const Key('departureAirportField')));
      ///arrival airport
      await insertAirport(tester, 'John F Kennedy', find.byKey(const Key('arrivalAirportField')));
      ///departure date
      final departureDateField = find.byKey(const Key('departureDateField'));
      await tester.ensureVisible(departureDateField);
      await tester.tap(departureDateField);
      await tester.pumpAndSettle();
      final okDateButton = find.text('OK');
      expect(okDateButton, findsOneWidget);
      await tester.tap(okDateButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      ///departure time
      final departureTimeField = find.byKey(const Key('departureTimeField'));
      await tester.ensureVisible(departureTimeField);
      await tester.tap(departureTimeField);
      await tester.pumpAndSettle();
      final okTimeButton = find.text('OK');
      expect(okTimeButton, findsOneWidget);
      await tester.tap(okTimeButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      ///duration
      final durationField = find.byKey(const Key('durationField'));
      await tester.enterText(durationField, '2');
      await tester.pumpAndSettle();

      //submit
      final submitButton = find.byKey(const Key('submitButton'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds:2));

      //assert
      final flightCardFinder = find.byWidgetPredicate((widget) {
        return widget is FlightActivityCard &&
            widget.flight.departureAirPort?['iata']?.contains('FCO') == true &&
            widget.flight.arrivalAirPort?['iata']?.contains('JFK') == true;
      });
      expect(flightCardFinder, findsOneWidget);
      //click to expand
      final expandButton = find.byKey(const Key('expandButton'));
      expect(expandButton, findsOneWidget);
      await tester.ensureVisible(expandButton);
      await tester.pumpAndSettle();
      await tester.tap(expandButton);
      await tester.pumpAndSettle();
      //assert
      expect(find.textContaining('Costo'), findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User adds an accommodation activity to a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);
      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.pumpAndSettle();
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created test
      final testTrip = find.text('Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.pumpAndSettle();
      await tester.tap(testTrip);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on add activity button
      final addActivityButton = find.byKey(const Key('newActivityButton'));
      expect(addActivityButton, findsOneWidget);
      await tester.tap(addActivityButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on flight button
      final flightButton = find.widgetWithText(ListTile, 'Alloggio');
      await tester.ensureVisible(flightButton);
      await tester.pumpAndSettle();
      await tester.tap(flightButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //fill form
      ///name
      final nameField = find.byKey(const Key('nameField'));
      await tester.ensureVisible(nameField);
      await tester.pumpAndSettle();
      await tester.tap(nameField);
      await tester.pumpAndSettle();
      expect(find.byType(PlacesSearchWidget), findsOneWidget);
      //find searchBar
      final searchBar = find.byKey(const Key('placesSearchBar'));
      await tester.enterText(searchBar, 'A');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      //click on the first result
      final firstResult = find.byType(ListTile).first;
      await tester.ensureVisible(firstResult);
      await tester.pumpAndSettle();
      await tester.tap(firstResult);
      await tester.pumpAndSettle();
      ///dates
      final state = tester.state(find.byType(AccommodationForm)) as dynamic;
      //fill dates
      state.startDate = DateTime.now().add(const Duration(days: 1));
      state.endDate = DateTime.now().add(const Duration(days: 2));
      //add cost
      final costField = find.byKey(const Key('costField'));
      await tester.enterText(costField, '100');
      await tester.pumpAndSettle();
      //submit
      final submitButton = find.byKey(const Key('add_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds:2));

      //assert
      final accommodationCardFinder = find.byWidgetPredicate((widget) {
        return widget is AccommodationActivityCard &&
            widget.accommodation.name?.contains('A') == true;
      });
      expect(accommodationCardFinder, findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User adds an attraction activity to a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);
      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.pumpAndSettle();
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created test trip
      final testTrip = find.text('Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.pumpAndSettle();
      await tester.tap(testTrip);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on add activity button
      final addActivityButton = find.byKey(const Key('newActivityButton'));
      expect(addActivityButton, findsOneWidget);
      await tester.tap(addActivityButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on attraction button
      final flightButton = find.widgetWithText(ListTile, 'Attrazione');
      await tester.ensureVisible(flightButton);
      await tester.pumpAndSettle();
      await tester.tap(flightButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //fill form
      ///location
      final locationField = find.byKey(const Key('locationField'));
      await tester.ensureVisible(locationField);
      await tester.pumpAndSettle();
      await tester.tap(locationField);
      await tester.pumpAndSettle();
      expect(find.byType(PlacesSearchWidget), findsOneWidget);
      //find searchBar
      final searchBar = find.byKey(const Key('placesSearchBar'));
      await tester.enterText(searchBar, 'A');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      //click on the first result
      final firstResult = find.byType(ListTile).first;
      await tester.ensureVisible(firstResult);
      await tester.pumpAndSettle();
      await tester.tap(firstResult);
      await tester.pumpAndSettle();
      ///dates
      final state = tester.state(find.byType(AttractionForm)) as dynamic;
      //fill dates
      state.startDate = DateTime.now().add(const Duration(days: 1));
      state.endDate = DateTime.now().add(const Duration(days: 2));
      //add cost with change of currency
      final costField = find.byKey(const Key('costField'));
      await tester.ensureVisible(costField);
      await tester.pumpAndSettle();
      //find currency dropdown
      final currencyDropdown = find.byKey(const Key('currencyDropdown'));
      await tester.ensureVisible(currencyDropdown);
      await tester.pumpAndSettle();
      await tester.tap(currencyDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('\$'));
      await tester.pumpAndSettle();
      //add cost
      await tester.enterText(costField, '100');
      await tester.pumpAndSettle();
      //submit
      final submitButton = find.byKey(const Key('submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await pumpUntilFound(tester, find.byType(ItineraryWidget));


      //assert
      final attractionCardFinder = find.byWidgetPredicate((widget) {
        return widget is AttractionActivityCard &&
            widget.attraction.name?.contains('A') == true;
      });
      expect(attractionCardFinder, findsOneWidget);


      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User adds a transport activity to a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);
      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.pumpAndSettle();
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created test trip
      final testTrip = find.text('Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.pumpAndSettle();
      await tester.tap(testTrip);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on add activity button
      final addActivityButton = find.byKey(const Key('newActivityButton'));
      expect(addActivityButton, findsOneWidget);
      await tester.tap(addActivityButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //tap on attraction button
      final flightButton = find.widgetWithText(ListTile, 'Altri Trasporti');
      await tester.ensureVisible(flightButton);
      await tester.pumpAndSettle();
      await tester.tap(flightButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //fill form
      ///departure
      final locationField = find.byKey(const Key('departurePlaceField'));
      await tester.ensureVisible(locationField);
      await tester.pumpAndSettle();
      await tester.enterText(locationField, 'Roma');
      await tester.pumpAndSettle();
      ///arrival
      final arrivalField = find.byKey(const Key('arrivalPlaceField'));
      await tester.ensureVisible(arrivalField);
      await tester.pumpAndSettle();
      await tester.enterText(arrivalField, 'Milano');
      await tester.pumpAndSettle();
      ///date and time
      final state = tester.state(find.byType(TransportForm)) as dynamic;
      //fill date and time
      state.departureDate = DateTime.now().add(const Duration(days: 1));
      //time
      final timeField = find.byKey(const Key('departureTimeField'));
      await tester.ensureVisible(timeField);
      await tester.pumpAndSettle();
      await tester.tap(timeField);
      await tester.pumpAndSettle();

      final okTimeButton = find.text('OK');
      expect(okTimeButton, findsOneWidget);
      await tester.tap(okTimeButton);
      await tester.pumpAndSettle();

      ///transport time
      final typeDropdown = find.byKey(const Key('transportTypeDropdown'));
      await tester.ensureVisible(typeDropdown);
      await tester.pumpAndSettle();
      await tester.tap(typeDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Treno'));
      await tester.pumpAndSettle();

      ///cost
      final costField = find.byKey(const Key('costField'));
      await tester.enterText(costField, '100');
      await tester.pumpAndSettle();

      //submit
      final submitButton = find.byKey(const Key('submitButton'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds:2));

      //assert
      final transportCardFinder = find.byWidgetPredicate((widget) {
        return widget is TransportActivityCard &&
            widget.transport.departurePlace?.contains('Roma') == true;
      });
      expect(transportCardFinder, findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User edits activity details', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);

      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created trip
      final testTrip = find.text('Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.pumpAndSettle();
      await tester.tap(testTrip);
      await tester.pumpAndSettle();

      //find previously created activity (flight)
      final flightCardFinder = find.byWidgetPredicate((widget) {
        return widget is FlightActivityCard &&
            widget.flight.departureAirPort?['iata']?.contains('FCO') == true &&
            widget.flight.arrivalAirPort?['iata']?.contains('JFK') == true;
      });
      expect(flightCardFinder, findsOneWidget);
      final activityMenuButton = find.byKey(const Key('activityMenu')).first;
      await tester.ensureVisible(activityMenuButton);
      await tester.pumpAndSettle();
      await tester.tap(activityMenuButton);
      await tester.pumpAndSettle();

      //tap on edit button
      final editButton = find.textContaining('Modifica');
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);

      //change departure airport
      await insertAirport(tester, 'Malpensa', find.byKey(const Key('departureAirportField')));
      //change duration
      final durationField = find.byKey(const Key('durationField'));
      await tester.enterText(durationField, '3');
      await tester.pumpAndSettle();

      //submit
      final submitButton = find.byKey(const Key('submitButton'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds:2));
      //Verify changes are visible

      //assert
      final newFlightCardFinder = find.byWidgetPredicate((widget) {
        return widget is FlightActivityCard &&
            widget.flight.departureAirPort?['iata']?.contains('MXP') == true &&
            widget.flight.arrivalAirPort?['iata']?.contains('JFK') == true;
      });
      expect(newFlightCardFinder, findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User modifies trip details', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);

      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created trip
      final testTrip = find.text('Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.tap(testTrip);
      await tester.pumpAndSettle();
      //navigate to update page
      final editButton = find.byKey(const Key('editButton'));
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.text('Modifica'), findsOneWidget);
      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();
      expect(find.byType(UpsertTripPage), findsOneWidget);
      //change title
      final titleField = find.byKey(const Key('titleField'));
      await tester.enterText(titleField, 'New Test Trip');
      await tester.pumpAndSettle();
      //Confirm changes
      final submitButton = find.byKey(const Key('submitButton'));
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      //assert new title
      expect(find.text('New Test Trip'), findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User removes an activity from a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);

      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created trip
      final testTrip = find.text('New Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.pumpAndSettle();
      await tester.tap(testTrip);
      await tester.pumpAndSettle();

      //find previously created activity (flight)
      final flightCardFinder = find.byWidgetPredicate((widget) {
        return widget is FlightActivityCard &&
            widget.flight.departureAirPort?['iata']?.contains('MXP') == true &&
            widget.flight.arrivalAirPort?['iata']?.contains('JFK') == true;
      });
      expect(flightCardFinder, findsOneWidget);
      //open menu
      final activityMenuButton = find.byKey(const Key('activityMenu')).first;
      await tester.ensureVisible(activityMenuButton);
      await tester.pumpAndSettle();
      await tester.tap(activityMenuButton);
      await tester.pumpAndSettle();

      //tap on delete button
      final editButton = find.textContaining('Elimina');
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      //tap on confirm
      final confirmButton = find.widgetWithText(TextButton, 'Conferma');
      await tester.ensureVisible(confirmButton);
      await tester.pumpAndSettle();
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      //Confirm activity is gone
      expect(flightCardFinder, findsNothing);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User opens map of a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);

      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created trip
      final testTrip = find.text('New Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.tap(testTrip);
      await tester.pumpAndSettle();
      //navigate to map page
      final editButton = find.byKey(const Key('editButton'));
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.text('Apri mappa'), findsOneWidget);
      await tester.tap(find.text('Apri mappa'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(MapPage), findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User checks expenses and changes currency', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);

      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      //click on previously created trip
      final testTrip = find.text('New Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.tap(testTrip);
      await tester.pumpAndSettle();

      //navigate to expenses tab
      final editButton = find.byKey(const Key('expensesTab'));
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.byType(TripExpensesWidget), findsOneWidget);

      // Change currency from dropdown
      final dropdownFinder = find.byType(DropdownButton<String>);
      await tester.ensureVisible(dropdownFinder);
      await tester.pumpAndSettle();
      expect(dropdownFinder, findsOneWidget);

      // Verify the initial currency is EUR.
      DropdownButton<String> dropdown = tester.widget(dropdownFinder);
      expect(dropdown.value, 'EUR');

      // Tap the dropdown to open the menu
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('\$').last);
      await tester.pumpAndSettle(const Duration(seconds: 1));


      dropdown = tester.widget(dropdownFinder);
      expect(dropdown.value, 'USD');
      expect(find.textContaining('\$'), findsWidgets);
      expect(find.textContaining('€'), findsNothing);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User changes trip privacy settings (private -> public)', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);
      //navigate to home page
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();
      //click on previously created trip
      final testTrip = find.text('New Test Trip');
      await tester.ensureVisible(testTrip);
      await tester.tap(testTrip);
      await tester.pumpAndSettle();
      //navigate to update page
      final editButton = find.byKey(const Key('editButton'));
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.text('Pubblica'), findsOneWidget);
      expect(find.text('Rendi privato'), findsNothing);
      //change privacy
      await tester.tap(find.text('Pubblica'));
      await tester.pumpAndSettle();
      expect(find.byType(TripPage), findsOneWidget);
      //click again on edit button
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.text('Pubblica'), findsNothing);
      expect(find.text('Rendi privato'), findsOneWidget);

      await IntegrationTestHelper().performLogout(tester);
    });

    testWidgets('User deletes a trip', (WidgetTester tester) async {
      await IntegrationTestHelper().performLogin(tester);

      // Navigate to home page to ensure we are on the list of trips
      final homeButton = find.byKey(const Key('homeButton'));
      await tester.ensureVisible(homeButton);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      // Find the trip to be deleted.
      final tripToDelete = find.text('New Test Trip');
      expect(tripToDelete, findsOneWidget);
      await tester.ensureVisible(tripToDelete);
      await tester.pumpAndSettle();

      await tester.tap(tripToDelete);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      final tripMenuButton = find.byKey(const Key('editButton'));
      expect(tripMenuButton, findsOneWidget);
      await tester.ensureVisible(tripMenuButton);
      await tester.tap(tripMenuButton);
      await tester.pumpAndSettle();

      // Find and tap the "Delete" option in the menu.
      final deleteOption = find.textContaining('Elimina');
      expect(deleteOption, findsOneWidget);
      await tester.ensureVisible(deleteOption);
      await tester.tap(deleteOption);
      await tester.pumpAndSettle();

      // Confirm deletion in a confirmation dialog
      final confirmDeleteButton = find.byKey(const Key('confirmDialogButton'));
      expect(confirmDeleteButton, findsOneWidget);
      await tester.ensureVisible(confirmDeleteButton);
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));

      // Verify the user is back on the MyTripsPage or home page and the trip is no longer visible.
      expect(find.byType(MyTripsPage), findsOneWidget);
      expect(find.text('New Test Trip'), findsNothing);

      await IntegrationTestHelper().performLogout(tester);
    });

  });
}

Future<void> insertCity(WidgetTester tester, String cityName) async {
  final fieldFinder = find.byKey(const Key('citiesField'));
  await tester.tap(fieldFinder);
  await tester.pumpAndSettle();

  final citySearchBar = find.byType(SearchBar);
  expect(citySearchBar, findsOneWidget);

  await tester.enterText(citySearchBar, cityName);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));

  final tile = find.widgetWithText(ListTile, cityName).first;
  expect(tile, findsOneWidget);
  await tester.tap(tile);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> insertAirport(WidgetTester tester, String airportName, Finder textField) async {

  await tester.tap(textField);
  await tester.pumpAndSettle();

  final searchBar = find.byKey(const Key('airportSearchField'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(searchBar);
  expect(searchBar, findsOneWidget);
  await tester.enterText(searchBar, airportName);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));
  //match tile with airport name (partial match)
  final tile = find.byWidgetPredicate((widget) {
    return widget is ListTile &&
        widget.title is Text &&
        (widget.title as Text).data?.contains(airportName) == true;
  });
  expect(tile, findsOneWidget);
  await tester.tap(tile);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
      Duration timeout = const Duration(seconds: 10),
      Duration interval = const Duration(milliseconds: 100),
    }) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(interval);
    if (finder.evaluate().isNotEmpty) {
      print('Widget found within ${timeout.inSeconds} seconds: $finder');
      await tester.pump(const Duration(milliseconds: 1));
      return; // Widget found ✅
    }
  }

  throw Exception('Widget not found within ${timeout.inSeconds} seconds: $finder');
}