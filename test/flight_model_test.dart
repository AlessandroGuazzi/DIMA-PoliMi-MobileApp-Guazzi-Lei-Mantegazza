import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/flightModel.dart';

import 'mocks.mocks.dart'; // genera usando mockito: MockDocumentSnapshot

void main() {
  group("FlightModel Tests", () {
    test("fromFirestore should correctly parse Firestore snapshot", () {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockData = {
        'tripId': 'trip_123',
        'type': 'flight',
        'departureAirPort': {'name': 'Malpensa', 'iata': 'MXP'},
        'arrivalAirPort': {'name': 'Heathrow', 'iata': 'LHR'},
        'departureDate': Timestamp.fromDate(DateTime(2024, 7, 1, 8, 30)),
        'arrivalDate': Timestamp.fromDate(DateTime(2024, 7, 1, 10, 45)),
        'duration': 2.25,
        'expenses': 120.0,
      };
      //insert mockData into the mockSnapshot
      when(mockSnapshot.id).thenReturn('flight_001');
      when(mockSnapshot.data()).thenReturn(mockData);

      final model = FlightModel.fromFirestore(mockSnapshot, null);

      expect(model.id, 'flight_001');
      expect(model.tripId, 'trip_123');
      expect(model.type, 'flight');
      expect(model.departureAirPort?['name'], 'Malpensa');
      expect(model.arrivalAirPort?['iata'], 'LHR');
      expect(model.departureDate, DateTime(2024, 7, 1, 8, 30));
      expect(model.arrivalDate, DateTime(2024, 7, 1, 10, 45));
      expect(model.duration, 2.25);
      expect(model.expenses, 120.0);
    });

    test("toFirestore should correctly serialize model to Firestore map", () {
      final model = FlightModel(
        id: 'flight_001',
        tripId: 'trip_123',
        type: 'flight',
        expenses: 120.0,
        departureAirPort: {'name': 'Malpensa', 'iata': 'MXP'},
        arrivalAirPort: {'name': 'Heathrow', 'iata': 'LHR'},
        departureDate: DateTime(2024, 7, 1, 8, 30),
        arrivalDate: DateTime(2024, 7, 1, 10, 45),
        duration: 2.25,
      );

      final map = model.toFirestore();

      expect(map['id'], 'flight_001');
      expect(map['tripId'], 'trip_123');
      expect(map['type'], 'flight');
      expect(map['departureAirPort']['name'], 'Malpensa');
      expect(map['arrivalAirPort']['iata'], 'LHR');
      expect(map['departureDate'], Timestamp.fromDate(DateTime(2024, 7, 1, 8, 30)));
      expect(map['arrivalDate'], Timestamp.fromDate(DateTime(2024, 7, 1, 10, 45)));
      expect(map['duration'], 2.25);
      expect(map['expenses'], 120.0);
    });
  });
}
