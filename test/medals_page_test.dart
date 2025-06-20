import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/medalsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

void main() {
  group('MedalsPage Data Processing Tests', () {
    late MedalsPage medalsPage;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      medalsPage = MedalsPage(
        username: 'testUser',
        userId: 'testId',
        databaseService: mockDatabaseService,
      );
    });

    group('extractCountryCodes', () {
      test('should extract country codes from valid trips', () {
        // Arrange
        final trips = [
          TripModel(nations: [
            {'code': 'IT', 'name': 'Italy'},
            {'code': 'FR', 'name': 'France'},
          ]),
          TripModel(nations: [
            {'code': 'DE', 'name': 'Germany'},
          ]),
        ];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.extractCountryCodes(trips);

        // Assert
        expect(result, equals(['IT', 'FR', 'DE']));
      });

      test('should handle trips with null nations', () {
        // Arrange
        final trips = [
          TripModel(nations: null),
          TripModel(nations: [
            {'code': 'IT', 'name': 'Italy'},
          ]),
        ];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.extractCountryCodes(trips);

        // Assert
        expect(result, equals(['IT']));
      });

      test('should handle trips with empty nations', () {
        // Arrange
        final trips = [
          TripModel(nations: []),
          TripModel(nations: [
            {'code': 'IT', 'name': 'Italy'},
          ]),
        ];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.extractCountryCodes(trips);

        // Assert
        expect(result, equals(['IT']));
      });

      test('should handle nations with null or empty codes', () {
        // Arrange
        final trips = [
          TripModel(nations: [
            {'code': null, 'name': 'Invalid'},
            {'code': '', 'name': 'Empty'},
            {'code': 'IT', 'name': 'Italy'},
          ]),
        ];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.extractCountryCodes(trips);

        // Assert
        expect(result, equals(['IT']));
      });

      test('should return empty list for empty trips', () {
        // Arrange
        final trips = <TripModel>[];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.extractCountryCodes(trips);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('countCountriesByContinent', () {
      test('should count countries correctly by continent', () {
        // Arrange
        final countryCodes = ['iT', 'fR', 'uS', 'jP', 'bR', 'eG', 'aU'];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.countCountriesByContinent(countryCodes);

        // Assert
        expect(result['Mondo'], equals(7));
        expect(result['Europa'], equals(2)); // IT, FR
        expect(result['Asia'], equals(1)); // JP
        expect(result['America Settentrionale'], equals(1)); // US
        expect(result['America Meridionale'], equals(1)); // BR
        expect(result['Africa'], equals(1)); // EG
        expect(result['Oceania'], equals(1)); // AU
      });

      test('should handle empty country list', () {
        // Arrange
        final countryCodes = <String>[];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.countCountriesByContinent(countryCodes);

        // Assert
        expect(result['Mondo'], equals(0));
        expect(result['Europa'], equals(0));
        expect(result['Asia'], equals(0));
        expect(result['America Settentrionale'], equals(0));
        expect(result['America Meridionale'], equals(0));
        expect(result['Africa'], equals(0));
        expect(result['Oceania'], equals(0));
      });

      test('should handle countries from single continent', () {
        // Arrange
        final countryCodes = ['iT', 'fR', 'dE', 'eS'];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.countCountriesByContinent(countryCodes);

        // Assert
        expect(result['Mondo'], equals(4));
        expect(result['Europa'], equals(4));
        expect(result['Asia'], equals(0));
      });

      test('should handle invalid country codes', () {
        // Arrange
        final countryCodes = ['xX', 'yY', 'iT'];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.countCountriesByContinent(countryCodes);

        // Assert
        expect(result['Mondo'], equals(3));
        expect(result['Europa'], equals(1)); // Only IT
      });
    });

    group('removeDuplicates', () {
      test('should remove duplicates from list', () {
        // Arrange
        final list = ['IT', 'FR', 'IT', 'DE', 'FR'];

        // Act
        final state = medalsPage.createState() as dynamic;
        final result = state.removeDuplicates(list);

        // Assert
        expect(result, equals(['IT', 'FR', 'DE']));
      });
    });
  });

  group('MedalsPage Business Logic Tests', () {
    test('should calculate correct level based on percentage', () {
      final testCases = [
        {'countries': 0, 'expected': 'Esploratore Novizio'},
        {'countries': 50, 'expected': 'Esploratore Novizio'}, // ~20%
        {'countries': 63, 'expected': 'Viaggiatore Avventuroso'}, // 25%
        {'countries': 100, 'expected': 'Viaggiatore Avventuroso'}, // ~40%
        {'countries': 126, 'expected': 'Globetrotter Esperto'}, // 50%
        {'countries': 150, 'expected': 'Globetrotter Esperto'}, // ~60%
        {'countries': 189, 'expected': 'Maestro del Viaggio'}, // 75%
        {'countries': 200, 'expected': 'Maestro del Viaggio'}, // ~80%
        {'countries': 251, 'expected': 'Leggenda del Mondo'}, // 100%
      ];

      for (final testCase in testCases) {
        final countries = testCase['countries'] as int;
        final expected = testCase['expected'] as String;

        // Simulate the level calculation logic
        final percentage = countries / 251;
        String level;

        if (percentage < 0.25) {
          level = "Esploratore Novizio";
        } else if (percentage < 0.5) {
          level = "Viaggiatore Avventuroso";
        } else if (percentage < 0.75) {
          level = "Globetrotter Esperto";
        } else if (percentage < 1) {
          level = "Maestro del Viaggio";
        } else {
          level = "Leggenda del Mondo";
        }

        expect(level, equals(expected),
            reason: '$countries countries should be $expected level');
      }
    });

    test('should calculate medal achievements correctly', () {
      final testCases = [
        {
          'visited': 0,
          'total': 100,
          'expected': [false, false, false, false, false]
        },
        {
          'visited': 1,
          'total': 100,
          'expected': [true, false, false, false, false]
        },
        {
          'visited': 25,
          'total': 100,
          'expected': [true, true, false, false, false]
        },
        {
          'visited': 50,
          'total': 100,
          'expected': [true, true, true, false, false]
        },
        {
          'visited': 75,
          'total': 100,
          'expected': [true, true, true, true, false]
        },
        {
          'visited': 100,
          'total': 100,
          'expected': [true, true, true, true, true]
        },
      ];

      for (final testCase in testCases) {
        final visited = testCase['visited'] as int;
        final total = testCase['total'] as int;
        final expected = testCase['expected'] as List<bool>;

        final percentage = (visited / total) * 100;

        final results = List.generate(5, (index) {
          switch (index) {
            case 0:
              return visited >= 1;
            case 1:
              return percentage >= 25;
            case 2:
              return percentage >= 50;
            case 3:
              return percentage >= 75;
            case 4:
              return percentage >= 100;
            default:
              return false;
          }
        });

        expect(results, equals(expected),
            reason: '$visited/$total should have medals: $expected');
      }
    });
  });

  group('MedalsPage Widget Tests', () {
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
    });

    Future<void> pumpTestableWidget(
        WidgetTester tester, String username, String userId) async {
      await tester.pumpWidget(MaterialApp(
          home: MedalsPage(
        username: username,
        userId: userId,
        databaseService: mockDatabaseService,
      )));
    }

    testWidgets('should show loading indicator while data is loading',
        (tester) async {
      // Arrange
      when(mockDatabaseService.getUserByUid(any)).thenAnswer(
          (_) => Future.delayed(const Duration(seconds: 1), () => null));
      when(mockDatabaseService.getCompletedTrips(any)).thenAnswer(
          (_) => Future.delayed(const Duration(seconds: 1), () => []));

      await pumpTestableWidget(tester, 'testUser', 'testId');

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should show user not found when user is null', (tester) async {
      when(mockDatabaseService.getUserByUid(any)).thenAnswer((_) async => null);
      when(mockDatabaseService.getCompletedTrips(any))
          .thenAnswer((_) async => []);

      await pumpTestableWidget(tester, 'testUser', 'testId');
      await tester.pumpAndSettle();

      expect(find.text('Utente non trovato'), findsOneWidget);
    });

    testWidgets('should display correct level and countries visited', (tester) async {

      final mockUser = UserModel(
        id: 'testId',
        username: 'TestUser',
        birthCountry: 'IT',
      );

      final mockTrips = [
        TripModel(nations: [
          {'code': 'IT', 'name': 'Italy'},
          {'code': 'FR', 'name': 'France'},
        ]),
      ];

      when(mockDatabaseService.getUserByUid('testId'))
          .thenAnswer((_) async => mockUser);
      when(mockDatabaseService.getCompletedTrips('testId'))
          .thenAnswer((_) async => mockTrips);

      await pumpTestableWidget(tester, mockUser.username!, mockUser.id!);
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget); // countries visited
      expect(find.text('Esploratore Novizio'), findsOneWidget); // level
      expect(find.text('Mondo'), findsOneWidget);
      expect(find.text('Europa'), findsOneWidget);
    });

    testWidgets('should display correct medal states for achievements',
        (tester) async {
      final mockUser = UserModel(
        id: 'testId',
        username: 'TestUser',
        birthCountry: 'IT',
      );

      //these trips should get two medals in europe
      final mockTrips = [
        TripModel(
            nations: List.generate(
                15,
                (i) => {
                      'code': [
                        'iT',
                        'fR',
                        'dE',
                        'eS',
                        'pT',
                        'nL',
                        'bE',
                        'aT',
                        'cH',
                        'sE',
                        'nO',
                        'dK',
                        'fI',
                        'pL',
                        'cZ'
                      ][i],
                      'name': 'Country $i'
                    })),
      ];

      when(mockDatabaseService.getUserByUid('testId'))
          .thenAnswer((_) async => mockUser);
      when(mockDatabaseService.getCompletedTrips('testId'))
          .thenAnswer((_) async => mockTrips);

      await pumpTestableWidget(tester, mockUser.username!, mockUser.id!);
      await tester.pumpAndSettle();

      isAchievedIcon(Widget widget) =>
          widget is Icon &&
          widget.icon == Icons.emoji_events &&
          widget.color == Colors.white;

      //1 medal under 'Mondo'
      final worldCard = find.ancestor(
        of: find.text('Mondo'),
        matching: find.byType(Card),
      );

      //two medal under 'Europa'
      final europaCard = find.ancestor(
        of: find.text('Europa'),
        matching: find.byType(Card),
      );

      expect(
        find.descendant(
          of: worldCard,
          matching: find.byWidgetPredicate(isAchievedIcon),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: europaCard,
          matching: find.byWidgetPredicate(isAchievedIcon),
        ),
        findsNWidgets(2),
      );
      expect(find.text('15'), findsOneWidget); // total countries
    });
  });
}
