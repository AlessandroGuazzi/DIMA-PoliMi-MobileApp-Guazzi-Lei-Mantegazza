import 'package:country_picker/country_picker.dart';
import 'package:dima_project/widgets/countryPickerWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late CountryService mockCountryService;
  late List<Country> countriesList;

  setUp(() {
    mockCountryService = MockCountryService();
    countriesList = [
      Country.parse('Italy'),
      Country.parse('France'),
      Country.parse('Germany'),
      Country.parse('Spain'),
    ];
    when(mockCountryService.getAll()).thenReturn(countriesList);
  });

  Future<void> pumpTestableWidget(
      WidgetTester tester,
      List<Country> selectedCountries,
      Function(List<Country>) onCountriesSelected,
      bool isUserNationality) async {
    await tester.pumpWidget(
      MaterialApp(
          home: Scaffold(
        body: CountryPickerWidget(
          selectedCountries: selectedCountries,
          onCountriesSelected: onCountriesSelected,
          isUserNationality: isUserNationality,
          countryService: mockCountryService,
        ),
      )),
    );
  }

  group('Set up and filtering Tests', () {
    testWidgets('ui renders correctly with initial list',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, [], (_) {}, false);
      await tester.pumpAndSettle();

      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.byIcon(Icons.flag_circle_sharp), findsOneWidget);
      expect(find.text('Conferma'), findsOneWidget);

      // Check that our mock list is rendered
      expect(find.textContaining('Italy'), findsOneWidget);
      expect(find.textContaining('France'), findsOneWidget);
      expect(find.textContaining('Germany'), findsOneWidget);
      expect(find.textContaining('Spain'), findsOneWidget);
    });

    testWidgets('filtering the list by a search query',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, [], (_) {}, false);
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(countriesList.length));

      await tester.enterText(find.byType(SearchBar), 'Fra');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget); // Only one result
      expect(find.textContaining('France'), findsOneWidget);
      expect(find.textContaining('Italy'), findsNothing);
      expect(find.textContaining('Germany'), findsNothing);

      //clearing restore the full list
      await tester.enterText(find.byType(SearchBar), '');
      await tester.pumpAndSettle();
      // The list should be restored to its original state
      expect(find.byType(ListTile), findsNWidgets(countriesList.length));
      expect(find.textContaining('Italy'), findsOneWidget);
      expect(find.textContaining('France'), findsOneWidget);
      expect(find.textContaining('Germany'), findsOneWidget);
    });
  });
  group('countries selection tests (isUserNationality = false)', () {
    testWidgets('selecting a country adds it to the list',
        (WidgetTester tester) async {});
    testWidgets('unselecting a country removes it from the list',
        (WidgetTester tester) async {});
    testWidgets(
        'maximum 5 countries can be selected', (WidgetTester tester) async {});
    testWidgets('tapping \'Conferma\' executes callback',
        (WidgetTester tester) async {});
  });

  group('user nationality selection tests (isUserNationality = true)', () {
    testWidgets('confirm button is hide', (WidgetTester tester) async {});
    testWidgets('tapping a country executes callback and pops the screen.',
        (WidgetTester tester) async {});
  });
}
