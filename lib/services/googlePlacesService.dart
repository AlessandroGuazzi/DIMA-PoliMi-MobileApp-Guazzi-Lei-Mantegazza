import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  final String apiKey = 'AIzaSyDKIlpTjMwBYqqmw-8lNs5PId8zWzPg5cY';

  Future<List<Map<String, String>>> searchCities(
      String query, List<String> countryCodes) async {
    // Put all country code in 'or' to build the query
    String components = countryCodes.map((code) => "country:$code").join("|");

    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=$query'
            '&types=(cities)'
            '&components=$components'
            '&language=it'
            '&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        //create a list of map {name, placeId} to return
        List<Map<String, String>> cities = (data['predictions'] as List)
            .map((prediction) => {
                  'place_name': prediction['structured_formatting']['main_text']
                      .toString(),
                  'place_id': prediction['place_id'].toString(),
                })
            .toList();
        return cities;
      } else {
        throw Exception('Error fetching cities: ${data["status"]}');
      }
    } else {
      throw Exception('Error fetching cities: error ${response.statusCode}');
    }
  }



  Future<Map<String, double>> getCoordinates(String placeId) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] =='OK') {
        return {
          'lat': data['result']['geometry']['location']['lat'],
          'lng': data['result']['geometry']['location']['lng'],
        };
      } else {
        throw Exception('Error fetching coordinates: ${data["status"]}');
      }
    } else {
      throw Exception('Error fetching coordinates: error ${response.statusCode}');
    }

  }
}
