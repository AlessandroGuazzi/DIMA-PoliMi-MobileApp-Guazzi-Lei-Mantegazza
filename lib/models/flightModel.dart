import 'package:cloud_firestore/cloud_firestore.dart';

class FlightModel {
  final String? id;
  final String? tripId;
  final String? departureAirPort;
  final String? arrivalAirPort;
  final String? flightCompany;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final num? duration;
  final num? expenses;


  // Constructor
  FlightModel({
    this.id,
    this.tripId,
    this.departureAirPort,
    this.arrivalAirPort,
    this.flightCompany,
    this.departureDate,
    this.arrivalDate,
    this.duration,
    this.expenses,
  });

  factory FlightModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    if (data == null) return FlightModel(); // Handle null data safely

    Timestamp? departureTimestamp = data['departureDate'] as Timestamp?;
    Timestamp? arrivalTimestamp = data['arrivalDate'] as Timestamp?;

    return FlightModel(
      id: snapshot.id, // Use Firestore document ID
      tripId: data['tripId'] as String?,
      departureAirPort: data['departureAirPort'] as String?,
      arrivalAirPort: data['arrivalAirPort'] as String?,
      flightCompany: data['flightCompany'] as String?,
      departureDate: departureTimestamp?.toDate(), // Convert Timestamp to DateTime
      arrivalDate: arrivalTimestamp?.toDate(), // Convert Timestamp to DateTime
      duration: data['duration'] as num?,
      expenses: data['expenses'] as num?,
    );
  }

}