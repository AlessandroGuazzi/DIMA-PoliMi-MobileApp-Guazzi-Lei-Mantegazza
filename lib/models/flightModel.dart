import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/airportModel.dart';

class FlightModel extends ActivityModel{
  //final String? id;
  //final String? tripId;

  //airport is a map of {'name' : String, 'iata' : String}
  final Map<String, String>? departureAirPort; // Esempio: {"name": "Malpensa", "iata": "MXP"}
  final Map<String, String>? arrivalAirPort;
  //final String? flightCompany;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final num? duration;
  //final num? expenses;


  // Constructor
  FlightModel({
    //this.id,
    //this.tripId,
    String? id,
    String? tripId,
    String? type,
    num? expenses,
    this.departureAirPort,
    this.arrivalAirPort,
    this.departureDate,
    this.arrivalDate,
    this.duration,
  }) : super(id: id, tripId: tripId, type: type, expenses: expenses);

  @override
  factory FlightModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    if (data == null) return FlightModel(); // Handle null data safely

    Timestamp? departureTimestamp = data['departureDate'] as Timestamp?;
    Timestamp? arrivalTimestamp = data['arrivalDate'] as Timestamp?;
    final Map<String, dynamic>? departureAirportData = data['departureAirPort'] as Map<String, dynamic>?;
    final Map<String, dynamic>? arrivalAirportData = data['arrivalAirPort'] as Map<String, dynamic>?;

    print('fetching flight.....');
    return FlightModel(
      id: snapshot.id, // Use Firestore document ID
      tripId: data['tripId'] as String?,
      type: data['type'] as String?,
      departureAirPort: departureAirportData != null
          ? {
        'name': departureAirportData['name'] as String? ?? '',
        'iata': departureAirportData['iata'] as String? ?? '',
        'iso' : departureAirportData['iso'] as String? ?? ''
      }
          : null,
      arrivalAirPort: arrivalAirportData != null
          ? {
        'name': arrivalAirportData['name'] as String? ?? '',
        'iata': arrivalAirportData['iata'] as String? ?? '',
        'iso' : arrivalAirportData['iso'] as String? ?? ''
      }
          : null,
      //flightCompany: data['flightCompany'] as String?,
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
      if (departureAirPort != null)
        'departureAirPort': {
          'name': departureAirPort!['name'],
          'iata': departureAirPort!['iata'],
          'iso' : departureAirPort!['iso']
        },
      if (arrivalAirPort != null)
        'arrivalAirPort': {
          'name': arrivalAirPort!['name'],
          'iata': arrivalAirPort!['iata'],
          'iso' : arrivalAirPort!['iso']
        },
      if (departureDate != null) 'departureDate': Timestamp.fromDate(departureDate!),
      if (arrivalDate != null) 'arrivalDate': Timestamp.fromDate(arrivalDate!),
      if (duration != null) 'duration': duration,
      if (expenses != null) 'expenses': expenses,
    };
  }

}