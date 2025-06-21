import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/airportModel.dart';

void main() {
  group('Airport model', () {
    test('fromJson crea oggetto Airport correttamente', () {
      final json = {
        'iata': 'FCO',
        'name': 'Rome Fiumicino',
        'iso': 'IT',
      };

      final airport = Airport.fromJson(json);

      expect(airport.iata, 'FCO');
      expect(airport.name, 'Rome Fiumicino');
      expect(airport.iso, 'IT');
    });

    test('fromJson gestisce campi mancanti', () {
      final json = {
        'iata': null,
        'name': null,
        'iso': null,
      };

      final airport = Airport.fromJson(json);

      expect(airport.iata, '');
      expect(airport.name, '');
      expect(airport.iso, '');
    });
  });
}
