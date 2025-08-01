import 'dart:async';

import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/accountSettings.dart';
import 'package:dima_project/screens/travelStatsPage.dart';
import 'package:dima_project/screens/medalsPage.dart';
import 'package:dima_project/screens/profilePage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


import 'mocks.mocks.dart';

void main() {
  //TODO: fix tests since profile page was modified
  group('ProfilePage Tests', () {
    late MockDatabaseService mockDatabaseService;
    late MockAuthService mockAuthService;
    late MockUser mockUser;

    // Sample test data
    final testUser = UserModel(
      id: 'test-uid',
      name: 'John',
      surname: 'Doe',
      username: 'johndoe',
      mail: 'john@example.com',
      savedTrip: ['trip1', 'trip2'],
      profilePic: null,
    );

    final testTrips = [
      TripModel(
        id: 'trip1',
        title: 'Test Trip 1',
        nations: [
          {
            'name': 'Italy',
            'flag': '',
            'code': 'iT',
          },
          {
            'name': 'France',
            'flag': '',
            'code': 'fR',
          }
        ],
        cities: [
          {
            'name': 'Rome',
            'place_id': '',
            'lat': 41.9027835,
            'lng': 12.4963655,
          }
        ],
      ),
      TripModel(
        id: 'trip2',
        title: 'Test Trip 2',
        nations: [
          {
            'name': 'Italy',
            'flag': '',
            'code': 'iT',
          },
          {
            'name': 'France',
            'flag': '',
            'code': 'fR',
          }
        ],
        cities: [
          {
            'name': 'Paris',
            'place_id': '',
            'lat': 41.9027835,
            'lng': 12.4963655,
          }
        ],
      ),
    ];

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockAuthService = MockAuthService();
      mockUser = MockUser();

      // Setup default mock behavior
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockDatabaseService.getUserByUid('test-uid'))
          .thenAnswer((_) async => testUser);
      when(mockDatabaseService.getHomePageTrips())
          .thenAnswer((_) async => testTrips);
      when(mockDatabaseService.getTripsByIds(['trip1', 'trip2']))
          .thenAnswer((_) async => testTrips);
      when(mockDatabaseService.getTripsByIds(null)).thenAnswer((_) async => []);
    });

    Widget createTestWidget(String? userId) {
      return MaterialApp(
        home: Scaffold(
          body: ProfilePage(
            userId: userId,
            databaseService: mockDatabaseService,
            authService: mockAuthService,
            isCurrentUser: true,
          ),
        ),
      );
    }

    group('State Logic', () {
      testWidgets('user is correctly loaded when authenticated',
          (tester) async {

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pump();

        verify(mockDatabaseService.getUserByUid('test-uid')).called(1);
      });

      testWidgets('handles when user not authenticated',
          (tester) async {

        //pump the widget with a null user
        await tester.pumpWidget(createTestWidget(null));
        await tester.pumpAndSettle();

        verifyNever(mockDatabaseService.getUserByUid(any));
        expect(find.text('Nessun utente autenticato'), findsOneWidget);
      });

      testWidgets('signOut calls AuthService.signOut', (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Log Out'));
        await tester.pump();

        verify(mockAuthService.signOut()).called(1);
      });

      testWidgets('initState initializes futures correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));

        verify(mockDatabaseService.getHomePageTrips()).called(1);
      });
    });

    group('UI Rendering', () {
      testWidgets('displays loading indicator while fetching user data',
          (tester) async {
        when(mockDatabaseService.getUserByUid(any)).thenAnswer(
            (_) => Future.delayed(const Duration(seconds: 1), () => testUser));

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();
      });

      testWidgets('displays ui elements correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('@johndoe'), findsOneWidget);

        //tab bar
        expect(find.text('Viaggi Salvati'), findsOneWidget);
        expect(find.text('I Tuoi Viaggi'), findsOneWidget);
      });

      testWidgets('displays default profile image when user has no profile pic',
          (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        final avatarFinder = find.byType(CircleAvatar);
        expect(avatarFinder, findsWidgets);

        final CircleAvatar avatar = tester.widget(avatarFinder.first);
        expect((avatar.backgroundImage as AssetImage).assetName,
            'assets/profile.png');
      });

      testWidgets('displays custom profile image when available',
          (tester) async {
        final userWithPic = UserModel(
          id: 'test-id',
          name: 'John',
          surname: 'Doe',
          username: 'johndoe',
          mail: 'john@example.com',
          profilePic: 'assets/avatars/avatar_1.png',
        );

        when(mockDatabaseService.getUserByUid('test-uid'))
            .thenAnswer((_) async => userWithPic);

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        final CircleAvatar avatar =
            tester.widget(find.byType(CircleAvatar).first);
        expect((avatar.backgroundImage as AssetImage).assetName,
            userWithPic.profilePic);
      });

      testWidgets('displays error message when user data fails to load', (tester) async {
        await runZonedGuarded(() async {
          when(mockDatabaseService.getUserByUid(any))
              .thenAnswer((_) => Future<UserModel>.error('Error'));

          await tester.pumpWidget(createTestWidget('test-uid'));
          await tester.pumpAndSettle();

          expect(find.textContaining('Errore:'), findsOneWidget);
        }, (error, stack) {
          print('Error: $error');
        });
      });
    });


    group('Responsive Layout', () {
      testWidgets('displays mobile layout on small screens', (tester) async {

        final originalPhysicalSize = tester.view.physicalSize;
        final originalDevicePixelRatio = tester.view.devicePixelRatio;

        // Force mobile layout
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        //Check for mobile-specific elements
        expect(find.byType(SliverAppBar), findsOneWidget);
        expect(find.text('Modifica Profilo'), findsNothing);

        // Restore original layout
        addTearDown(() {
          tester.view.physicalSize = originalPhysicalSize;
          tester.view.devicePixelRatio = originalDevicePixelRatio;
        });
      });

      testWidgets('displays tablet layout on large screens', (tester) async {
        final originalPhysicalSize = tester.view.physicalSize;
        final originalDevicePixelRatio = tester.view.devicePixelRatio;

        // Force tablet layout
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        // Check for tablet-specific elements
        expect(find.byType(VerticalDivider), findsOneWidget);
        expect(find.text('Modifica Profilo'), findsOneWidget);
        expect(find.text('Nazioni Visitate'), findsOneWidget);
        expect(find.text('Medaglie'), findsOneWidget);
        expect(find.text('Log Out'), findsOneWidget);

        // Restore original layout
        addTearDown(() {
          tester.view.physicalSize = originalPhysicalSize;
          tester.view.devicePixelRatio = originalDevicePixelRatio;
        });
      });
    });

    group('Trip Lists', () {
      testWidgets('displays saved trips correctly', (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        expect(find.byType(TripCardWidget), findsNWidgets(2));
      });

      testWidgets('displays empty message when no saved trips', (tester) async {
        when(mockDatabaseService.getTripsByIds(any))
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        expect(find.text('Nessun viaggio salvato'), findsOneWidget);
      });

      testWidgets('displays empty message when no created trips',
          (tester) async {
        when(mockDatabaseService.getHomePageTrips())
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        //switch tab
        await tester.tap(find.text('I Tuoi Viaggi'));
        await tester.pumpAndSettle();

        expect(find.text('Nessun viaggio creato'), findsOneWidget);
      });

      testWidgets('shows loading indicator while fetching trips',
          (tester) async {
        when(mockDatabaseService.getTripsByIds(any)).thenAnswer((_) =>
            Future.delayed(const Duration(seconds: 1), () => testTrips));

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsWidgets);

        await tester.pumpAndSettle();

      });
    });

    group('Navigation', () {
      testWidgets('navigates to TripPage when trip card is tapped',
          (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        //stub trip page
        when(mockDatabaseService.getTripActivities(any))
            .thenAnswer((_) async => []);

        await tester.tap(find.byType(TripCardWidget).first);
        await tester.pumpAndSettle();

        expect(find.byType(TripPage), findsOneWidget);
      });

      testWidgets('opens settings modal on mobile when settings icon is tapped',
          (tester) async {
        final originalPhysicalSize = tester.view.physicalSize;
        final originalDevicePixelRatio = tester.view.devicePixelRatio;

        // Force mobile layout
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsOneWidget);

        // Restore original layout
        addTearDown(() {
          tester.view.physicalSize = originalPhysicalSize;
          tester.view.devicePixelRatio = originalDevicePixelRatio;
        });
      });
    });

    group('Settings Menu', () {
      testWidgets('settings menu displays all options', (tester) async {

        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        expect(find.text('Modifica Profilo'), findsOneWidget);
        expect(find.text('Nazioni Visitate'), findsOneWidget);
        expect(find.text('Medaglie'), findsOneWidget);
        expect(
          find.text('Tema chiaro').evaluate().isNotEmpty ||
              find.text('Tema scuro').evaluate().isNotEmpty,
          isTrue,
        );
        expect(find.text('Log Out'), findsOneWidget);
      });

      testWidgets(
          'navigates to AccountSettings when Modifica Profilo is tapped',
          (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Modifica Profilo'));
        await tester.pumpAndSettle();

        expect(find.byType(AccountSettings), findsOneWidget);
      });

      testWidgets('navigates to GamePage when Nazioni Visitate is tapped',
          (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        //stub travel stats page
        when(mockDatabaseService.getCompletedTrips(any))
            .thenAnswer((_) async => []);

        await tester.tap(find.text('Nazioni Visitate'));
        await tester.pumpAndSettle();

        expect(find.byType(TravelStatsPage), findsOneWidget);
      });

      testWidgets('navigates to MedalsPage when Medaglie is tapped',
          (tester) async {
        await tester.pumpWidget(createTestWidget('test-uid'));
        await tester.pumpAndSettle();

        //stub
        when(mockDatabaseService.getUserByUid(any))
            .thenAnswer((_) async => testUser);
        when(mockDatabaseService.getCompletedTrips(any))
            .thenAnswer((_) async => []);

        await tester.tap(find.text('Medaglie'));
        await tester.pumpAndSettle();

        expect(find.byType(MedalsPage), findsOneWidget);
      });
    });

    group('Edge Cases', () {

      testWidgets('handles errors during trip loading', (tester) async {
        await runZonedGuarded(() async {
          when(mockDatabaseService.getHomePageTrips())
              .thenAnswer((_) async => throw Exception('Test error'));

          await tester.pumpWidget(createTestWidget('test-uid'));
          await tester.pumpAndSettle();

          // Switch tab
          await tester.tap(find.text('I Tuoi Viaggi'));
          await tester.pumpAndSettle();

          expect(find.text('Nessun viaggio creato'), findsOneWidget);
        }, (error, stack) {
          print('Error: $error');
        });
      });
    });
  });
}
