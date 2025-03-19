import 'package:cloud_firestore/cloud_firestore.dart';


class TransportModel {
  final String? id;
  final String? tripId;
  final DateTime? departureDate;
  final String? departurePlace;
  final String? arrivalPlace;
  final num? duration;
  final num? cost;

  // Constructor
  TransportModel({
    this.id,
    this.tripId,
    this.departureDate,
    this.departurePlace,
    this.arrivalPlace,
    this.duration,
    this.cost,
  });

  // Factory method to convert Firestore snapshot to TransportModel
  factory TransportModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    if (data == null) return TransportModel(); // Handle null case

    Timestamp? departureTimestamp = data['departureDate'] as Timestamp?;

    return TransportModel(
      id: snapshot.id, // Firestore document ID
      tripId: data['tripId'] as String?,
      departureDate: departureTimestamp?.toDate(), // Convert Timestamp to DateTime
      departurePlace: data['departurePlace'] as String?,
      arrivalPlace: data['arrivalPlace'] as String?,
      duration: data['duration'] as num?,
      cost: data['cost'] as num?,
    );
  }
}