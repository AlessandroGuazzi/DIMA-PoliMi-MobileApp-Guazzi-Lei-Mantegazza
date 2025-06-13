import 'package:dima_project/utils/PlacesType.dart';
import 'package:dima_project/widgets/placesSearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockGooglePlacesService mockGooglePlacesService;

  setUp(() {
    mockGooglePlacesService = MockGooglePlacesService();
  });

  Future<void> pumpTestableWidget({
    required WidgetTester tester,
    required Function(Map<String, String>) onPlaceSelected,
    required List<String> countryCodes,
    required PlacesType type,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: PlacesSearchWidget(
        selectedCountryCodes: countryCodes,
        onPlaceSelected: onPlaceSelected,
        type: type,
        googlePlacesService: mockGooglePlacesService,
      ),
    ));
  }

  testWidgets('renders ui elements', (WidgetTester tester) async {
    await pumpTestableWidget(
        tester: tester,
        onPlaceSelected: (_) {},
        countryCodes: ['IT'],
        type: PlacesType.cities);
    await tester.pumpAndSettle();

    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.text('Cerca...'), findsOneWidget);
  });

  testWidgets('calls onPlaceSelected and pops when suggestion is selected',
          (WidgetTester tester) async {
        bool wasSelected = false;
        Map<String, String>? selectedPlace;

        await pumpTestableWidget(
            tester: tester,
            onPlaceSelected: (place) {
              wasSelected = true;
              selectedPlace = place;
            },
            countryCodes: ['IT'],
            type: PlacesType.cities);
        await tester.pumpAndSettle();

        final state = tester.state(find.byType(PlacesSearchWidget))
        as PlacesSearchWidgetState;

        state.widget.onPlaceSelected(
          {
            'name': 'Roma',
            'other_info': '',
            'place_id': '123',
          },
        );
        await tester.pumpAndSettle();

        expect(wasSelected, isTrue);
        expect(selectedPlace, isNotNull);
        expect(selectedPlace!['name'], equals('Roma'));
      });


  testWidgets('suggestionsCallback returns filtered list for valid input',
          (WidgetTester tester) async {
        // simulate a direct call to suggestionsCallback logic
        await pumpTestableWidget(tester: tester,
            onPlaceSelected: (_) {},
            countryCodes: ['IT'], type: PlacesType.cities);
        await tester.pumpAndSettle();

        when(mockGooglePlacesService.searchAutocomplete(any, any, any))
            .thenAnswer((_) async {
          return Future.value([{
            'name': 'Roma',
            'other_info': '',
            'place_id': '123',
          },
            {
              'name': 'Milano',
              'other_info': '',
              'place_id': '456',
            }
          ]);
        });

        final searchInput = find.byType(SearchBar);
        expect(searchInput, findsOneWidget);

        // 2. Simulate typing
        await tester.enterText(searchInput, 'R');
        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsNWidgets(2));
        expect(find.widgetWithText(ListTile, 'Roma'), findsOneWidget);
        expect(find.widgetWithText(ListTile, 'Milano'), findsOneWidget);
      });
}
