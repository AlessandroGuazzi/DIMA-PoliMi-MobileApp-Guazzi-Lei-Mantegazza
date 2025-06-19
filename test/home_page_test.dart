import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/homePage.dart';
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
  });

  testWidgets('MyHomePage shows AppBar and BottomNavigationBar', (
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

    // Verifica che l'AppBar sia presente con il titolo corretto
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Titolo HomePage'), findsOneWidget);

    // Verifica che la BottomNavigationBar sia presente
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verifica le etichette delle tre voci di navigazione
    expect(find.text('Esplora'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);

    // Verifica le icone
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.account_box), findsOneWidget);
  });


  testWidgets('BottomNavigationBar switches between pages',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MyHomePage(
              title: 'Titolo HomePage',
              databaseService: mockDatabaseService,
              authService: mockAuthService,
            ),
          ),
        );

        await tester.pumpAndSettle(); // aspetta il caricamento

        // Controlla che la pagina iniziale sia Esplora
        expect(find.text('Esplora'), findsWidgets);

        // Clicca sulla tab "Home"
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();

        // Controlla che sia visibile la pagina Home
        expect(find.text('Home'), findsWidgets);

        // Clicca sulla tab "Profilo"
        //await tester.tap(find.byIcon(Icons.account_box));
        await tester.pumpAndSettle();

        // Controlla che sia visibile la pagina Profilo
        //expect(find.text('Profilo'), findsWidgets);

        // Torna a Esplora
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        // Controlla che sia visibile di nuovo Esplora
        expect(find.text('Esplora'), findsWidgets);
      });
}