import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/trip_widgets/tripExpensesWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../mocks.mocks.dart';

void main() {
  group('TripExpensesWidget Tests', () {
    late MockDatabaseService mockDatabaseService;
    late MockCurrencyService mockCurrencyService;
    late TripModel testTrip;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCurrencyService = MockCurrencyService();

      testTrip = TripModel(
        id: 'test-trip-id',
        nations: [
          {'name': 'Italy', 'code': 'IT'},
          {'name': 'United States', 'code': 'US'},
        ],
        expenses: {
          'flight': 500.0,
          'accommodation': 300.0,
          'attraction': 150.0,
          'transport': 100.0,
        },
      );

      when(mockDatabaseService.loadTrip('test-trip-id'))
          .thenAnswer((_) async => testTrip);
    });

    Future<void> pumpTestableWidget(
        WidgetTester tester, {
          required String tripId,
        }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripExpensesWidget(
              tripId: tripId,
              databaseService: mockDatabaseService,
              currencyService: mockCurrencyService,
            ),
          ),
        ),
      );
    }

    testWidgets('shows loading indicator while data loads', (tester) async {
      when(mockDatabaseService.loadTrip('test-trip-id')).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return testTrip;
      });

      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('shows "Viaggio non trovato" when trip is null', (tester) async {
      when(mockDatabaseService.loadTrip('test-trip-id'))
          .thenAnswer((_) async => null);

      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      await tester.pumpAndSettle();

      expect(find.text('Viaggio non trovato'), findsOneWidget);
    });

    testWidgets('displays expense data correctly', (tester) async {
      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      await tester.pumpAndSettle();

      expect(find.text('Le tue spese'), findsOneWidget);
      expect(find.text('Panoramica delle spese'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);

      expect(find.textContaining('1.050 EUR'), findsOneWidget);

      expect(find.textContaining('500 EUR'), findsOneWidget);
      expect(find.textContaining('300 EUR'), findsOneWidget);
      expect(find.textContaining('150 EUR'), findsOneWidget);
      expect(find.textContaining('100 EUR'), findsOneWidget);

      expect(find.text('Voli'), findsOneWidget);
      expect(find.text('Alloggio'), findsOneWidget);
      expect(find.text('Attrazioni'), findsOneWidget);
      expect(find.text('Trasporti'), findsOneWidget);
    });

    testWidgets('handles null expenses ', (tester) async {
      final tripWithMissing = TripModel(
        id: 'test-trip-id',
        nations: [{'name': 'Italy', 'code': 'IT'}],
        expenses: null,
      );
      when(mockDatabaseService.loadTrip('test-trip-id'))
          .thenAnswer((_) async => tripWithMissing);

      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      await tester.pumpAndSettle();

      expect(find.textContaining('0 EUR'), findsNWidgets(5));
    });

    testWidgets('shows a currency dropdown', (tester) async {
      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('calculates percentages correctly', (tester) async {
      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      await tester.pumpAndSettle();

      // 500/1050 ≈ 48%
      expect(find.textContaining('(48%)'), findsOneWidget);
      // 300/1050 ≈ 29%
      expect(find.textContaining('(29%)'), findsOneWidget);
      // 150/1050 ≈ 14%
      expect(find.textContaining('(14%)'), findsOneWidget);
      // 100/1050 ≈ 10%
      expect(find.textContaining('(10%)'), findsOneWidget);
    });

    testWidgets('renders large expenses with correctly formatted sum', (tester) async {
      final hugeTrip = TripModel(
        id: 'test-trip-id',
        nations: [{'name': 'Italy', 'code': 'IT'}],
        expenses: {
          'flight': 999999.99,
          'accommodation': 888888.88,
          'attraction': 777777.77,
          'transport': 666666.66,
        },
      );

      when(mockDatabaseService.loadTrip('test-trip-id'))
          .thenAnswer((_) async => hugeTrip);

      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      await tester.pumpAndSettle();

      final decimalFormat = NumberFormat.decimalPattern('it')
        ..maximumFractionDigits = 0;

      expect(find.textContaining('${decimalFormat.format(999999.99)} EUR'), findsOneWidget);
      expect(find.textContaining('${decimalFormat.format(888888.88)} EUR'), findsOneWidget);
      expect(find.textContaining('${decimalFormat.format(777777.77)} EUR'), findsOneWidget);
      expect(find.textContaining('${decimalFormat.format(666666.66)} EUR'), findsOneWidget);

      //total > 1M use compact format
      final compactFormat = NumberFormat.compact(locale: 'it');
      const total = 999999.99 + 888888.88 + 777777.77 + 666666.66;
      expect(find.textContaining('${compactFormat.format(total)} EUR'), findsOneWidget);
    });

    testWidgets('renders expenses >= 1M with compact format', (tester) async {
      final massiveTrip = TripModel(
        id: 'test-trip-id',
        nations: [{'name': 'Italy', 'code': 'IT'}],
        expenses: {
          'flight': 1500000.0,
          'accommodation': 2000000.0,
          'attraction': 500000.0,
          'transport': 3000000.0,
        },
      );

      when(mockDatabaseService.loadTrip('test-trip-id'))
          .thenAnswer((_) async => massiveTrip);

      await pumpTestableWidget(tester, tripId: 'test-trip-id');
      await tester.pumpAndSettle();

      final compactFormat = NumberFormat.compact(locale: 'it');
      final decimalFormat = NumberFormat.decimalPattern('it')
        ..maximumFractionDigits = 0;

      // >= 1M values use compact format
      expect(find.textContaining('${compactFormat.format(1500000.0)} EUR'), findsOneWidget);
      expect(find.textContaining('${compactFormat.format(2000000.0)} EUR'), findsOneWidget);
      expect(find.textContaining('${compactFormat.format(3000000.0)} EUR'), findsOneWidget);

      // < 1M values use decimal format
      expect(find.textContaining('${decimalFormat.format(500000.0)} EUR'), findsOneWidget);

      const total = 1500000.0 + 2000000.0 + 500000.0 + 3000000.0;
      expect(find.textContaining('${compactFormat.format(total)} EUR'), findsOneWidget);
    });

    group('Currency Conversion Tests', () {
      testWidgets('converts to USD with proper formatting', (tester) async {
        when(mockCurrencyService.getExchangeRate('EUR', 'USD'))
            .thenAnswer((_) async => 2);

        await pumpTestableWidget(tester, tripId: 'test-trip-id');
        await tester.pumpAndSettle();

        // open dropdown and pick USD
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('\$'));
        await tester.pumpAndSettle();

        // All converted values are < 1M, so they use decimal format with no fractions
        expect(find.textContaining('1.000 USD'), findsOneWidget);
        expect(find.textContaining('600 USD'), findsOneWidget);
        expect(find.textContaining('300 USD'), findsOneWidget);
        expect(find.textContaining('200 USD'), findsOneWidget);

        // Total: 2100
        expect(find.textContaining('2.100 USD'), findsOneWidget);
      });

      testWidgets('toggles back and forth between EUR and USD', (tester) async {
        when(mockCurrencyService.getExchangeRate('EUR', 'USD'))
            .thenAnswer((_) async => 2);

        await pumpTestableWidget(tester, tripId: 'test-trip-id');
        await tester.pumpAndSettle();

        // initially EUR
        expect(find.textContaining('1.050 EUR'), findsOneWidget);

        // switch to USD
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('\$'));
        await tester.pumpAndSettle();
        expect(find.textContaining('1.050 EUR'), findsNothing);
        expect(find.textContaining('2.100 USD'), findsOneWidget);

        // switch back to EUR
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('€'));
        await tester.pumpAndSettle();
        expect(find.textContaining('1.050 EUR'), findsOneWidget);
        expect(find.textContaining('2.100 USD'), findsNothing);
      });
    });
  });
}
