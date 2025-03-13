import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/activityModel.dart';

class TripModel {
  final String? id;
  final String? creatorId;
  final String? title;
  final List<String>? nations;
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
    this.creatorId,
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
        id: data?['id'],
        creatorId: data?['creatorId'],
        title: data?['title'],
        nations: data?['nations'] is Iterable ? List<String>.from(data?['nations']) : null,
        cities: data?['cities'] is Iterable ? List<String>.from(data?['cities']) : null,
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
      if (creatorId != null) 'creatorId': creatorId,
      if (title != null) 'title': title,
      if (nations != null) 'nations': nations,
      if (cities != null) 'cities': cities,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      if (activities != null) 'activities': activities,
      if (expenses != null) 'creatorId': expenses,
      if (isConfirmed != null) 'isConfirmed': isConfirmed,
      if (isPast != null) 'isPast': isPast,
      if (isPrivate != null) 'isPrivate': isPrivate,
    };
  }
}
