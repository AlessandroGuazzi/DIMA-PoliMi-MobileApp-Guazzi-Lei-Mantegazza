import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/widgets/activity_widgets/attractionForm.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/utils/PlacesType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'mocks.mocks.dart';
import 'mocks.dart';

void main() {
  group('AttractionForm Widget', () {
    late TripModel testTrip;
    late MockDatabaseService mockDatabaseService;
    late AttractionModel attraction;

    setUp(() async {
      mockDatabaseService = MockDatabaseService();
      testTrip = TripModel(
        id: 'trip123',
        title: 'Test Trip',
        nations: [
          {'name': 'Italy', 'code': 'IT'},
          {'name': 'France', 'code': 'FR'}
        ],
        startDate: DateTime(2025, 12, 1),
        endDate: DateTime(2025, 12, 20),
      );
      attraction = AttractionModel(
          id: 'attraction_1',
          tripId: testTrip.id,
          name: 'Colosseum',
          attractionType: 'tourist_attraction',
          address: 'Piazza del Colosseo, 1, Rome',
          startDate: DateTime(2025, 12, 12, 10, 0),
          endDate: DateTime(2025, 12, 12, 14, 0),
          expenses: 25.0,
          description: 'Ancient Roman amphitheater',
          type: 'attraction'
      );

      // Stub the database call - stesso pattern del test funzionante
      when(mockDatabaseService.createActivity(any)).thenAnswer((_) async => Future.value());
    });

    Future<void> pumpTestableWidget(WidgetTester tester, {AttractionModel? attraction}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionForm(
              trip: testTrip,
              attraction: attraction,
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );
    }


    testWidgets('should render all form fields', (WidgetTester tester) async {
      await pumpTestableWidget(tester, attraction: attraction);
      await tester.pumpAndSettle();

      // Controlli per i campi del form
      expect(find.widgetWithText(DropdownButtonFormField2<PlacesType>, 'Seleziona il tipo di attività'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Dove?'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Indirizzo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Quando?'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Costo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Inizio'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Fine'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Descrizione (opzionale)'), findsOneWidget);

      // Controlli per i time picker
      expect(find.byIcon(Icons.access_time), findsNWidgets(2)); // Start e End time
      expect(find.byIcon(Icons.date_range), findsOneWidget); // Date range picker

      // Pulsante di salvataggio
      expect(find.widgetWithText(ElevatedButton, 'Aggiungi attività'), findsOneWidget);
    });


    testWidgets('should show validation errors if required fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionForm(trip: testTrip, databaseService: mockDatabaseService),
          ),
        ),
      );

      // Trova il pulsante che potrebbe essere fuori schermo
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi attività');

      // 1. Scorri fino a rendere visibile il pulsante
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle(); // Attendi che l'animazione di scroll termini

      // 2. Ora che è visibile, tappa il pulsante
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle(); // Attendi l'aggiornamento dello stato (es. la comparsa dei messaggi di errore)

      // 3. Controlla che compaiano gli errori di validazione
      expect(find.text('Inserisci un luogo'), findsOneWidget);
      expect(find.text('Per favore seleziona delle date'), findsOneWidget);
    });


    testWidgets('should populate fields correctly when editing existing attraction', (WidgetTester tester) async {
      await pumpTestableWidget(tester, attraction: attraction);
      await tester.pumpAndSettle();

      // Verifica che i campi siano popolati correttamente
      expect(find.text('Colosseum'), findsOneWidget);
      expect(find.text('Piazza del Colosseo, 1, Rome'), findsOneWidget);
      expect(find.text('25.0'), findsOneWidget);
      expect(find.text('Ancient Roman amphitheater'), findsOneWidget);
    });


    testWidgets('should update activity type dropdown', (WidgetTester tester) async {
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Trova e tocca il dropdown del tipo di attività
      final dropdown = find.byType(DropdownButtonFormField2<PlacesType>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Verifica che le opzioni siano presenti
      expect(find.text('Museo'), findsOneWidget);
      expect(find.text('Ristorante'), findsOneWidget);
      expect(find.text('Stadio'), findsOneWidget);
      expect(find.text('Parco Naturale'), findsOneWidget);
      expect(find.text('Zoo'), findsOneWidget);
      expect(find.text('Chiesa'), findsOneWidget);
      expect(find.text('Cinema'), findsOneWidget);
      expect(find.text('Attrazione turistica'), findsNWidgets(2));

      expect(find.byIcon(Icons.museum), findsOneWidget);        // museo
      expect(find.byIcon(Icons.restaurant), findsOneWidget);    // ristorante
      expect(find.byIcon(Icons.stadium), findsOneWidget);       // stadio
      expect(find.byIcon(Icons.park), findsOneWidget);          // parco naturale
      expect(find.byIcon(Icons.pets), findsOneWidget);          // zoo
      expect(find.byIcon(Icons.church), findsOneWidget);        // chiesa
      expect(find.byIcon(Icons.movie), findsOneWidget);         // cinema


      // Seleziona 'Museo'
      await tester.tap(find.text('Museo'));
      await tester.pumpAndSettle();

      // Verifica che la selezione sia avvenuta
      expect(find.text('Museo'), findsOneWidget);
    });



    testWidgets('should update currency dropdown and enter cost', (WidgetTester tester) async {
      await pumpTestableWidget(tester, attraction: attraction);
      await tester.pumpAndSettle();

      final costField = find.widgetWithText(TextFormField, 'Costo');
      expect(costField, findsOneWidget);

      // Trova e tocca il dropdown della valuta
      final currencyDropdown = find.byType(DropdownButton<String>);
      expect(currencyDropdown, findsOneWidget);

      await tester.tap(currencyDropdown);
      await tester.pumpAndSettle();

      // Inserisci un valore di costo
      await tester.enterText(costField, '50');
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('should validate cost field with negative values', (WidgetTester tester) async {
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Inserisci un valore negativo nel campo costo
      final costField = find.widgetWithText(TextFormField, 'Costo');
      await tester.enterText(costField, '-10');

      // Compila il campo obbligatorio per triggare la validazione
      final locationField = find.widgetWithText(TextFormField, 'Dove?');
      await tester.tap(locationField);
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi attività');

      // Ottieni il widget e simula il tap direttamente
      final button = tester.widget<ElevatedButton>(buttonFinder);
      button.onPressed?.call();
      await tester.pumpAndSettle();

      // Verifica che appaia l'errore di validazione per il costo
      expect(find.text('Per favore inserisci un costo valido'), findsOneWidget);
    });


    testWidgets('should create attraction with correct data when form is submitted', (WidgetTester tester) async {
      await pumpTestableWidget(tester, attraction: attraction);
      await tester.pumpAndSettle();

      // Stub del database service - stesso pattern degli altri test
      when(mockDatabaseService.updateActivity(any, any, any, any)).thenAnswer((_) async => Future.value());

      // Il form dovrebbe essere pre-popolato con i dati dell'attraction esistente
      // Verifica che i campi siano popolati correttamente
      expect(find.text('Colosseum'), findsOneWidget);
      expect(find.text('Piazza del Colosseo, 1, Rome'), findsOneWidget);

      // Modifica alcuni campi
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Costo'),
          '30'
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Descrizione (opzionale)'),
          'Updated description'
      );

      // Trova il pulsante che potrebbe essere fuori schermo
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi attività');

      // 1. Scorri fino a rendere visibile il pulsante
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle(); // Attendi che l'animazione di scroll termini

      // 2. Ora che è visibile, tappa il pulsante
      await tester.tap(buttonFinder);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      // Verifica che updateActivity sia stato chiamato (dato che stiamo modificando)
      verify(mockDatabaseService.updateActivity(any, any, any, any)).called(1);
    });

    /*testWidgets('should create new attraction when form is submitted without existing attraction', (WidgetTester tester) async {
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Stub del database service
      when(mockDatabaseService.createActivity(any)).thenAnswer((_) async => Future.value());

      // Simula la selezione di un luogo (necessario per validazione)
      final locationField = find.widgetWithText(TextFormField, 'Dove?');
      await tester.tap(locationField);
      await tester.pumpAndSettle();

      // Simula l'inserimento manuale del testo (dato che onTap apre un modal)
      final locationTextFormField = tester.widget<TextFormField>(locationField);
      locationTextFormField.controller?.text = 'Test Location';

      // Simula la selezione di date (set manualmente per il test)
      final attractionFormState = tester.state<_AttractionFormState>(find.byType(AttractionForm));
      attractionFormState._startDate = DateTime(2025, 12, 10);
      attractionFormState._endDate = DateTime(2025, 12, 11);

      // Compila altri campi opzionali
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Indirizzo'),
          'Test Address'
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Costo'),
          '40'
      );

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi attività');

      // Ottieni il widget e simula il tap direttamente
      final button = tester.widget<ElevatedButton>(buttonFinder);
      button.onPressed?.call();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 200));

      // Verifica che createActivity sia stato chiamato
      verify(mockDatabaseService.createActivity(any)).called(1);

      // Cattura l'argomento passato per verificare i dati
      final captured = verify(mockDatabaseService.createActivity(captureAny)).captured;
      expect(captured.length, 1);

      final AttractionModel capturedAttraction = captured.first as AttractionModel;
      expect(capturedAttraction.tripId, testTrip.id);
      expect(capturedAttraction.type, 'attraction');
      expect(capturedAttraction.name, 'Test Location');
      expect(capturedAttraction.address, 'Test Address');
    });*/

    testWidgets('should show validation errors for empty required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionForm(trip: testTrip, databaseService: mockDatabaseService,),
          ),
        ),
      );

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi attività');
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verifica che vengano mostrati gli errori di validazione
      expect(find.text('Inserisci un luogo'), findsOneWidget);
      expect(find.text('Per favore seleziona delle date'), findsOneWidget);

      // Verifica che createActivity NON sia stato chiamato
      verifyNever(mockDatabaseService.createActivity(any));
    });

    testWidgets('should show snackbar when validation fails', (WidgetTester tester) async {
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Aggiungi attività');
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verifica che appaia la snackbar con il messaggio di errore
      expect(find.text('Per favore compila tutti i campi correttamente!'), findsOneWidget);
    });
  });
}