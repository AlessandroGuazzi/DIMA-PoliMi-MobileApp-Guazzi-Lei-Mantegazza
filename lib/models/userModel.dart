import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? surname;
  final String? username;
  final String? profilePic;
  final DateTime? birthDate;
  final String? mail;
  final String? birthCountry;
  final String? description;
  final List<String>? createdTrip;
  final List<String>? savedTrip;
  final List<String>? visitedCountry;
  final DateTime? joinDate;

  // Constructor
  UserModel({
    this.id,
    this.name,
    this.surname,
    this.username,
    this.profilePic,
    this.birthDate,
    this.mail,
    this.birthCountry,
    this.description,
    this.createdTrip,
    this.savedTrip,
    this.visitedCountry,
    this.joinDate,
  });

  // Factory method to create a UserModel instance from Firestore
  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    Timestamp? birthDate = data?['birthDate'];
    Timestamp? joinDate = data?['joinDate'];

    return UserModel(
      id: data?['id'],
      name: data?['name'],
      surname: data?['surname'],
      username: data?['username'],
      profilePic: data?['profilePic'],
      birthDate: birthDate?.toDate(),
      mail: data?['mail'],
      birthCountry: data?['birthCountry'],
      description: data?['description'],
      createdTrip: data?['createdTrip'] is Iterable
          ? List<String>.from(data?['createdTrip'])
          : null,
      savedTrip: data?['savedTrip'] is Iterable
          ? List<String>.from(data?['savedTrip'])
          : null,
      visitedCountry: data?['visitedCountry'] is Iterable
          ? List<String>.from(data?['visitedCountry'])
          : null,
      joinDate: joinDate?.toDate(),
    );
  }

  // Method to convert a UserModel instance to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (username != null) 'username': username,
      if (profilePic != null) 'profilePic': profilePic,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
      if (mail != null) 'mail': mail,
      if (birthCountry != null) 'birthCountry': birthCountry,
      if (description != null) 'description': description,
      if (createdTrip != null) 'createdTrip': createdTrip,
      if (savedTrip != null) 'savedTrip': savedTrip,
      if (visitedCountry != null) 'visitedCountry': visitedCountry,
      if (joinDate != null) 'joinDate': Timestamp.fromDate(joinDate!),
    };
  }
}
