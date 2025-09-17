import 'dart:typed_data';

import 'package:dima_project/models/airportModel.dart';
import 'package:dima_project/widgets/search_bottom_sheets/airportSearchWidget.dart'; // importa il tuo widget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show CachingAssetBundle, rootBundle;
import 'package:flutter/services.dart';


import 'dart:convert';

class TestAssetBundle extends CachingAssetBundle {
  final Map<String, String> fakeAssets;

  TestAssetBundle(this.fakeAssets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (fakeAssets.containsKey(key)) {
      return fakeAssets[key]!;
    }
    throw FlutterError('Asset "$key" non trovato nel TestAssetBundle.');
  }

  @override
  Future<ByteData> load(String key) async {
    final string = await loadString(key);
    final bytes = Uint8List.fromList(utf8.encode(string));
    return ByteData.view(bytes.buffer);
  }
}
void main() {
  testWidgets('AirportSearchWidget mostra e filtra aeroporti', (WidgetTester tester) async {
    const fakeJson = '''[
  { "name": "Rome Fiumicino", "iata": "FCO", "iso": "IT" },
  { "name": "Milan Malpensa", "iata": "MXP", "iso": "IT" },
  { "name": "Amsterdam Schiphol", "iata": "AMS", "iso": "NL" }
  ]''';

    final testBundle = TestAssetBundle({'assets/airports.json': fakeJson});
    Airport? selectedAirport;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AirportSearchWidget(
            onAirportSelected: (airport) => selectedAirport = airport,
            assetBundle: testBundle, // Passa direttamente il bundle
          ),
        ),
      ),
    );


    await tester.pumpAndSettle();

    // Test per l'icona flight_takeoff nel TextField
    expect(find.byIcon(Icons.flight_takeoff), findsOneWidget);
    expect(find.text('Cerca aeroporto'), findsOneWidget);

    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Rome Fiumicino'), findsOneWidget);
    expect(find.text('Milan Malpensa'), findsOneWidget);

    // Test filtro
    await tester.enterText(find.byType(TextField), 'Rome');
    await tester.pumpAndSettle();

    expect(find.text('Rome Fiumicino'), findsOneWidget);
    expect(find.text('Milan Malpensa'), findsNothing);
    expect(find.text('Amsterdam Schiphol'), findsNothing);

    // Test selezione
    await tester.tap(find.text('Rome Fiumicino'));
    await tester.pumpAndSettle();

    expect(selectedAirport?.iata, 'FCO');
  });

  testWidgets('Mostra Nessun risultato quando filtro non combacia', (WidgetTester tester) async {

    const fakeJson = '''[
  { "name": "Rome Fiumicino", "iata": "FCO", "iso": "IT" },
  { "name": "Milan Malpensa", "iata": "MXP", "iso": "IT" },
  { "name": "Amsterdam Schiphol", "iata": "AMS", "iso": "NL" }
  ]''';

    final testBundle = TestAssetBundle({'assets/airports.json': fakeJson});
    Airport? selectedAirport;
      await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AirportSearchWidget(
            onAirportSelected: (airport) => selectedAirport = airport,
            assetBundle: testBundle, // Passa direttamente il bundle
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.enterText(find.byType(TextField), 'Tokyo');
    await tester.pumpAndSettle();

    expect(find.text('Nessun risultato'), findsOneWidget);
  });
}