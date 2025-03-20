import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/models/userModel.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({required String email, required String password}) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<void> createUserWithEmailAndPassword({required String name,
    required String surname,
    required String email,
    required String password,
    required String username,
    required DateTime? birthDate,
    required String nationality}) async{
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await DatabaseService().initializeUserData(UserModel(
        id: currentUser!.uid ?? 'null',
        name: name,
        surname: surname,
        username: username,
        profilePic: null,
        birthDate: birthDate,
        mail: email,
        birthCountry: nationality,
        description: null,
        createdTrip: null,
        savedTrip: null,
        visitedCountry: null,
        joinDate: DateTime.now(),
      ));
    } on Exception catch (e){
      rethrow;
    }
  }

  Future<void> updateUserWithEmailAndPassword({required String? name,
    required String? surname,
    required String? email,
    required String? username,
    required String? description,
    required DateTime? birthDate,
    required String? nationality}) async{
    try{
      final updatedFields = <String, dynamic>{};
      if(name != null) {updatedFields['name'] = name;}
      if (surname != null) updatedFields['surname'] = surname;
      if (username != null) updatedFields['username'] = username;
      if (birthDate != null) updatedFields['birthDate'] = birthDate;
      if (email != null) updatedFields['mail'] = email;
      if (nationality != null) updatedFields['birthCountry'] = nationality;
      if (description != null) updatedFields['description'] = description;
      await DatabaseService().updateUserData(UserModel(
        id: currentUser!.uid ?? 'null',
        name: name,
        surname: surname,
        username: username,
        birthDate: birthDate,
        mail: email,
        birthCountry: nationality,
        description: description,
      ));
    } on Exception catch (e){
      rethrow;
    }
  }

  Future<void> signOut() async{
    try{
      await _firebaseAuth.signOut();
    } on Exception catch (e){
      rethrow;
    }
  }
}