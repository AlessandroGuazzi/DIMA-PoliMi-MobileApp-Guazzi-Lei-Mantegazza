import 'package:country_picker/country_picker.dart';
import 'package:dima_project/widgets/search_bottom_sheets/countryPickerWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.mocks.dart';

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
      Country.parse('United Kingdom'),
      Country.parse('United States'),
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
        (WidgetTester tester) async {
      List<Country> selected = [];

      await pumpTestableWidget(tester, selected, (_) {}, false);
      await tester.pumpAndSettle();

      final italyTile = find.textContaining('Italy');
      await tester.tap(italyTile);
      await tester.pumpAndSettle();

      expect(selected.any((c) => c.name == 'Italy'), isTrue);
    });
    testWidgets('unselecting a country removes it from the list',
        (WidgetTester tester) async {
      List<Country> selected = [Country.parse('Germany')];

      await pumpTestableWidget(tester, selected, (_) {}, false);
      await tester.pumpAndSettle();

      final germanyTile = find.textContaining('Germany');
      await tester.tap(germanyTile);
      await tester.pumpAndSettle();

      expect(selected.any((c) => c.name == 'Germany'), isFalse);
    });
    testWidgets('maximum 5 countries can be selected',
        (WidgetTester tester) async {
      List<Country> selected = [
        Country.parse('Italy'),
        Country.parse('France'),
        Country.parse('Germany'),
        Country.parse('Spain'),
        Country.parse('United Kingdom'),
      ];

      await pumpTestableWidget(tester, selected, (_) {}, false);
      await tester.pumpAndSettle();

      //attempt to click a 6th country
      final usTile = find.textContaining('United States');
      await tester.ensureVisible(usTile);
      await tester.pump();
      await tester.tap(usTile);
      await tester.pumpAndSettle();

      expect(selected.length, equals(5));
      expect(selected.any((c) => c.name == 'United States'), isFalse);
    });

    testWidgets('tapping \'Conferma\' executes callback',
        (WidgetTester tester) async {
      List<Country> selected = [];

      await pumpTestableWidget(tester, [], (newSelection) {
        selected = newSelection;
      }, false);
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('France'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(selected.length, equals(1));
      expect(selected.first.name, equals('France'));
    });
  });

  group('user nationality selection tests (isUserNationality = true)', () {
    testWidgets('confirm button is hidden', (WidgetTester tester) async {
      await pumpTestableWidget(tester, [], (_) {}, true);
      await tester.pumpAndSettle();

      expect(find.text('Conferma'), findsNothing);
    });
    testWidgets('tapping a country executes callback and pops the screen.',
        (WidgetTester tester) async {
      Country? selectedCountry;

      await pumpTestableWidget(tester, [], (selection) {
        selectedCountry = selection.first;
      }, true);
      await tester.pumpAndSettle();

      final franceTile = find.textContaining('France');
      await tester.tap(franceTile);
      await tester.pumpAndSettle();

      expect(selectedCountry?.name, equals('France'));
      expect(find.byType(CountryPickerWidget), findsNothing); // Widget popped
    });
  });
}
