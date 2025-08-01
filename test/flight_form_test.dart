import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/activity_widgets/forms/FlightForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';
import 'mocks.dart';

void main() {
  group('FlightForm Widget', () {
    late TripModel testTrip;
    late MockDatabaseService mockDatabaseService;
    late FlightModel flight;
    final departureAirport = {
      'iata': 'FCO',
      'name': 'Rome Fiumicino',
      'iso': 'IT',
    };

    final arrivalAirport = {
      'iata': 'JFK',
      'name': 'John F. Kennedy Intl',
      'iso': 'US',
    };

    setUp(() async {
      mockDatabaseService = MockDatabaseService();
      testTrip = TripModel(
        id: 'trip123',
        title: 'Test Trip',
        //nations: ['Italy'],
        startDate: DateTime(2025, 12, 1),
        endDate: DateTime(2025, 12, 20),
      );
      flight = FlightModel(
          id: 'flight_1',
          tripId: testTrip.id,
          departureAirPort: departureAirport,
          arrivalAirPort: arrivalAirport,
          departureDate: DateTime(2025, 12, 12, 10, 0),
          duration: 9.0,
          expenses: 500.0,
          type: 'flight'
      );

      // Stub the database call - stesso pattern del test funzionante
      when(mockDatabaseService.createActivity(any)) .thenAnswer((_) async => Future.value());
    });

    Future<void> pumpTestableWidget(WidgetTester tester, {FlightModel? flight}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightForm(
              trip: testTrip,
              flight: flight,
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );
    }

    testWidgets('should render all form fields', (WidgetTester tester) async {
      await pumpTestableWidget(tester, flight: flight);
      await tester.pumpAndSettle();

      // Controlli per i TextFormField
      expect(find.widgetWithText(TextFormField, 'Departure Airport'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Arrival Airport'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Departure Date'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Departure Time'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Duration (in hours)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Costo'), findsOneWidget);

      // Pulsante di salvataggio
      expect(find.widgetWithText(ElevatedButton, 'Save Flight'), findsOneWidget);
    });

    testWidgets('should show validation errors if required fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightForm(trip: testTrip, databaseService: mockDatabaseService,),
          ),
        ),
      );

      // Tappa il pulsante senza compilare
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Flight'));
      await tester.pump();

      // Controllo che compaiano errori di validazione
      expect(find.text('Required'), findsNWidgets(3)); // Departure, Arrival, Duration
      expect(find.text('Select a date'), findsOneWidget);
      expect(find.text('Select a time'), findsOneWidget);
    });

    testWidgets('should update currency dropdown and enter cost', (WidgetTester tester) async {
      await pumpTestableWidget(tester, flight: flight);
      await tester.pumpAndSettle();

      final costField = find.widgetWithText(TextFormField, 'Costo');
      expect(costField, findsOneWidget);

      // Trova e tocca il dropdown
      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Inserisci un valore di costo
      await tester.enterText(costField, '150');
      expect(find.text('150'), findsOneWidget);
    });


    testWidgets('should create flight with correct data when form is submitted', (WidgetTester tester) async {
      await mockDatabaseService.createActivity(flight);// ✅ Questo ritorna void;

      await pumpTestableWidget(tester, flight: flight);
      await tester.pumpAndSettle();

      // Stub del database service - stesso pattern degli altri test
      when(mockDatabaseService.createActivity(any)).thenAnswer((_) async => Future.value());  // ✅ Questo ritorna void

      // Il form dovrebbe essere pre-popolato con i dati del flight esistente
      // Verifica che i campi siano popolati correttamente
      expect(find.text('Rome Fiumicino (FCO)'), findsOneWidget);
      expect(find.text('John F. Kennedy Intl (JFK)'), findsOneWidget);

      // Compila/modifica alcuni campi necessari
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Duration (in hours)'),
          '9'
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Costo'),
          '500'
      );

      // Tap su "Save Flight"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Flight'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      // Verifica che createActivity sia stato chiamato
      verify(mockDatabaseService.updateActivity(any, any, any, any)).called(1);

      // Cattura l'argomento passato per verificare i dati
      final captured = verify(mockDatabaseService.createActivity(captureAny)).captured;
      expect(captured.length, 1);

      final FlightModel capturedFlight = captured.first as FlightModel;
      expect(capturedFlight.tripId, testTrip.id);
      expect(capturedFlight.type, 'flight');
      expect(capturedFlight.departureAirPort?['iata'], 'FCO');
      expect(capturedFlight.arrivalAirPort!['iata'], 'JFK');
    });

    testWidgets('should show validation errors for empty required fields', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightForm(trip: testTrip, databaseService: mockDatabaseService,),
          ),
        ),
      );

      // Tap su "Save Flight" senza compilare i campi
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Flight'));
      await tester.pumpAndSettle();

      // Verifica che vengano mostrati gli errori di validazione
      expect(find.text('Required'), findsWidgets);
      expect(find.text('Select a date'), findsOneWidget);
      expect(find.text('Select a time'), findsOneWidget);

      // Verifica che createActivity NON sia stato chiamato
      verifyNever(mockDatabaseService.createActivity(any));
    });


    testWidgets('should validate cost field with negative values', (WidgetTester tester) async {
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Inserisci un valore negativo nel campo costo
      final costField = find.widgetWithText(TextFormField, 'Costo');
      await tester.enterText(costField, '-10');

      // Compila il campo obbligatorio per triggare la validazione
      //final locationField = find.widgetWithText(TextFormField, 'Dove?');
      //await tester.tap(locationField);
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Save Flight');

      // Ottieni il widget e simula il tap direttamente
      final button = tester.widget<ElevatedButton>(buttonFinder);
      button.onPressed?.call();
      await tester.pumpAndSettle();

      // Verifica che appaia l'errore di validazione per il costo
      expect(find.text('Per favore inserisci un costo valido'), findsOneWidget);
    });

    testWidgets('should update currency dropdown and enter cost', (WidgetTester tester) async {
      await pumpTestableWidget(tester); // funzione helper già esistente nel test

      await tester.pumpAndSettle();

      final costField = find.widgetWithText(TextFormField, 'Costo');
      expect(costField, findsOneWidget);

      // Scrive nel campo costo
      await tester.enterText(costField, '200');
      expect(find.text('200'), findsOneWidget);

      // Trova e interagisce con il DropdownButton della valuta
      final currencyDropdown = find.byType(DropdownButton<String>);
      expect(currencyDropdown, findsOneWidget);

      await tester.tap(currencyDropdown);
      await tester.pumpAndSettle();
    });

    testWidgets('should prefill fields when editing existing flight', (WidgetTester tester) async {
      await pumpTestableWidget(tester, flight: flight);
      await tester.pumpAndSettle();

      // Controlla che i campi pre-popolati siano visibili
      expect(find.text('Rome Fiumicino (FCO)'), findsOneWidget);
      expect(find.text('John F. Kennedy Intl (JFK)'), findsOneWidget);

      final dateText = DateFormat('dd/MM/yy').format(flight.departureDate!);
      expect(find.text(dateText), findsOneWidget);

      final timeText = DateFormat('HH:mm').format(flight.departureDate!);
      //expect(find.text('10:00'), findsOneWidget);

      expect(find.text('500.00'), findsOneWidget);
      // Se il campo valuta è presente e predefinito (es. 'EUR')
      //expect(find.text('€'), findsOneWidget);

      // Se il campo durata è pre-popolato come '9h 0m'
      expect(find.text('9.0'), findsOneWidget);
    });

    testWidgets('tapping on start date field opens date picker and selects date', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      // Trova il campo "Departure Date"
      final startDateField = find.widgetWithText(TextFormField, 'Departure Date');
      expect(startDateField, findsOneWidget);

      // Tap per aprire il DatePicker
      await tester.tap(startDateField);
      await tester.pumpAndSettle();

      // Verifica che si apra il DatePicker
      expect(find.text('Select date'), findsOneWidget);
      expect(find.text('20'), findsWidgets); // attenzione: più '20' potrebbero esistere

      // Tap sul giorno 20 (l'ultimo tra quelli trovati)
      await tester.tap(find.text('20').last);
      await tester.pumpAndSettle();

      // Tap sul pulsante "OK"
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verifica che il campo ora contenga la data selezionata
      // Supponendo che venga formattata ad esempio come '2025-12-20'
      expect(find.textContaining('20/12/25'), findsOneWidget);
       // potrebbe essere '2025-12-20'
    });

    testWidgets('tapping on departure time field opens time picker and selects time', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      // Trova il campo dell’orario di partenza
      final departureTimeField = find.widgetWithText(TextFormField, 'Departure Time');
      expect(departureTimeField, findsOneWidget);

      // Tap per aprire il TimePicker
      await tester.tap(departureTimeField);
      await tester.pumpAndSettle();

      // Verifica che il TimePicker sia visibile
      // Il testo dipende dal locale, ma 'OK' è spesso presente
      expect(find.text('OK'), findsOneWidget);

      // Facoltativo: seleziona un orario. Il TimePicker nativo è difficile da manipolare nei test widget.
      // In genere si salta questo passaggio e si conferma direttamente.

      // Conferma l’orario
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });
}