import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/createActivityPage.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/activity_widgets/forms/FlightForm.dart';
import 'package:dima_project/widgets/trip_widgets/itineraryWidget.dart';
import 'package:dima_project/widgets/activity_widgets/flightActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/attractionActivityCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';


void main() {
  late MockDatabaseService mockDatabaseService;
  //late GooglePlacesService mockGooglePlacesService;
  late MockNavigatorObserver mockNavigatorObserver;

  late TripModel fakeTrip;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockNavigatorObserver = MockNavigatorObserver();

    fakeTrip = TripModel(
      id: '123',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2025, 12, 12),
    );

    when(mockDatabaseService.getTripActivities(any)).thenAnswer(
          (_) async => [
        FlightModel(id: 'f1', tripId: '123', type: 'flight', departureDate: DateTime(2024, 1, 2)),
        AttractionModel(id: 'a1', tripId: '123', type: 'attraction', startDate: DateTime(2024, 1, 3)),
      ],
    );
  });


  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
      navigatorObservers: [mockNavigatorObserver],

    );
  }

  testWidgets('renders activities from database', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      ItineraryWidget(
        trip: fakeTrip,
        isMyTrip: true,
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(FlightActivityCard), findsOneWidget);
    expect(find.byType(AttractionActivityCard), findsOneWidget);
  });

  testWidgets('opens bottom sheet when add button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      ItineraryWidget(
        trip: fakeTrip,
        isMyTrip: true,
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Crea una nuova attività'), findsOneWidget);
    expect(find.text('Volo'), findsOneWidget);
    expect(find.text('Alloggio'), findsOneWidget);
  });

  testWidgets('navigates to CreateActivityPage on tap', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      ItineraryWidget(
        trip: fakeTrip,
        isMyTrip: true,
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Volo'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateActivityPage), findsOneWidget);
  });
}




