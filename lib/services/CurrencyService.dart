import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyService {

  Future<num> getExchangeRate(String base, String target) async {
    final Uri url = Uri.parse('https://hexarate.paikama.co/api/rates/latest/$base?target=$target');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);
        return data['data']['mid'];  // Returns a map of currency rates
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Failed to load exchange rates: $e');
    }
  }

}