import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  //Method for retrieval of all  'Trips' documents that are not created by the current user and isPrivate=false
  Future<List<TripModel>> getExplorerTrips() async {
    List<TripModel> trips = [];

    try {
      QuerySnapshot<TripModel> querySnapshot = await tripCollection
          .where("creatorInfo.id", isNotEqualTo: currentUserId)
          .where("isPrivate", isEqualTo: false)
          .get();

      debugPrint("Trip retrieval completed");

      for (var docSnapshot in querySnapshot.docs) {
        TripModel trip = docSnapshot.data();

        //fetch the user
        final userId = trip.creatorInfo?['id'];
        if (userId != null) {
          final userDoc = await userCollection.doc(userId).get();
          final userData = userDoc.data();
          //assign new data
          if (userData != null && trip.creatorInfo != null) {
            trip.creatorInfo!['username'] = userData.username ?? 'Unknown';
            trip.creatorInfo!['profilePic'] = userData.profilePic ?? 'assets/profile.png';
          }
        }
        trips.add(trip);
      }

    } catch (e) {
      debugPrint("Error retrieving trip: $e");
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
      return Future.error(e);
    }

    return trips;
  }

  //Method for retrieval of all 'Trips' documents that are created by the user in input, with choice on the privacy
  Future<List<TripModel>> getTripsOfUserWithPrivacy(String userId, bool publicOnly) async {
    List<TripModel> trips = [];

    try {

      QuerySnapshot<TripModel> querySnapshot;
      if(publicOnly) {
        querySnapshot = await tripCollection
            .where("creatorInfo.id", isEqualTo: userId)
            .where("isPrivate", isEqualTo: false)
            .get();
      } else {
        querySnapshot = await tripCollection
            .where("creatorInfo.id", isEqualTo: userId)
            .get();
      }

      if (kDebugMode) {
        print("Successfully completed");
      }

      for (var docSnapshot in querySnapshot.docs) {
        trips.add(docSnapshot.data());
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error completing: $e");
      }
      return Future.error(e);
    }

    return trips;
  }

  Future<List<TripModel>> getCompletedTrips([String userId = "defaultUserId"]) async {
    List<TripModel> trips = [];

    try {
      QuerySnapshot<TripModel> querySnapshot;
      if(userId == "defaultUserId") {
        querySnapshot = await tripCollection
            .where("creatorInfo.id", isEqualTo: currentUserId)
            .where("endDate", isLessThan: Timestamp.now())
            .get();
      } else {
        querySnapshot = await tripCollection
            .where("creatorInfo.id", isEqualTo: userId)
            .where("endDate", isLessThan: Timestamp.now())
            .get();
      }

      print("Successfully completed");

      for (var docSnapshot in querySnapshot.docs) {
        trips.add(docSnapshot.data());
      }
    } catch (e) {
      print("Error completing: $e");
    }

    return trips;
  }

  //method for updating a trip details
  Future updateTrip(TripModel trip) async {
    return await tripCollection.doc(trip.id).update(trip.toFirestore());
  }

  Stream<List<ActivityModel>> streamTripActivities(TripModel trip) {
    return activityCollection
        .where("tripId", isEqualTo: trip.id)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) => docSnapshot.data()).toList();
    });
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

  Future<void> handleTripSave(bool isCurrentlySaved, String tripId) async {

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    if (tripId.isNotEmpty) {
      final userDocRef = userCollection.doc(currentUserId);
      final tripDocRef = tripCollection.doc(tripId);

      try {
        await db.runTransaction((transaction) async {
          // Get the current trip document to check its saveCounter
          DocumentSnapshot tripSnapshot = await transaction.get(tripDocRef);

          if (!tripSnapshot.exists) {
            throw Exception("Trip with ID $tripId not found.");
          }

          final currentSaveCounter = (tripSnapshot.data() as Map<String, dynamic>?)?['saveCounter'] as num? ?? 0;

          //Increment/decrement counter
          if (isCurrentlySaved) {
            //Trying to unsave
            if (currentSaveCounter > 0) {
              transaction.update(tripDocRef, {
                'saveCounter': FieldValue.increment(-1)
              });
            } else {
             //unexpected case -> set it back to 0
              transaction.update(tripDocRef, {'saveCounter': 0});
            }
          } else {
            //Trying to save
            transaction.update(tripDocRef, {
              'saveCounter': FieldValue.increment(1)
            });
          }
          //2nd transaction
          //Update user saved trips list
          transaction.update(userDocRef, {
            'savedTrip': isCurrentlySaved
                ? FieldValue.arrayRemove([tripId])
                : FieldValue.arrayUnion([tripId])
          });
        });
      } on FirebaseException catch (e) {
        rethrow;
      } on Exception catch (e) {
        rethrow;
      }
    } else {
      throw Exception("Invalid tripId");
    }
  }

  Future<void> createActivity(ActivityModel activity) async {
    try {
      await db.collection('Activities').add(activity.toFirestore());
      updateTripCost(activity.tripId!, activity.expenses ?? 0.0, true, activity.type!);
      print('Successfully added a new ${activity.runtimeType}!');
    } on Exception catch (e) {
      print("Error creating activity: $e");
    }
  }

  Future<void> deleteActivity(ActivityModel activity) async {
    try {
      await db.collection('Activities').doc(activity.id).delete();
      updateTripCost(activity.tripId!, activity.expenses ?? 0.0, false, activity.type!);
      print('Successfully deleted activity with ID: ${activity.id}');
    } on Exception catch (e) {
      print('Error deleting activity: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await db.runTransaction((transaction) async {
        final tripRef = db.collection('Trips').doc(tripId);
        final userRef = userCollection.doc(currentUserId);

        final tripSnapshot = await transaction.get(tripRef);

        if (!tripSnapshot.exists) {
          throw Exception("Trip not found");
        }

        // if user created the trip
        final userSnapshot = await transaction.get(userRef);
        final createdTrips = List<String>.from(userSnapshot['createdTrip'] ?? []);
        if (!createdTrips.contains(tripId)) {
          throw Exception("User does not own this trip");
        }

        // Delete activities linked to this trip
        final activitiesSnapshot = await db
            .collection('Activities')
            .where('tripId', isEqualTo: tripId)
            .get();
        for (var doc in activitiesSnapshot.docs) {
          transaction.delete(doc.reference);
        }

        // Delete the trip
        transaction.delete(tripRef);

        // Update user doc
        transaction.update(userRef, {
          'createdTrip': FieldValue.arrayRemove([tripId]),
        });
      });

    } on FirebaseException catch (e) {
      print('Firebase error deleting trip: ${e.message}');
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  Future<void> updateTripCost(String tripId, num cost, bool isAdd, String type) async {
    final tripRef = FirebaseFirestore.instance.collection('Trips').doc(tripId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(tripRef);

        if (!snapshot.exists) {
          throw Exception("Trip with id $tripId does not exist");
        }

        final data = snapshot.data();
        final expenses = (data?['expenses'] as Map<String, dynamic>?);

        // Valore attuale o default a 0
        final currentCost = (expenses != null && expenses[type] != null)
            ? expenses[type] as num
            : 0;

        final updatedCost = isAdd ? currentCost + cost : currentCost - cost;

        if (expenses == null) {
          transaction.update(tripRef, {
            'expenses': {type: updatedCost},
          });
        } else {
          transaction.update(tripRef, {
            'expenses.$type': updatedCost,
          });
        }
      });
    } catch (e) {
      print("Errore durante l'update del costo del trip: $e");
      rethrow;
    }
  }

  Future<TripModel?> loadTrip(String tripId) async {
    try {
      final docSnapshot = await tripCollection.doc(tripId).get();

      final TripModel? trip = docSnapshot.data();

      return trip;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading trip with ID $tripId: $e');
      }
      return null;
    }
  }

  Future<void> updateActivity(String id, ActivityModel activity, num cost, bool isAdd) async {
    final docRef = activityCollection.doc(id);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.update(activity.toFirestore());
    } else {
      throw Exception("Documento non trovato con ID: ${activity.id}");
    }
    updateTripCost(activity.tripId!, cost, isAdd, activity.type!);
  }

  Future<List<TripModel>> getTripsByIds(List<String>? tripIds) async {
    List<TripModel> trips = [];

    if (tripIds == null || tripIds.isEmpty) return trips;

    try {
      // Firestore limita whereIn a massimo 10 elementi per query
      for (int i = 0; i < tripIds.length; i += 10) {
        final chunk = tripIds.skip(i).take(10).toList();

        QuerySnapshot<TripModel> querySnapshot = await tripCollection
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (var docSnapshot in querySnapshot.docs) {
          trips.add(docSnapshot.data());
        }
      }

      print("Successfully fetched trips by IDs");
    } catch (e) {
      print("Error fetching trips by IDs: $e");
    }

    return trips;
  }

  Future<void> updateTripPrivacy(String tripId, bool isPrivate) async {
    try {
      await tripCollection.doc(tripId).update({'isPrivate': isPrivate});
    } on Exception catch (e) {
      debugPrint('Error updating privacy: $e');
      rethrow;
    }
  }

}
