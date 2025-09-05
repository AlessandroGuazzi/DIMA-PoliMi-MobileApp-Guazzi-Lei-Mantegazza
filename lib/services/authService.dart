import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/models/userModel.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<void> createUserWithEmailAndPassword(
      {required String name,
      required String surname,
      required String email,
      required String password,
      required String username,
      required DateTime? birthDate,
      required String nationality}) async {
    //generates a random number between 0 and 5
    final random = Random().nextInt(6);
    final path = 'assets/avatars/avatar_$random.png';
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await DatabaseService().initializeUserData(UserModel(
        id: currentUser!.uid ?? 'null',
        name: name,
        surname: surname,
        username: username,
        profilePic: path,
        birthDate: birthDate,
        mail: email,
        birthCountry: nationality,
        description: null,
        createdTrip: null,
        savedTrip: null,
        visitedCountry: null,
        joinDate: DateTime.now(),
      ));
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserWithEmailAndPassword({
    required String? name,
    required String? surname,
    required String? username,
    required String? description,
    required DateTime? birthDate,
    required String? profilePic,
  }) async {
    try {
      final updatedFields = <String, dynamic>{};
      if (name != null) updatedFields['name'] = name;
      if (surname != null) updatedFields['surname'] = surname;
      if (username != null) updatedFields['username'] = username;
      if (birthDate != null) updatedFields['birthDate'] = birthDate;
      if (description != null) updatedFields['description'] = description;
      if (profilePic != null) updatedFields['profilePic'] = profilePic;
      await DatabaseService().updateUserData(UserModel(
        id: currentUser?.uid ?? 'null',
        name: name,
        surname: surname,
        username: username,
        birthDate: birthDate,
        description: description,
        profilePic: profilePic,
      ));
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on Exception catch (e) {
      rethrow;
    }
  }
}
