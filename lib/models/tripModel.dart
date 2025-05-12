import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  String? id;
  final Map<String, dynamic>? creatorInfo;
  final String? title;

  //nations is a map of {'name': String, 'flag': String, 'code': String}
  final List<Map<String, dynamic>>? nations;

  //cities is a map of {'name': String, 'place_id': String,  'lat': num, 'lng': num}
  final List<Map<String, dynamic>>? cities;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? activities;
  //final num? expenses;
  final Map<String, num>? expenses;
  final bool? isConfirmed;
  final bool? isPast;
  final bool? isPrivate;
  int? saveCounter;
  final Timestamp? timestamp;
  final String? imageRef;

  //constructor
  TripModel({
    this.id,
    this.creatorInfo,
    this.title,
    this.nations,
    this.cities,
    this.startDate,
    this.endDate,
    this.activities,
    this.expenses,
    this.isConfirmed,
    this.isPast,
    this.isPrivate,
    this.saveCounter,
    this.timestamp,
    this.imageRef,
  });

  factory TripModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    Timestamp startDate = data?['startDate'];
    Timestamp endDate = data?['endDate'];

    return TripModel(
        id: snapshot.id,
        creatorInfo: data?['creatorInfo'],
        title: data?['title'],
        nations: data?['nations'] is Iterable
            ? List<Map<String, dynamic>>.from(data?['nations'])
            : null,
        cities: data?['cities'] is Iterable
            ? List<Map<String, dynamic>>.from(data?['cities'])
            : null,
        startDate: startDate.toDate(),
        endDate: endDate.toDate(),
        activities: data?['activities'] is Iterable
            ? List<String>.from(data?['activities'])
            : null,
        //expenses: data?['expenses'],
        expenses: data?['expenses'] != null
            ? {
          'flight': (data?['expenses']?['flight'] as num?) ?? 0,
          'accommodation': (data?['expenses']?['accommodation'] as num?) ?? 0,
          'attraction': (data?['expenses']?['attraction'] as num?) ?? 0,
          'transport': (data?['expenses']?['transport'] as num?) ?? 0,
        }
            : null,
        isConfirmed: data?['isConfirmed'],
        isPast: data?['isPast'],
        isPrivate: data?['isPrivate'],
        saveCounter: data?['saveCounter'],
        timestamp: data?['timestamp'],
        imageRef: data?['imageRef']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (creatorInfo != null) 'creatorInfo': creatorInfo,
      if (title != null) 'title': title,
      if (nations != null)
        'nations': nations!
            .map((country) => {
                  'name': country['name'],
                  'flag': country['flag'],
                  'code': country['code'],
                })
            .toList(),
      if (cities != null)
        'cities': cities!
            .map((city) => {
                  'name': city['name'],
                  'place_id': city['place_id'],
                  'lat': city['lat'],
                  'lng': city['lng'],
                })
            .toList(),
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      if (activities != null) 'activities': activities,
      //if (expenses != null) 'expenses': expenses,
      if (expenses != null)
        'expenses': {
          'flight': expenses!['flight'] ?? 0,
          'accommodation': expenses!['accommodation'] ?? 0,
          'attraction': expenses!['attraction'] ?? 0,
          'transport': expenses!['transport'] ?? 0,
        },
      if (isConfirmed != null) 'isConfirmed': isConfirmed,
      if (isPast != null) 'isPast': isPast,
      if (isPrivate != null) 'isPrivate': isPrivate,
      if (saveCounter != null) 'saveCounter': saveCounter else 'saveCounter': 0,
      if (timestamp != null) 'timestamp': timestamp,
      if(imageRef != null) 'imageRef': imageRef,
    };
  }
}
