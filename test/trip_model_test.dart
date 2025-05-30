import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'trip_model_test.mocks.dart';

@GenerateMocks([DocumentSnapshot])
void main() {
  group("Trip model testing", () {
    test("fromFirestore method should convert Firestore snapshot to model", () {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockData = {
        'creatorInfo': {'name': 'Alice'},
        'title': 'Trip to Rome',
        'nations': [
          {'name': 'Italy', 'flag': '🇮🇹', 'code': 'IT'},
        ],
        'cities': [
          {'name': 'Rome', 'place_id': 'abc123', 'lat': 41.9, 'lng': 12.5},
        ],
        'startDate': Timestamp.fromDate(DateTime(2024, 6, 1)),
        'endDate': Timestamp.fromDate(DateTime(2024, 6, 15)),
        'activities': ['Museum'],
        'expenses': {
          'flight': 200,
          'accommodation': 400,
          'attraction': 100,
          'transport': 50,
        },
        'isConfirmed': true,
        'isPast': false,
        'isPrivate': false,
        'saveCounter': 1,
        'timestamp': Timestamp.fromDate(DateTime(2024, 5, 1)),
        'imageRef': 'img/path.jpg',
      };
      //insert mockData into the mockSnapshot
      when(mockSnapshot.id).thenReturn('mockId');
      when(mockSnapshot.data()).thenReturn(mockData);

      final tripModel = TripModel.fromFirestore(mockSnapshot, null);

      //Assert only a few fields
      expect(tripModel.id, 'mockId');
      expect(tripModel.creatorInfo, {'name': 'Alice'});
      expect(tripModel.title, 'Trip to Rome');

    });
    test("toFirestore method should convert model to Firestore map", () {
      final trip = TripModel(
        id: 'trip123',
        creatorInfo: {'name': 'Alice'},
        title: 'Trip to Italy',
        nations: [
          {'name': 'Italy', 'flag': '🇮🇹', 'code': 'IT'},
        ],
        cities: [
          {'name': 'Rome', 'place_id': 'abc123', 'lat': 41.9, 'lng': 12.5},
        ],
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
        activities: ['Beach', 'Museum'],
        expenses: {
          'flight': 300,
          'accommodation': 500,
          'attraction': 200,
          'transport': 50,
        },
        isConfirmed: true,
        isPast: false,
        isPrivate: true,
        saveCounter: 5,
        timestamp: Timestamp.fromDate(DateTime(2024, 5, 1)),
        imageRef: 'img/rome.jpg',
      );

      final firestoreMap = trip.toFirestore();

      expect(firestoreMap['id'], 'trip123');
      expect(firestoreMap['creatorInfo']['name'], 'Alice');
      expect(firestoreMap['title'], 'Trip to Italy');
      expect(firestoreMap['nations'][0]['code'], 'IT');
      expect(firestoreMap['cities'][0]['lat'], 41.9);
      expect(firestoreMap['startDate'], Timestamp.fromDate(DateTime(2024, 6, 1)));
      expect(firestoreMap['endDate'], Timestamp.fromDate(DateTime(2024, 6, 10)));
      expect(firestoreMap['expenses']['accommodation'], 500);
      expect(firestoreMap['isConfirmed'], true);
      expect(firestoreMap['saveCounter'], 5);
      expect(firestoreMap['imageRef'], 'img/rome.jpg');
    });
  });
}