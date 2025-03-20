import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/activityModel.dart';

class FlightModel extends ActivityModel{
  //final String? id;
  //final String? tripId;
  final String? departureAirPort;
  final String? arrivalAirPort;
  final String? flightCompany;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final num? duration;
  final num? expenses;


  // Constructor
  FlightModel({
    //this.id,
    //this.tripId,
    String? id,
    String? tripId,
    String? type,
    this.departureAirPort,
    this.arrivalAirPort,
    this.flightCompany,
    this.departureDate,
    this.arrivalDate,
    this.duration,
    this.expenses,
  }) : super(id: id, tripId: tripId, type: type);

  @override
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
      type: data['type'] as String?,
      departureAirPort: data['departureAirPort'] as String?,
      arrivalAirPort: data['arrivalAirPort'] as String?,
      flightCompany: data['flightCompany'] as String?,
      departureDate: departureTimestamp?.toDate(), // Convert Timestamp to DateTime
      arrivalDate: arrivalTimestamp?.toDate(), // Convert Timestamp to DateTime
      duration: data['duration'] as num?,
      expenses: data['expenses'] as num?,
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (tripId != null) 'tripId': tripId,
      if (type != null) 'type': 'flight',
      if (departureAirPort != null) 'departureAirPort': departureAirPort,
      if (arrivalAirPort != null) 'arrivalAirPort': arrivalAirPort,
      if (flightCompany != null) 'flightCompany': flightCompany,
      if (departureDate != null) 'departureDate': Timestamp.fromDate(departureDate!),
      if (arrivalDate != null) 'arrivalDate': Timestamp.fromDate(arrivalDate!),
      if (duration != null) 'duration': duration,
      if (expenses != null) 'expenses': expenses,
    };
  }

}