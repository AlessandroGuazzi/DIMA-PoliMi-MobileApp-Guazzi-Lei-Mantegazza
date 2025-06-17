import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/widgets/activity_widgets/accommodationForm.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';

void main() {
  group('AccommodationForm Widget', () {
    late TripModel testTrip;
    late MockDatabaseService mockDatabaseService;
    late AccommodationModel accommodation;

    setUp(() async {
      mockDatabaseService = MockDatabaseService();
      testTrip = TripModel(
        id: 'trip123',
        title: 'Test Trip',
        nations: [
          {'name': 'Italy', 'code': 'IT'}
        ],
        startDate: DateTime(2025, 12, 1),
        endDate: DateTime(2025, 12, 10),
      );
      accommodation = AccommodationModel(
        id: 'acc_1',
        tripId: testTrip.id,
        name: 'Hotel Test',
        address: 'Via Roma 1, Milano',
        checkIn: DateTime(2025, 12, 2, 14, 0),
        checkOut: DateTime(2025, 12, 5, 11, 0),
        expenses: 120.0,
        type: 'accommodation',
      );

      when(mockDatabaseService.createActivity(any)).thenAnswer((_) async => Future.value());
    });

    Future<void> pumpTestableWidget(WidgetTester tester, {AccommodationModel? accommodation}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccommodationForm(
              trip: testTrip,
              accommodation: accommodation,
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );
    }

    testWidgets('should render all form fields', (WidgetTester tester) async {
      await pumpTestableWidget(tester, accommodation: accommodation);
      await tester.pumpAndSettle();

      //expect(find.widgetWithText(TextFormField, 'Edit accommodation'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Dove dormirai?'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Indirizzo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Costo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Check-in'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Check-out'), findsOneWidget);

      expect(find.byIcon(Icons.access_time), findsNWidgets(2));
      expect(find.byIcon(Icons.date_range), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Aggiungi alloggio'), findsOneWidget);
    });

    testWidgets('should show validation errors if required fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccommodationForm(trip: testTrip, databaseService: mockDatabaseService),
          ),
        ),
      );

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi alloggio');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Per favore inserisci un\'alloggio'), findsOneWidget);
      expect(find.text('Per favore seleziona data di arrivo e fine'), findsOneWidget);
    });

    testWidgets('should populate fields when editing existing accommodation', (WidgetTester tester) async {
      await pumpTestableWidget(tester, accommodation: accommodation);
      await tester.pumpAndSettle();

      expect(find.text('Hotel Test'), findsOneWidget);
      expect(find.text('Via Roma 1, Milano'), findsOneWidget);
      expect(find.text('120.00'), findsOneWidget);
      //expect(find.text('Camera con vista'), findsOneWidget);
    });

    testWidgets('should validate cost field with negative values', (WidgetTester tester) async {
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      final costField = find.widgetWithText(TextFormField, 'Costo');
      await tester.enterText(costField, '-50');

      //final locationField = find.widgetWithText(TextFormField, 'Dove dormirai?');
      //await tester.tap(locationField);
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi alloggio');
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('-50'), findsOneWidget);
      expect(find.text('Per favore inserisci un costo valido'), findsOneWidget);
      expect(find.text('Per favore compila tutti i campi correttamente!'), findsOneWidget);
    });

    testWidgets('should update accommodation when form is submitted', (WidgetTester tester) async {
      await pumpTestableWidget(tester, accommodation: accommodation);
      await tester.pumpAndSettle();

      when(mockDatabaseService.updateActivity(any, any, any, any)).thenAnswer((_) async => Future.value());

      await tester.enterText(find.widgetWithText(TextFormField, 'Costo'), '150');

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi alloggio');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      verify(mockDatabaseService.updateActivity(any, any, any, any)).called(1);
    });
  });
}
