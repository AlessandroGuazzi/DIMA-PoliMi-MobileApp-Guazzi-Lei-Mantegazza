import 'dart:convert';
import 'package:http/http.dart' as http;


class GooglePlacesService {
  final String apiKey = 'AIzaSyDtmTOAl3g3pR8nK4SDYdGJhDBDzpIya-k';

  Future<List<Map<String, String>>> searchAutocomplete(String query, List<String> countryCodes, String searchType) async {
    // Put all country code in 'or' to build the query
    String components = countryCodes.map((code) => "country:$code").join("|");

    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=$query'
            '&types=$searchType'
            '&components=$components'
            '&language=it'
            '&key=$apiKey');

    final response = await http.get(url);
    print('GOOGLE AUTOCOMPLETE API CALL');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        //create a list of map {name, placeId} to return
        List<Map<String, String>> places = (data['predictions'] as List)
            .map((prediction) => {
                  'name': prediction['structured_formatting']['main_text']
                      .toString(),
                  'other_info': prediction['structured_formatting']
                          ['secondary_text']
                      .toString(),
                  'place_id': prediction['place_id'].toString(),
                })
            .toList();
        return places;
      } else {
        throw Exception('Error fetching cities: ${data["status"]}');
      }
    } else {
      throw Exception('Error fetching cities: error ${response.statusCode}');
    }
  }

  Future<Map<String, double>> getCoordinates(String? placeId) async {
    if (placeId == null) return {'lat': 0, 'lng': 0};
    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=$placeId'
            '&key=$apiKey');

    final response = await http.get(url);
    print('GOOGLE API CALL');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return {
          'lat': data['result']['geometry']['location']['lat'],
          'lng': data['result']['geometry']['location']['lng'],
        };
      } else {
        throw Exception('Error fetching coordinates: ${data["status"]}');
      }
    } else {
      throw Exception(
          'Error fetching coordinates: error ${response.statusCode}');
    }
  }
}
