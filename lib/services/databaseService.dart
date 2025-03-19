import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authService.dart';

class DatabaseService {
  final db = FirebaseFirestore.instance;
  final String? currentUserId = AuthService().currentUser?.uid;

  final userCollection = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
      fromFirestore: UserModel.fromFirestore,
      toFirestore: (UserModel user, _) => user.toFirestore()
  );

  //reference to the 'Trips' collection of document in the db
  final tripCollection = FirebaseFirestore.instance
      .collection('Trips')
      .withConverter(
      fromFirestore: TripModel.fromFirestore,
      toFirestore: (TripModel trip, _) => trip.toFirestore()
  );


  Future initializeUserData(UserModel user) async {
    return await userCollection.doc(currentUserId).set(user);
  }

  Future<UserModel?> getUserByUid(String uid) async {
    try {
      DocumentSnapshot<UserModel> doc = await userCollection.doc(uid).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Errore recupero utente: $e');
      return null;
    }
  }


  //Method for retrieval of all  'Trips' documents that are not created by the current user
  Future<List<TripModel>> getExplorerTrips() async {
    List<TripModel> trips = [];

    try {
      QuerySnapshot<TripModel> querySnapshot = await tripCollection
          .where("creatorInfo.id", isNotEqualTo: currentUserId)
          .get();

      print("Successfully completed");

      for (var docSnapshot in querySnapshot.docs) {
        trips.add(docSnapshot.data());
      }
    } catch (e) {
      print("Error completing: $e");
    }

    return trips;
  }


  //Method for retrieval of all  'Trips' documents that are created by the current user
  Future<List<TripModel>> getHomePageTrips() async {
    List<TripModel> trips = [];

    try {
      QuerySnapshot<TripModel> querySnapshot = await tripCollection
          .where("creatorInfo.id", isEqualTo: currentUserId)
          .get();

      print("Successfully completed");

      for (var docSnapshot in querySnapshot.docs) {
        trips.add(docSnapshot.data());
      }
    } catch (e) {
      print("Error completing: $e");
    }

    return trips;
  }


  Future<void> createTrip(TripModel trip) async{
    try {
      await db.collection('Trips').add(trip.toFirestore());
      print('Successfully added a new trip!');

    } catch (e) {
      print("Error completing: $e");
    }
  }



}