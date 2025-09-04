import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/explorerPage.dart';
import 'package:dima_project/screens/homePage.dart';
import 'package:dima_project/screens/myTripsPage.dart';
import 'package:dima_project/screens/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockAuthService mockAuthService;
  late MockUser mockCurrentUser;

  UserModel testCurrentUserModel = UserModel(
    id: 'user_001',
    name: 'Alice',
    surname: 'Rossi',
    username: 'alice_rossi',
    profilePic: 'assets/profile.png',
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
    mockAuthService = MockAuthService();
    mockCurrentUser = MockUser();

    when(mockCurrentUser.uid).thenReturn('user_001');
    when(mockAuthService.currentUser).thenReturn(mockCurrentUser);
    when(mockDatabaseService.getUserByUid(any)).thenAnswer(
          (_) async => testCurrentUserModel,
    );
    when(mockDatabaseService.getExplorerTrips())
        .thenAnswer((_) async => testTripList);
    when(mockDatabaseService.getHomePageTrips()).thenAnswer((_) async => []
    );
    when(mockDatabaseService.getTripsOfUserWithPrivacy(any, any)).thenAnswer((_) async => []);
  });

  testWidgets('MyHomePage shows AppBar and NavigationBar', (
      WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(
          title: 'Titolo HomePage',
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Benvenuto ${testCurrentUserModel.name}'), findsOneWidget);

    expect(find.byType(NavigationBar), findsOneWidget);

    expect(find.text('Esplora'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);

    expect(find.widgetWithIcon(NavigationBar, Icons.search), findsOneWidget);
    expect(find.widgetWithIcon(NavigationBar, Icons.home_outlined), findsOneWidget);
    expect(find.widgetWithIcon(NavigationBar, Icons.account_box_outlined), findsOneWidget);
  });


  testWidgets('NavigationBar switches between pages correctly', (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(
          title: 'Test HomePage',
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );
    await tester.pumpAndSettle();
    when(mockDatabaseService.getTripsByIds(any)).thenAnswer((_) async => []);

    //initial state
    expect(find.byType(ExplorerPage), findsOneWidget);
    expect(find.byType(MyTripsPage), findsNothing);
    expect(find.byType(ProfilePage), findsNothing);

    await tester.tap(find.byKey(const Key('homeButton')));
    await tester.pumpAndSettle();

    expect(find.byType(ExplorerPage), findsNothing);
    expect(find.byType(MyTripsPage), findsOneWidget);
    expect(find.byType(ProfilePage), findsNothing);

    await tester.tap(find.byKey(const Key('profileButton')));
    await tester.pumpAndSettle();

    expect(find.byType(ExplorerPage), findsNothing);
    expect(find.byType(MyTripsPage), findsNothing);
    expect(find.byType(ProfilePage), findsOneWidget);

    //back to Explorer page
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();

    expect(find.byType(ExplorerPage), findsOneWidget);
    expect(find.byType(MyTripsPage), findsNothing);
    expect(find.byType(ProfilePage), findsNothing);
  });
}