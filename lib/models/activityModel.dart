import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/transportModel.dart';

class ActivityModel {
  final String? id;
  final String? tripId;
  final String? type;
  final num? expenses;

  ActivityModel({
    this.id,
    this.tripId,
    this.type,
    this.expenses
  });


  factory ActivityModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    if (data == null) return ActivityModel();


    switch (data['type']) {
      case 'flight':
        return FlightModel.fromFirestore(snapshot, null);
      case 'accommodation':
        return AccommodationModel.fromFirestore(snapshot, null);
      case 'transport':
        return TransportModel.fromFirestore(snapshot, null);
      case 'attraction':
        return AttractionModel.fromFirestore(snapshot, null);
      default:
        return ActivityModel(id: snapshot.id, tripId: data['tripId'] as String?);
    }

  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (tripId != null) 'tripId': tripId,
      if (type != null)  'type': type,
      if (expenses != null)  'expenses': expenses
    };
  }



}
