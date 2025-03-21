
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/accomodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'authService.dart';

class DatabaseService {
  final db = FirebaseFirestore.instance;
  final String? currentUserId = AuthService().currentUser?.uid;

  final userCollection = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel user, _) => user.toFirestore());

  //reference to the 'Trips' collection of document in the db
  final tripCollection = FirebaseFirestore.instance
      .collection('Trips')
      .withConverter(
          fromFirestore: TripModel.fromFirestore,
          toFirestore: (TripModel trip, _) => trip.toFirestore());

  final activityCollection = FirebaseFirestore.instance
      .collection('Activities')
      .withConverter(
          fromFirestore: ActivityModel.fromFirestore,
          toFirestore: (ActivityModel activity, _) => activity.toFirestore());

  //TODO CAPIRE SE SERVE USARLI
  //reference to the 'flights' in collection 'Activity' of document in the db
  final flightCollection = FirebaseFirestore.instance
      .collection('Activities')
      .where('type', isEqualTo: 'flight')
      .withConverter(
          fromFirestore: FlightModel.fromFirestore,
          toFirestore: (FlightModel flight, _) => flight.toFirestore());

  //reference to the 'other transports' in collection 'Activity' of document in the db
  final transportCollection = FirebaseFirestore.instance
      .collection('Activities')
      .where('type', isEqualTo: 'transport')
      .withConverter(
          fromFirestore: TransportModel.fromFirestore,
          toFirestore: (TransportModel transport, _) =>
              transport.toFirestore());

  //reference to the 'attractions' in collection 'Activity' of document in the db
  final attractionCollection = FirebaseFirestore.instance
      .collection('Activities')
      .where('type', isEqualTo: 'attraction') // Filtra per attrazioni
      .withConverter(
        fromFirestore: AttractionModel.fromFirestore,
        toFirestore: (AttractionModel attraction, _) =>
            attraction.toFirestore(),
      );

  //reference to the 'accomodation' in collection 'Activity' of document in the db
  final accommodationCollection = FirebaseFirestore.instance
      .collection('Activities')
      .where('type', isEqualTo: 'accommodation') // Filtra per alloggi
      .withConverter(
        fromFirestore: AccommodationModel.fromFirestore,
        toFirestore: (AccommodationModel accommodation, _) =>
            accommodation.toFirestore(),
      );

  Future initializeUserData(UserModel user) async {
    return await userCollection.doc(currentUserId).set(user);
  }

  Future updateUserData(UserModel user) async {
    return await userCollection.doc(user.id).update(user.toFirestore());
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

      print("Trip retrieval completed");

      for (var docSnapshot in querySnapshot.docs) {
        trips.add(docSnapshot.data());
      }
    } catch (e) {
      print("Error retrieving trip: $e");
    }

    return trips;
  }

  //Method for retrieval of all 'Trips' documents that are created by the current user
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

  Future<List<ActivityModel>> getTripActivities(TripModel trip) async {
    List<ActivityModel> activities = [];

    try {
      QuerySnapshot<ActivityModel> querySnapshot =
          await activityCollection.where("tripId", isEqualTo: trip.id).get();

      print("Successfully completed");

      for (var docSnapshot in querySnapshot.docs) {
        activities.add(docSnapshot.data());
      }
    } catch (e) {
      print("Error completing: $e");
    }

    return activities;
  }

  //updated method assign id to the trip and add it to the user that created it
  Future<void> createTrip(TripModel trip) async {
    //Do not use tripCollection directly for problem with transaction and withConverter
    DocumentReference tripDoc =
        FirebaseFirestore.instance.collection('Trips').doc();
    String tripId = tripDoc.id;
    trip.id = tripId;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        //insert trip in createdTrip for the user
        transaction.update(userCollection.doc(currentUserId), {
          'createdTrip': FieldValue.arrayUnion([tripId])
        });
        //add the actual trip document to db
        transaction.set(tripDoc, trip.toFirestore());
      });
    } on Exception catch (e) {
      print("Error creating a new trip: $e");
    }
  }

  //Handle logic to save/unsave a trip
  Future<void> handleTripSave(bool isSaved, String tripId) async {
    if (tripId != 'null') {
      try {
        await userCollection.doc(currentUserId).update({
          'savedTrip': isSaved
              ? FieldValue.arrayRemove([tripId])
              : FieldValue.arrayUnion([tripId])
        });
      } on Exception catch (e) {
        print('Error saving/unsaving trip: $e');
      }
    } else {
      return;
    }
  }
}
