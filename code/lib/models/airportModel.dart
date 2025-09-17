import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Airport {
  final String iata;
  final String name;
  final String iso;

  Airport({
    required this.iata,
    required this.name,
    required this.iso,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      iata: json['iata'] ?? '',
      name: json['name'] ?? '',
      iso: json['iso'] ?? '',
    );
  }
}


