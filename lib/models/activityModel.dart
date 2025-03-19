import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { sightseeing, adventure, relaxation, cultural, other }

class ActivityModel {
  final String? id;
  final String? tripId;
  final String? name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final num? cost;
  final String? type;

  // Constructor
  ActivityModel({
    this.id,
    this.tripId,
    this.name,
    this.startDate,
    this.endDate,
    this.description,
    this.cost,
    this.type,
  });

  // Factory method to convert Firestore snapshot to ActivityModel
  factory ActivityModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    if (data == null) return ActivityModel(); // Handle null case

    Timestamp? startTimestamp = data['startDate'] as Timestamp?;
    Timestamp? endTimestamp = data['endDate'] as Timestamp?;

    return ActivityModel(
      id: snapshot.id, // Firestore document ID
      tripId: data['tripId'] as String?,
      name: data['name'] as String?,
      startDate: startTimestamp?.toDate(), // Convert Timestamp to DateTime
      endDate: endTimestamp?.toDate(), // Convert Timestamp to DateTime
      description: data['description'] as String?,
      cost: data['cost'] as num?,
      type: data['type'] as String?, // Convert String to Enum
    );
  }


}
