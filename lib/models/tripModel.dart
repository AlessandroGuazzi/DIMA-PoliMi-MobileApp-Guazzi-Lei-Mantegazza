import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  String? id;
  final Map<String, dynamic>? creatorInfo;
  final String? title;
  //nations is a map of {'name': String, 'flag': String, 'code': String}
  final List<Map<String, dynamic>>? nations;
  final List<String>? cities;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? activities;
  final num? expenses;
  final bool? isConfirmed;
  final bool? isPast;
  final bool? isPrivate;

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
            ? List<String>.from(data?['cities'])
            : null,
        startDate: startDate.toDate(),
        endDate: endDate.toDate(),
        activities: data?['activities'] is Iterable
            ? List<String>.from(data?['activities'])
            : null,
        expenses: data?['expenses'],
        isConfirmed: data?['isConfirmed'],
        isPast: data?['isPast'],
        isPrivate: data?['isPrivate']);
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
      if (cities != null) 'cities': cities,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      if (activities != null) 'activities': activities,
      if (expenses != null) 'expenses': expenses,
      if (isConfirmed != null) 'isConfirmed': isConfirmed,
      if (isPast != null) 'isPast': isPast,
      if (isPrivate != null) 'isPrivate': isPrivate,
    };
  }
}
