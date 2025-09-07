import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/explorerPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockAuthService mockAuthService;
  late MockUser mockCurrentUser;

  UserModel testCurrentUserModel = UserModel(
    id: 'user_001',
    name: 'Alice',
    surname: 'Rossi',
    username: 'alice_rossi',
    profilePic: 'https://example.com/profile.png',
    birthDate: DateTime(1995, 6, 15),
    mail: 'alice@example.com',
    birthCountry: 'Italy',
    description: 'Love to travel the world!',
    createdTrip: ['trip_001'],
    savedTrip: ['trip_002'],
    visitedCountry: ['IT', 'FR'],
    joinDate: DateTime(2022, 1, 1),
  );

  final testTripList = [
    TripModel(
      id: 'trip_002',
      creatorInfo: {
        'id': 'user_002',
        'name': 'John Doe',
        'username': 'john_doe',
      },
      title: 'European Adventure',
      timestamp: Timestamp.fromDate(DateTime(2024, 1, 1)),
      saveCounter: 1,
    ),
    TripModel(
      id: 'trip_003',
      creatorInfo: {
        'id': 'user_003',
        'name': 'Bob',
        'username': 'bob33',
      },
      title: 'Wonderful trip',
      timestamp: Timestamp.fromDate(DateTime(2025, 1, 1)),
      saveCounter: 7,
    ),
  ];

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockCurrentUser = MockUser();
    mockAuthService = MockAuthService();

    when(mockCurrentUser.uid).thenReturn('user_001');
    when(mockAuthService.currentUser).thenReturn(mockCurrentUser);
    when(mockDatabaseService.getUserByUid(any)).thenAnswer((_) =>
        Future.delayed(
            const Duration(milliseconds: 1), () => testCurrentUserModel));
    when(mockDatabaseService.getExplorerTrips())
        .thenAnswer((_) async => testTripList);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: ExplorerPage(
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    );
  }


  testWidgets('displays loading indicator while fetching user',
      (WidgetTester tester) async {
    //delayed
    await tester.pumpWidget(buildTestableWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the future complete
    await tester.pumpAndSettle();
  });

  testWidgets('shows empty message when no trips', (WidgetTester tester) async {
    when(mockDatabaseService.getExplorerTrips()).thenAnswer((_) async => []);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Nessun viaggio pubblico'), findsOneWidget);
  });

  testWidgets('shows trips when available', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    //assert first that the search bar is empty
    await tester.enterText(find.byType(SearchBar), '');
    await tester.pumpAndSettle();

    //assert that there's the same number of trip widget as the length of the trips returned
    expect(find.byType(TripCardWidget), findsExactly(testTripList.length));
    //assert that the trip title is correct for each trip in the list
    for (var trip in testTripList) {
      expect(find.text(trip.title!), findsOneWidget);
    }
  });

  testWidgets('filters trips based on search query',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);

    //simulate write query on the search bar
    await tester.enterText(searchBar, 'European');
    await tester.pumpAndSettle();

    //assert that the trip with matching title is displayed and the others are not
    expect(find.text('European Adventure'), findsOneWidget);
    expect(find.text('Wonderful trip'), findsNothing);
  });

  testWidgets('sorts trips by date', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final sortButton = find.byIcon(Icons.filter_alt_outlined);
    expect(sortButton, findsOneWidget);

    await tester.tap(sortButton);
    await tester.pumpAndSettle();

    expect(find.text('Più recenti'), findsOneWidget);
    await tester.tap(find.text('Più recenti'));
    await tester.pumpAndSettle();

    //assert that the trips are sorted by date
    final tripCards =
        tester.widgetList<TripCardWidget>(find.byType(TripCardWidget)).toList();
    final timestamps = tripCards.map((card) => card.trip.timestamp!).toList();

    final sortedTimestamps = [...timestamps]..sort((a, b) => b.compareTo(a));
    expect(timestamps, sortedTimestamps);
  });

  testWidgets('sorts trips by popularity', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final sortButton = find.byIcon(Icons.filter_alt_outlined);
    expect(sortButton, findsOneWidget);

    await tester.tap(sortButton);
    await tester.pumpAndSettle();

    expect(find.text('Più popolari'), findsOneWidget);
    await tester.tap(find.text('Più popolari'));
    await tester.pumpAndSettle();

    //assert that the trips are sorted by popularity
    final tripCards =
        tester.widgetList<TripCardWidget>(find.byType(TripCardWidget)).toList();
    final saveCounters =
        tripCards.map((card) => card.trip.saveCounter!).toList();

    final sortedSaveCounters = [...saveCounters]
      ..sort((a, b) => b.compareTo(a));
    expect(saveCounters, sortedSaveCounters);
  });

  testWidgets('click on save button updates saveCounter (saved -> unsaved)', (WidgetTester tester) async {

    final mockTripList = [
      TripModel(
        id: 'trip_002',
        creatorInfo: {
          'id': 'user_002',
          'name': 'John Doe',
          'username': 'john_doe',
        },
        title: 'European Adventure',
        timestamp: Timestamp.fromDate(DateTime(2024, 1, 1)),
        saveCounter: 1,
      ),
      TripModel(
        id: 'trip_003',
        creatorInfo: {
          'id': 'user_003',
          'name': 'Bob',
          'username': 'bob33',
        },
        title: 'Wonderful trip',
        timestamp: Timestamp.fromDate(DateTime(2025, 1, 1)),
        saveCounter: 7,
      ),
    ];

    when(mockDatabaseService.getExplorerTrips())
        .thenAnswer((_) async => mockTripList);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // mock db call
    when(mockDatabaseService.handleTripSave(any, any)).thenAnswer((_) async {});

    // Find the first trip's save button (saved icon)
    Finder saveButton = find.byIcon(Icons.bookmark_added_rounded).first;
    expect(saveButton, findsOneWidget);

    // mock db call
    when(mockDatabaseService.handleTripSave(any, any)).thenAnswer((_) async {
      testCurrentUserModel.savedTrip!.remove(mockTripList[0].id);
    });

    // First tap: should remove save, decrement counter
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(mockTripList[0].saveCounter, equals(0));

    // Second tap: should add save back, increment counter
    saveButton = find.byIcon(Icons.bookmark_add_outlined).first;
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(mockTripList[0].saveCounter, equals(1));
  });
}
