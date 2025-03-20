import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/activityModel.dart';


class TransportModel extends ActivityModel{
  //final String? id;
  //final String? tripId;
  final DateTime? departureDate;
  final String? departurePlace;
  final String? arrivalPlace;
  final num? duration;
  final num? cost;

  // Constructor
  TransportModel({
    String? id,
    String? tripId,
    String? type,
    this.departureDate,
    this.departurePlace,
    this.arrivalPlace,
    this.duration,
    this.cost,
  }): super(id: id, tripId: tripId, type: type);

  // Factory method to convert Firestore snapshot to TransportModel
  @override
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
      type: data['type'] as String?,
      departureDate: departureTimestamp?.toDate(), // Convert Timestamp to DateTime
      departurePlace: data['departurePlace'] as String?,
      arrivalPlace: data['arrivalPlace'] as String?,
      duration: data['duration'] as num?,
      cost: data['cost'] as num?,
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (tripId != null) 'tripId': tripId,
      if (type != null) 'type': 'flight',
      if (departureDate != null) 'departureDate': Timestamp.fromDate(departureDate!),
      if (departurePlace != null) 'departurePlace': departurePlace,
      if (arrivalPlace != null) 'arrivalPlace': arrivalPlace,
      if (duration != null) 'duration': duration,
      if (cost != null) 'cost': cost,
    };
  }
}