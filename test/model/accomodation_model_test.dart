import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/accommodationModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  group('AccommodationModel test', () {
    test('fromFirestore should convert snapshot to model correctly', () {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockData = {
        'name': 'Hotel Milano',
        'tripId': 'trip001',
        'type': 'accommodation',
        'address': 'Via Roma 1, Milano',
        'checkIn': Timestamp.fromDate(DateTime(2024, 7, 10)),
        'checkOut': Timestamp.fromDate(DateTime(2024, 7, 15)),
        'expenses': 550,
        'contacts': {
          'phone': '+3902123456',
        },
      };

      when(mockSnapshot.id).thenReturn('acc123');
      when(mockSnapshot.data()).thenReturn(mockData);

      final accommodation = AccommodationModel.fromFirestore(mockSnapshot, null);

      expect(accommodation.id, 'acc123');
      expect(accommodation.name, 'Hotel Milano');
      expect(accommodation.tripId, 'trip001');
      expect(accommodation.type, 'accommodation');
      expect(accommodation.address, 'Via Roma 1, Milano');
      expect(accommodation.checkIn, DateTime(2024, 7, 10));
      expect(accommodation.checkOut, DateTime(2024, 7, 15));
      expect(accommodation.expenses, 550);
      expect(accommodation.contacts?['phone'], '+3902123456');
      expect(accommodation.contacts?.containsKey('email'), isFalse);
    });

    test('toFirestore should convert model to Firestore map correctly', () {
      final model = AccommodationModel(
        id: 'acc123',
        name: 'Hotel Milano',
        tripId: 'trip001',
        type: 'accommodation',
        address: 'Via Roma 1, Milano',
        checkIn: DateTime(2024, 7, 10),
        checkOut: DateTime(2024, 7, 15),
        expenses: 550,
        contacts: {
          'phone': '+3902123456',
          'email': 'info@hotelmilano.com',
        },
      );

      final firestoreMap = model.toFirestore();

      expect(firestoreMap['id'], 'acc123');
      expect(firestoreMap['name'], 'Hotel Milano');
      expect(firestoreMap['tripId'], 'trip001');
      expect(firestoreMap['type'], 'accommodation');
      expect(firestoreMap['address'], 'Via Roma 1, Milano');
      expect(firestoreMap['checkIn'], Timestamp.fromDate(DateTime(2024, 7, 10)));
      expect(firestoreMap['checkOut'], Timestamp.fromDate(DateTime(2024, 7, 15)));
      expect(firestoreMap['expenses'], 550);
      expect(firestoreMap['contacts']['phone'], '+3902123456');
      expect(firestoreMap['contacts']['email'], 'info@hotelmilano.com');
    });
  });
}
