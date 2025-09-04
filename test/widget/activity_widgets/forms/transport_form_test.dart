// test/transportForm_test.dart
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/activity_widgets/forms/TransportForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/intl.dart';
import '../../../mocks.mocks.dart';

void main() {
  group('TransportForm Widget', () {
    late TripModel testTrip;
    late MockDatabaseService mockDatabaseService;
    late TransportModel existingTransport;

    setUp(() {
      mockDatabaseService = MockDatabaseService();

      testTrip = TripModel(
        id: 'trip123',
        title: 'Test Trip',
        nations: [
          {'name': 'Italy', 'code': 'IT'},
          {'name': 'United States', 'code': 'US'}
        ],
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
      );

      existingTransport = TransportModel(
        id: 'transport_1',
        tripId: testTrip.id,
        departurePlace: 'Rome',
        arrivalPlace: 'Paris',
        departureDate: DateTime(2025, 6, 15, 10, 30),
        transportType: 'Treno',
        expenses: 120.50,
        duration: 300, // 5 ore
        type: 'transport',
      );

      // Stub delle chiamate al servizio database
      when(mockDatabaseService.createActivity(any)).thenAnswer((_) async => Future.value());
      when(mockDatabaseService.updateActivity(any, any, any, any)).thenAnswer((_) async => Future.value());
    });

    Future<void> pumpTestableWidget(WidgetTester tester, {TransportModel? transport}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransportForm(
              trip: testTrip,
              transport: transport,
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('dovrebbe renderizzare correttamente tutti i campi del form per un nuovo trasporto', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      expect(find.widgetWithText(TextFormField, 'Luogo di partenza'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Destinazione'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Data'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Ora'), findsOneWidget);
      expect(find.widgetWithText(DropdownButtonFormField<String>, 'Tipo di trasporto'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Costo (opzionale)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Durata (opzionale)'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Aggiungi trasporto'), findsOneWidget);

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('dovrebbe popolare correttamente i campi quando si modifica un trasporto esistente', (WidgetTester tester) async {
      await pumpTestableWidget(tester, transport: existingTransport);

      expect(find.text('Rome'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text(DateFormat('dd/MM/yy').format(existingTransport.departureDate!)), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget); // O '10:30' a seconda delle impostazioni locali
      expect(find.text('Treno'), findsOneWidget);
      expect(find.text('120.5'), findsOneWidget);
      expect(find.text('5h 0m'), findsOneWidget); // Durata pre-popolata
    });

    testWidgets('dovrebbe mostrare errori di validazione quando i campi obbligatori sono vuoti alla sottomissione', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Aggiungi trasporto'));
      await tester.pumpAndSettle();

      expect(find.text('Inserisci un luogo di partenza'), findsOneWidget);
      expect(find.text('Inserisci una destinazione'), findsOneWidget);
      expect(find.text('Seleziona una data'), findsOneWidget);
      expect(find.text('Seleziona un orario'), findsOneWidget);
      expect(find.text('Seleziona un tipo di trasporto'), findsOneWidget);
      expect(find.text('Compila tutti i campi'), findsOneWidget); // SnackBar
    });

    testWidgets('dovrebbe permettere la selezione della data di partenza', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      // Tocca il campo data
      await tester.tap(find.widgetWithText(TextFormField, 'Data'));
      await tester.pumpAndSettle();

      // Verifica che il DatePicker sia mostrato
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('dovrebbe permettere la selezione dell" ora di partenza', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      // Tocca il campo ora
      final departureTimeField = find.widgetWithText(TextFormField, 'Ora');
      await tester.ensureVisible(departureTimeField);
      await tester.pumpAndSettle();
      await tester.tap(departureTimeField);
      await tester.pumpAndSettle();

      // Verifica che il TimePicker sia mostrato
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('dovrebbe mostrare errore di validazione per un costo non valido', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      final costField = find.widgetWithText(TextFormField, 'Costo (opzionale)');
      await tester.enterText(costField, '-10');

      // Compila gli altri campi obbligatori per scatenare la validazione completa
      await tester.enterText(find.widgetWithText(TextFormField, 'Luogo di partenza'), 'A');
      await tester.enterText(find.widgetWithText(TextFormField, 'Destinazione'), 'B');

      await tester.pumpAndSettle();

      // Trova il pulsante che potrebbe essere fuori schermo
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi trasporto');

      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Inserisci un valore valido'), findsOneWidget);
    });

    testWidgets('dovrebbe permettere la selezione della durata', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      // Tocca il campo durata
      await tester.tap(find.widgetWithText(TextFormField, 'Durata (opzionale)'));
      await tester.pumpAndSettle();

      // Verifica che il DurationPickerDialog sia mostrato
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Seleziona durata'), findsNWidgets(2));

      // Seleziona 1 ora e 30 minuti
      await tester.tap(find.text('0 h'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0 m'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Conferma'));
      await tester.pumpAndSettle();

      // Verifica che il campo durata sia aggiornato
      expect(find.text('0h 0m'), findsOneWidget);
    });

    // --- Test: Sottomissione del Form (Creazione di un nuovo trasporto) ---
    /*testWidgets('dovrebbe chiamare createActivity con i dati corretti quando si salva un nuovo trasporto', (WidgetTester tester) async {
      await pumpTestableWidget(tester);

      // Compila tutti i campi obbligatori
      await tester.enterText(find.widgetWithText(TextFormField, 'Departure Place'), 'Start City');
      await tester.enterText(find.widgetWithText(TextFormField, 'Arrival Place'), 'End City');

      // Imposta direttamente data e ora per il test di sottomissione
      /*final formState = tester.state<StatefulElement>(find.byType(TransportForm)).state as dynamic;
      formState.setState(() {
        formState._departureDate = DateTime(2025, 7, 1);
        formState._departureTime = const TimeOfDay(hour: 9, minute: 0);
        formState._selectedType = 'Bus';
      });*/
      await tester.pumpAndSettle(); // Assicura che gli aggiornamenti di stato siano riflessi

      await tester.enterText(find.widgetWithText(TextFormField, 'Costo'), '75.00');
      await tester.tap(find.byKey(const Key('currencyDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR').last);
      await tester.pumpAndSettle();

      // Imposta una durata
      /*formState.setState(() {
        formState._selectedDuration = const Duration(hours: 2, minutes: 15);
      });*/
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Transport'));
      await tester.pumpAndSettle();

      // Verifica che createActivity sia stato chiamato
      verify(mockDatabaseService.createActivity(captureAny)).called(1);

      // Cattura l'argomento passato e verifica le sue proprietà
      final capturedTransport = verify(mockDatabaseService.createActivity(captureAny)).captured.first as TransportModel;
      expect(capturedTransport.tripId, testTrip.id);
      expect(capturedTransport.departurePlace, 'Start City');
      expect(capturedTransport.arrivalPlace, 'End City');
      expect(capturedTransport.departureDate, DateTime(2025, 7, 1, 9, 0));
      expect(capturedTransport.transportType, 'Bus');
      // Verifica la conversione del costo (75.00 USD * 0.9 = 67.50 EUR)
      expect(capturedTransport.expenses, 75.00 * 0.9); // Assicurati che il tasso di cambio mock sia applicato
      expect(capturedTransport.duration, 135); // 2 ore e 15 minuti in minuti
      expect(capturedTransport.type, 'transport');
    });*/

    testWidgets('dovrebbe chiamare updateActivity con i dati corretti quando si aggiorna un trasporto esistente', (WidgetTester tester) async {
      await pumpTestableWidget(tester, transport: existingTransport);

      // Modifica alcuni campi
      await tester.enterText(find.widgetWithText(TextFormField, 'Destinazione'), 'New York');
      await tester.enterText(find.widgetWithText(TextFormField, 'Costo (opzionale)'), '200.00');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Aggiungi trasporto'));
      await tester.pumpAndSettle();

      // Verifica che updateActivity sia stato chiamato
      final captured = verify(mockDatabaseService.updateActivity(
        'transport_1',
        captureAny, // TransportModel
        79.5,
        true,
      )).captured;

      expect(captured.length, 1);

      final model = captured.first as TransportModel;
      expect(model.departurePlace, 'Rome');
      expect(model.arrivalPlace, 'New York'); // Campo modificato nel test
      expect(model.expenses, 200.0);
    });

    testWidgets('should show validation errors for empty required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransportForm(
              trip: testTrip,
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi trasporto');
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Check validation messages for required fields
      expect(find.text('Inserisci un luogo di partenza'), findsOneWidget);
      expect(find.text('Inserisci una destinazione'), findsOneWidget);
      expect(find.text('Seleziona una data'), findsOneWidget);
      expect(find.text('Seleziona un orario'), findsOneWidget);
      expect(find.text('Seleziona un tipo di trasporto'), findsOneWidget);
      expect(find.text('Compila tutti i campi'), findsOneWidget);

      // Ensure createActivity was NOT called
      verifyNever(mockDatabaseService.createActivity(any));
    });

    testWidgets('dovrebbe mostrare i vari tipi di trasporto quando clicchi su tipo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransportForm(
              trip: testTrip,
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );

      final transportTypeDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Tipo di trasporto');
      expect(transportTypeDropdown, findsOneWidget);

      await tester.tap(transportTypeDropdown);
      await tester.pumpAndSettle(); // aspetta che il dropdown si apra


      // Verifica che tutti i tipi siano presenti come testo
      expect(find.text('Bus'), findsWidgets);
      expect(find.text('Treno'), findsWidgets);
      expect(find.text('Auto'), findsWidgets);
      expect(find.text('Traghetto'), findsWidgets);

      // Verifica che tutte le icone siano visibili nel menu
      expect(find.byIcon(Icons.directions_bus), findsWidgets);
      expect(find.byIcon(Icons.train), findsWidgets);
      expect(find.byIcon(Icons.directions_car), findsWidgets);
      expect(find.byIcon(Icons.directions_boat), findsWidgets);
    });

  });
}