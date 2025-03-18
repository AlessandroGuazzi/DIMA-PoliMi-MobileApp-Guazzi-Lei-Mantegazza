import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';

import 'authService.dart';

class DatabaseService {
  final db = FirebaseFirestore.instance;
  final String? currentUserId = AuthService().currentUser?.uid;

  //reference to the 'Trips' collection of document in the db
  final tripCollection = FirebaseFirestore.instance
      .collection('Trips')
      .withConverter(
      fromFirestore: TripModel.fromFirestore,
      toFirestore: (TripModel trip, _) => trip.toFirestore()
  );





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