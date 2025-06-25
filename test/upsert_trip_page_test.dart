import 'package:country_picker/country_picker.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:dima_project/services/googlePlacesService.dart';
import 'package:dima_project/services/unsplashService.dart';
import 'package:dima_project/widgets/countryPickerWidget.dart';
import 'package:dima_project/widgets/placesSearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';
import 'mocks.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockAuthService mockAuthService;
  late GooglePlacesService mockGooglePlacesService;
  late UnsplashService mockUnsplashService;
  late MockNavigatorObserver mockNavigatorObserver;
  late UserModel currentUser;
  late MockUser mockCurrentUser;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockGooglePlacesService = MockGooglePlacesService();
    mockAuthService = MockAuthService();
    mockCurrentUser = MockUser();
    currentUser = UserModel(
      id: '123',
      username: 'John Doe',
    );
    mockUnsplashService = MockUnsplashService();

    //stub methods
    when(mockDatabaseService.getUserByUid(any)).thenAnswer((_) async {
      return currentUser;
    });
    when(mockCurrentUser.uid).thenReturn('123');
    when(mockAuthService.currentUser).thenReturn(mockCurrentUser);
    when(mockGooglePlacesService.getCoordinates(any)).thenAnswer((_) async {
      return {'lat': 123, 'lng': 456};
    });
    when(mockUnsplashService.getPhotoUrl(any)).thenAnswer((_) async {
      return 'testing_ref';
    });
  });

  Future<void> pumpTestableWidget(
      WidgetTester tester, TripModel? trip, bool? isUpdate) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UpsertTripPage(
          trip: trip,
          isUpdate: isUpdate,
          databaseService: mockDatabaseService,
          authService: mockAuthService,
          googlePlacesService: mockGooglePlacesService,
          unsplashService: mockUnsplashService,
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  Future<void> fillInsertForm(WidgetTester tester) async {
    final countries = [
      Country.parse('Italy'),
      Country.parse('France'),
    ];

    final cities = [
      {
        'name': 'Roma',
        'other_info': '',
        'place_id': '123',
      },
      {
        'name': 'Paris',
        'other_info': '',
        'place_id': '456',
      }
    ];

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Titolo'), 'Test trip');
    final state = tester.state(find.byType(UpsertTripPage)) as dynamic;
    state.simulateCountrySelection(countries);
    state.simulateCitySelection(cities);
    state.simulateDateSelection(DateTime(2025, 6, 10), DateTime(2025, 6, 15));
    await tester.pumpAndSettle();
  }

  Future<void> fillUpdateForm(WidgetTester tester) async {
    final cities = [
      {
        'name': 'Milan',
        'other_info': '',
        'place_id': '789',
      },
      {
        'name': 'Marseille',
        'other_info': '',
        'place_id': '012',
      }
    ];

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Titolo'), 'Updated trip');
    final state = tester.state(find.byType(UpsertTripPage)) as dynamic;
    state.simulateCitySelection(cities);
    await tester.pumpAndSettle();
  }

  group('Insert mode tests', () {
    testWidgets('correctly renders all form fields',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, null, false);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Titolo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Che nazioni visiterai?'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Che città visiterai?'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Quando partirai?'),
          findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Crea il viaggio'),
          findsOneWidget);
    });

    testWidgets('Shows validation errors when fields are empty',
        (tester) async {
      await pumpTestableWidget(tester, null, false);
      await tester.pumpAndSettle();

      final submitButton = find.text('Crea il viaggio');

      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Per favore inserisci un titolo'), findsOneWidget);
      expect(
          find.text('Per favore seleziona almeno una nazione'), findsOneWidget);
      //expect(find.text('Per favore inserisci almeno una città'), findsOneWidget);
      expect(find.text('Per favore seleziona delle date'), findsOneWidget);
    });

    testWidgets('shows circular indicator while loading', (tester) async {
      // Stub createTrip
      when(mockDatabaseService.createTrip(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
      });

      await pumpTestableWidget(tester, null, false);
      await tester.pumpAndSettle();

      await fillInsertForm(tester);

      final submitButton = find.text('Crea il viaggio');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Finish up async operations
      await tester.pumpAndSettle();
    });

    testWidgets('Submits form data', (tester) async {
      when(mockDatabaseService.createTrip(any)).thenAnswer((_) async {});

      await pumpTestableWidget(tester, null, false);
      await tester.pumpAndSettle();

      //fill form fields
      await fillInsertForm(tester);

      //tap submit button
      final submitButton = find.text('Crea il viaggio');

      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      //verify that the trip passed to the database service is correct
      final TripModel capturedTrip = verify(
        mockDatabaseService.createTrip(captureAny),
      ).captured.first as TripModel;

      expect(capturedTrip.title, equals('Test trip'));
      expect(capturedTrip.nations!.length, equals(2));
      expect(capturedTrip.nations!.first['name'], equals('Italy'));
      expect(capturedTrip.imageRef, equals('testing_ref'));
      expect(capturedTrip.startDate, isNotNull);
      expect(capturedTrip.endDate, isNotNull);
    });

    testWidgets('Display selected countries as chips', (tester) async {
      await pumpTestableWidget(tester, null, false);
      await tester.pumpAndSettle();

      final countries = [
        Country.parse('Italy'),
        Country.parse('France'),
      ];
      final state = tester.state(find.byType(UpsertTripPage)) as dynamic;
      await state.simulateCountrySelection(countries);
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.textContaining('Italy'), findsOneWidget);
      expect(find.textContaining('France'), findsOneWidget);
    });

    testWidgets('Selecting date field open DateRangePickerDialog',
        (tester) async {
      await pumpTestableWidget(tester, null, false);

      // Tap to trigger _selectDateRange
      await tester.tap(find.widgetWithText(TextFormField, 'Quando partirai?'));
      await tester.pumpAndSettle();

      expect(find.byType(DateRangePickerDialog), findsOneWidget);
    });
  });

  group('Update mode tests', () {
    final trip = TripModel(
      id: '123',
      title: 'Test trip',
      nations: [
        {'name': 'Italy', 'flag': '🇮🇹', 'code': 'iT'},
        {'name': 'France', 'flag': '🇫🇷', 'code': 'fR'},
      ],
      cities: [
        {'name': 'Roma', 'place_id': '123', 'lat': 123, 'lng': 456},
        {'name': 'Paris', 'place_id': '456', 'lat': 123, 'lng': 456},
      ],
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      imageRef: 'testing_ref',
    );
    testWidgets('correctly initialize all data', (WidgetTester tester) async {
      await pumpTestableWidget(tester, trip, true);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Test trip'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'Aggiungi tappe'), findsOneWidget);
      final startDate = DateFormat('dd/MM/yy').format(DateTime.now());
      final endDate = DateFormat('dd/MM/yy')
          .format(DateTime.now().add(const Duration(days: 7)));
      expect(find.widgetWithText(TextFormField, startDate), findsOneWidget);
      expect(find.widgetWithText(TextFormField, endDate), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Shows validation errors when title field is empty',
        (tester) async {
      await pumpTestableWidget(tester, TripModel(title: 'Test trip'), true);
      await tester.pumpAndSettle();

      final titleField = find.widgetWithText(TextFormField, 'Test trip');
      await tester.enterText(titleField, '');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Per favore inserisci un titolo'), findsOneWidget);
    });

    testWidgets('Submits update form data', (tester) async {
      when(mockDatabaseService.updateTrip(any)).thenAnswer((_) async {});

      await pumpTestableWidget(tester, trip, true);
      await tester.pumpAndSettle();

      //fill form fields
      await fillUpdateForm(tester);

      //tap submit button
      final submitButton = find.text('Salva modifiche');

      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      //verify that the trip passed to the database service is correct
      final TripModel capturedTrip = verify(
        mockDatabaseService.updateTrip(captureAny),
      ).captured.first as TripModel;

      expect(capturedTrip.title, equals('Updated trip'));
      expect(capturedTrip.cities!.length, equals(4));
      expect(
        capturedTrip.cities!.any((city) => city['name'] == 'Milan'),
        isTrue,
      );
      expect(
        capturedTrip.cities!.any((city) => city['name'] == 'Marseille'),
        isTrue,
      );
    });

    testWidgets('Display selected cities as chips', (tester) async {
      await pumpTestableWidget(tester, trip, true);
      await tester.pumpAndSettle();

      final cities = [
        {
          'name': 'Milan',
          'other_info': '',
          'place_id': '789',
        },
        {
          'name': 'Marseille',
          'other_info': '',
          'place_id': '012',
        }
      ];

      final state = tester.state(find.byType(UpsertTripPage)) as dynamic;
      await state.simulateCitySelection(cities);
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.textContaining('Milan'), findsOneWidget);
      expect(find.textContaining('Marseille'), findsOneWidget);
    });

    testWidgets('cannot add a city twice', (tester) async {
      await pumpTestableWidget(tester, trip, true);
      await tester.pumpAndSettle();

      final cityAlreadySelected = {
        'name': 'Roma',
        'other_info': '',
        'place_id': '123'
      };

      final state = tester.state(find.byType(UpsertTripPage)) as dynamic;
      await state.simulateCitySelection([cityAlreadySelected]);
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsNothing);
      //expect snackbar
      expect(
          find.widgetWithText(
              SnackBar, 'Questa tappa è già nel tuo itinerario'),
          findsOneWidget);
    });

    testWidgets('Selecting date field open DatePickerDialog', (tester) async {
      await pumpTestableWidget(tester, trip, true);

      // Tap to trigger _selectDateRange
      await tester.tap(find.widgetWithText(TextFormField, 'Quando partirai?'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('General mode tests', () {
    testWidgets('Tapping country field opens CountryPickerWidget',
        (tester) async {
      await pumpTestableWidget(tester, null, false);

      await tester
          .tap(find.widgetWithText(TextFormField, 'Che nazioni visiterai?'));
      await tester.pumpAndSettle();

      expect(find.byType(CountryPickerWidget), findsOneWidget);
    });

    testWidgets('Tapping city field opens PlacesSearchWidget', (tester) async {
      await pumpTestableWidget(tester, null, false);

      //first insert a country to unlock cities button
      final state = tester.state(find.byType(UpsertTripPage)) as dynamic;
      await state.simulateCountrySelection([Country.parse('Italy')]);
      await tester.pumpAndSettle();

      await tester
          .tap(find.widgetWithText(TextFormField, 'Che città visiterai?'));
      await tester.pumpAndSettle();

      expect(find.byType(PlacesSearchWidget), findsOneWidget);
    });
  });
}
