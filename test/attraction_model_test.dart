import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart'; // genera usando mockito: MockDocumentSnapshot

void main() {
  group("AttractionModel test", () {
    test("fromFirestore should correctly deserialize data", () {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockData = {
        'tripId': 'trip456',
        'type': 'attraction',
        'name': 'Colosseo',
        'startDate': Timestamp.fromDate(DateTime(2025, 7, 1, 10, 0)),
        'endDate': Timestamp.fromDate(DateTime(2025, 7, 1, 12, 0)),
        'address': 'Piazza del Colosseo, Roma',
        'description': 'Visita guidata al Colosseo',
        'expenses': 25,
        'attractionType': 'monument',
      };

      when(mockSnapshot.id).thenReturn('attr001');
      when(mockSnapshot.data()).thenReturn(mockData);

      final model = AttractionModel.fromFirestore(mockSnapshot, null);

      expect(model.id, 'attr001');
      expect(model.tripId, 'trip456');
      expect(model.type, 'attraction');
      expect(model.name, 'Colosseo');
      expect(model.startDate, DateTime(2025, 7, 1, 10, 0));
      expect(model.endDate, DateTime(2025, 7, 1, 12, 0));
      expect(model.address, 'Piazza del Colosseo, Roma');
      expect(model.description, 'Visita guidata al Colosseo');
      expect(model.expenses, 25);
      expect(model.attractionType, 'monument');
    });

    test("toFirestore should correctly serialize data", () {
      final model = AttractionModel(
        id: 'attr001',
        tripId: 'trip456',
        type: 'attraction',
        name: 'Colosseo',
        startDate: DateTime(2025, 7, 1, 10, 0),
        endDate: DateTime(2025, 7, 1, 12, 0),
        address: 'Piazza del Colosseo, Roma',
        description: 'Visita guidata al Colosseo',
        expenses: 25,
        attractionType: 'monument',
      );

      final map = model.toFirestore();

      expect(map['id'], 'attr001');
      expect(map['tripId'], 'trip456');
      expect(map['type'], 'attraction');
      expect(map['name'], 'Colosseo');
      expect(map['startDate'], Timestamp.fromDate(DateTime(2025, 7, 1, 10, 0)));
      expect(map['endDate'], Timestamp.fromDate(DateTime(2025, 7, 1, 12, 0)));
      expect(map['address'], 'Piazza del Colosseo, Roma');
      expect(map['description'], 'Visita guidata al Colosseo');
      expect(map['expenses'], 25);
      expect(map['attractionType'], 'monument');
    });
  });
}
