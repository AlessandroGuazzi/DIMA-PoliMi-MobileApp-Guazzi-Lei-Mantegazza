import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  group("TransportModel test", () {
    test("fromFirestore should correctly deserialize data", () {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockData = {
        'tripId': 'trip789',
        'type': 'transport',
        'departureDate': Timestamp.fromDate(DateTime(2025, 8, 20, 14, 30)),
        'departurePlace': 'Florence',
        'arrivalPlace': 'Venice',
        'duration': 3.5,
        'expenses': 45,
        'transportType': 'train',
      };

      when(mockSnapshot.id).thenReturn('transport001');
      when(mockSnapshot.data()).thenReturn(mockData);

      final model = TransportModel.fromFirestore(mockSnapshot, null);

      expect(model.id, 'transport001');
      expect(model.tripId, 'trip789');
      expect(model.type, 'transport');
      expect(model.departureDate, DateTime(2025, 8, 20, 14, 30));
      expect(model.departurePlace, 'Florence');
      expect(model.arrivalPlace, 'Venice');
      expect(model.duration, 3.5);
      expect(model.expenses, 45);
      expect(model.transportType, 'train');
    });

    test("toFirestore should correctly serialize data", () {
      final model = TransportModel(
        id: 'transport001',
        tripId: 'trip789',
        type: 'transport',
        departureDate: DateTime(2025, 8, 20, 14, 30),
        departurePlace: 'Florence',
        arrivalPlace: 'Venice',
        duration: 3.5,
        expenses: 45,
        transportType: 'train',
      );

      final map = model.toFirestore();

      expect(map['id'], 'transport001');
      expect(map['tripId'], 'trip789');
      expect(map['type'], 'transport');
      expect(map['departureDate'], Timestamp.fromDate(DateTime(2025, 8, 20, 14, 30)));
      expect(map['departurePlace'], 'Florence');
      expect(map['arrivalPlace'], 'Venice');
      expect(map['duration'], 3.5);
      expect(map['expenses'], 45);
      expect(map['transportType'], 'train');
    });
  });
}
