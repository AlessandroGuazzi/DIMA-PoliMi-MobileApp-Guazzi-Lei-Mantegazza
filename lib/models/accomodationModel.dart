import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/activityModel.dart';

class AccommodationModel extends ActivityModel{
  //final String? id;
  final String? name;
  final String? address;
  final DateTime? checkIn;
  final DateTime? checkOut;
  //final num? cost;
  final Map<String, dynamic>? contacts; // Changed to a Map

  // Constructor
  AccommodationModel({
    String? id,
    String? tripId,
    String? type,
    num? expenses,
    this.name,
    this.address,
    this.checkIn,
    this.checkOut,
    this.contacts,
  }) : super(id: id, tripId: tripId, type: type, expenses: expenses);

  // Factory method to convert Firestore snapshot to AccommodationModel
  @override
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
      type: data['type'] as String?,
      address: data['address'] as String?,
      checkIn: checkInTimestamp?.toDate(), // Convert Timestamp to DateTime
      checkOut: checkOutTimestamp?.toDate(), // Convert Timestamp to DateTime
      expenses: data['expenses'] as num?,
      contacts: data['contacts'] != null
          ? Map<String, dynamic>.from(data['contacts'] as Map) // Ensure it's a map
          : {}, // Default to an empty map if null
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tripId != null) 'tripId': tripId,
      if (type != null) 'type': 'accommodation',
      if (address != null) 'address': address,
      if (checkIn != null) 'checkIn': Timestamp.fromDate(checkIn!),
      if (checkOut != null) 'checkOut': Timestamp.fromDate(checkOut!),
      if (expenses!= null) 'expenses': expenses,
      if (contacts != null) 'contacts': contacts,
    };
  }
}
