import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/activityModel.dart';

//enum ActivityType { sightseeing, adventure, relaxation, cultural, other }

class AttractionModel extends ActivityModel{
  //final String? id;
  //final String? tripId;
  final String? name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? address;
  final String? description;
  final num? cost;
  final String? attractionType;

  // Constructor
  AttractionModel({
    String? id,
    String? tripId,
    String? type,
    this.name,
    this.startDate,
    this.endDate,
    this.address,
    this.description,
    this.cost,
    this.attractionType,
  }) : super(id: id, tripId: tripId, type: type);

  // Factory method to convert Firestore snapshot to ActivityModel
  factory AttractionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    if (data == null) return AttractionModel(); // Handle null case

    Timestamp? startTimestamp = data['startDate'] as Timestamp?;
    Timestamp? endTimestamp = data['endDate'] as Timestamp?;

    return AttractionModel(
      id: snapshot.id, // Firestore document ID
      tripId: data['tripId'] as String?,
      type: data['type'] as String?,
      name: data['name'] as String?,
      startDate: startTimestamp?.toDate(), // Convert Timestamp to DateTime
      endDate: endTimestamp?.toDate(), // Convert Timestamp to DateTime
      address: data['address'] as String?,
      description: data['description'] as String?,
      cost: data['cost'] as num?,
      attractionType: data['attractionType'] as String?, // Convert String to Enum
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (tripId != null) 'tripId': tripId,
      if (type != null) 'type': 'attraction',
      if (name != null) 'name': name,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      if (address != null) 'address': address,
      if (description != null) 'description': description,
      if (cost != null) 'cost': cost,
      if (type != null) 'attractionType': attractionType,
    };
  }


}
