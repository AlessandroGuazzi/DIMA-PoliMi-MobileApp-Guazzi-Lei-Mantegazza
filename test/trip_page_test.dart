import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/mapPage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockDatabaseService mockDatabaseService;
  //late GooglePlacesService mockGooglePlacesService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockNavigatorObserver = MockNavigatorObserver();
    //mockGooglePlacesService = MockGooglePlacesService();
    //when(mockGooglePlacesService.getImageUrl(any)).thenReturn('some_image_url');)
    when(mockDatabaseService.getTripActivities(any))
        .thenAnswer((_) async => [FlightModel(type: 'flight'), AttractionModel(type: 'attraction')]);
  });

  Future<void> pumpTestableWidget(WidgetTester tester, trip, isMyTrip) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TripPage(
          databaseService: mockDatabaseService, trip: trip, isMyTrip: isMyTrip,
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  testWidgets('correctly renders trip info when isMyTrip == true', (tester) async {
    final trip = TripModel(
      id: '1',
      title: 'Test Trip',
      endDate: DateTime.now().add(const Duration(days: 10)),
    );
    const isMyTrip = true;

    await pumpTestableWidget(tester, trip, isMyTrip);
    await tester.pumpAndSettle();

    // Check title + image + action button
    expect(find.text('Test Trip'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('correctly renders trip info when isMyTrip == false', (tester) async {
    final trip = TripModel(
      id: '1',
      title: 'Test Trip',
      endDate: DateTime.now().add(const Duration(days: 10)),
    );
    const isMyTrip = false;

    await pumpTestableWidget(tester, trip, isMyTrip);
    await tester.pumpAndSettle();

    // Check title + image + not action button
    expect(find.text('Test Trip'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('correctly renders actions options', (tester) async {
    final trip = TripModel(id: '1', title: 'Trip', endDate: DateTime.now(), isPrivate: true);

    await pumpTestableWidget(tester, trip, true);
    await tester.pumpAndSettle();

    // tap on actions button
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Elimina'), findsOneWidget);
    expect(find.text('Apri mappa'), findsOneWidget);
    expect(find.text('Pubblica'), findsOneWidget);
  });

  testWidgets('tapping on \'Modifica\' navigate to \'UpsertTripPage\'', (tester) async {
    final trip = TripModel(id: '1', title: 'Trip', endDate: DateTime.now(), isPrivate: true);
    final updatedTrip = TripModel(id: '1', title: 'Updated Trip', endDate: DateTime.now());

    await pumpTestableWidget(tester, trip, true);
    await tester.pumpAndSettle();

    // tap on actions button
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    expect(find.byType(UpsertTripPage), findsOneWidget);
  });

  testWidgets('tapping on \'Apri mappa\' navigate to \'MapPage\'', (tester) async {
    final trip = TripModel(id: '1', title: 'Trip', endDate: DateTime.now(), isPrivate: true);

    await pumpTestableWidget(tester, trip, true);
    await tester.pumpAndSettle();

    // tap on actions button
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apri mappa'));
    await tester.pumpAndSettle();

    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets('Delete trip flow', (tester) async {

    final trip = TripModel(
      id: '1',
      title: 'Trip to Delete',
      endDate: DateTime.now(),
    );

    when(mockDatabaseService.deleteTrip(any)).thenAnswer((_) async => Future.value());

    await pumpTestableWidget(tester, trip, true);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Elimina'));
    await tester.pumpAndSettle();

    // aswert delete dialog
    expect(find.text('Conferma eliminazione'), findsOneWidget);
    expect(find.text('Elimina'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Elimina'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200)); // delayed snackbar

    // Verify deleteTrip is called
    verify(mockDatabaseService.deleteTrip(trip.id!)).called(1);

    // Check snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Viaggio eliminato con successo'), findsOneWidget);
  });

  testWidgets('Privacy toggle updates trip privacy ', (tester) async {

    final trip = TripModel(id: '1', title: 'Private Trip', isPrivate: true);

    //stub db call
    when(mockDatabaseService.updateTripPrivacy(any, any))
        .thenAnswer((_) async {});

    // Build the widget
    await pumpTestableWidget(tester, trip, true);
    await tester.pumpAndSettle();

    //tap actions
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pubblica'));
    await tester.pumpAndSettle();

    //Assert that updateTripPrivacy was called with newPrivacy = false
    verify(mockDatabaseService.updateTripPrivacy('1', false)).called(1);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    //Now the text should have changed
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Rendi privato'), findsOneWidget);
  });

  testWidgets('Privacy toggle exception from db ', (tester) async {

    final trip = TripModel(id: '1', title: 'Private Trip', isPrivate: true);

    //stub db call
    when(mockDatabaseService.updateTripPrivacy(any, any))
        .thenAnswer((_) async => throw Exception('error'));

    // Build the widget
    await pumpTestableWidget(tester, trip, true);
    await tester.pumpAndSettle();

    //tap actions
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pubblica'));
    await tester.pumpAndSettle();

    //Assert that updateTripPrivacy was called with newPrivacy = false
    verify(mockDatabaseService.updateTripPrivacy('1', false)).called(1);

    //verify that execption is caught
    expect(find.text('Errore'), findsOneWidget);
    expect(find.text('Impossibile aggiornare'), findsOneWidget);

  });
}