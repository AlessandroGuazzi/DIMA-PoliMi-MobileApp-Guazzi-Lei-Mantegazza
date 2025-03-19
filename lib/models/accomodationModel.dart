import 'package:cloud_firestore/cloud_firestore.dart';

class AccommodationModel {
  final String? id;
  final String? name;
  final String? tripId;
  final String? address;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final num? cost;
  final Map<String, dynamic>? contacts; // Changed to a Map

  // Constructor
  AccommodationModel({
    this.id,
    this.name,
    this.tripId,
    this.address,
    this.checkIn,
    this.checkOut,
    this.cost,
    this.contacts,
  });

  // Factory method to convert Firestore snapshot to AccommodationModel
  factory AccommodationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    if (data == null) return AccommodationModel(); // Handle null case

    Timestamp? checkInTimestamp = data['checkIn'] as Timestamp?;
    Timestamp? checkOutTimestamp = data['checkOut'] as Timestamp?;

    return AccommodationModel(
      id: snapshot.id, // Firestore document ID
      name: data['name'] as String?,
      tripId: data['tripId'] as String?,
      address: data['address'] as String?,
      checkIn: checkInTimestamp?.toDate(), // Convert Timestamp to DateTime
      checkOut: checkOutTimestamp?.toDate(), // Convert Timestamp to DateTime
      cost: data['cost'] as num?,
      contacts: data['contacts'] != null
          ? Map<String, dynamic>.from(data['contacts'] as Map) // Ensure it's a map
          : {}, // Default to an empty map if null
    );
  }
}
