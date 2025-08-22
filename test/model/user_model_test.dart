import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart'; // MockDocumentSnapshot<Map<String, dynamic>>

void main() {
  group("UserModel test", () {
    test("fromFirestore should correctly deserialize data", () {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockData = {
        'id': 'user001',
        'name': 'Mario',
        'surname': 'Rossi',
        'username': 'mrossi',
        'profilePic': 'https://example.com/profile.jpg',
        'birthDate': Timestamp.fromDate(DateTime(1990, 5, 15)),
        'mail': 'mario.rossi@example.com',
        'birthCountry': 'Italy',
        'description': 'Travel enthusiast',
        'createdTrip': ['trip1', 'trip2'],
        'savedTrip': ['trip3'],
        'visitedCountry': ['Italy', 'France'],
        'joinDate': Timestamp.fromDate(DateTime(2024, 1, 1)),
      };

      when(mockSnapshot.data()).thenReturn(mockData);

      final model = UserModel.fromFirestore(mockSnapshot, null);

      expect(model.id, 'user001');
      expect(model.name, 'Mario');
      expect(model.surname, 'Rossi');
      expect(model.username, 'mrossi');
      expect(model.profilePic, 'https://example.com/profile.jpg');
      expect(model.birthDate, DateTime(1990, 5, 15));
      expect(model.mail, 'mario.rossi@example.com');
      expect(model.birthCountry, 'Italy');
      expect(model.description, 'Travel enthusiast');
      expect(model.createdTrip, ['trip1', 'trip2']);
      expect(model.savedTrip, ['trip3']);
      expect(model.visitedCountry, ['Italy', 'France']);
      expect(model.joinDate, DateTime(2024, 1, 1));
    });

    test("toFirestore should correctly serialize data", () {
      final model = UserModel(
        id: 'user001',
        name: 'Mario',
        surname: 'Rossi',
        username: 'mrossi',
        profilePic: 'https://example.com/profile.jpg',
        birthDate: DateTime(1990, 5, 15),
        mail: 'mario.rossi@example.com',
        birthCountry: 'Italy',
        description: 'Travel enthusiast',
        createdTrip: ['trip1', 'trip2'],
        savedTrip: ['trip3'],
        visitedCountry: ['Italy', 'France'],
        joinDate: DateTime(2024, 1, 1),
      );

      final map = model.toFirestore();

      expect(map['id'], 'user001');
      expect(map['name'], 'Mario');
      expect(map['surname'], 'Rossi');
      expect(map['username'], 'mrossi');
      expect(map['profilePic'], 'https://example.com/profile.jpg');
      expect(map['birthDate'], Timestamp.fromDate(DateTime(1990, 5, 15)));
      expect(map['mail'], 'mario.rossi@example.com');
      expect(map['birthCountry'], 'Italy');
      expect(map['description'], 'Travel enthusiast');
      expect(map['createdTrip'], ['trip1', 'trip2']);
      expect(map['savedTrip'], ['trip3']);
      expect(map['visitedCountry'], ['Italy', 'France']);
      expect(map['joinDate'], Timestamp.fromDate(DateTime(2024, 1, 1)));
    });
  });
}
