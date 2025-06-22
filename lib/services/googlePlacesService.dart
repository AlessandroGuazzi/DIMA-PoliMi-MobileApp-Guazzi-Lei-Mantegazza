import 'dart:convert';
import 'package:http/http.dart' as http;


class GooglePlacesService {
  final String apiKey = '';

  Future<List<Map<String, String>>> searchAutocomplete(
      String query, List<String> countryCodes, String searchType) async {
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
    print('API CALL');

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
    print('API CALL');
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

  /*
  Future<String> getCountryImageRef(String? country) async {
    if (country == null) {
      return '';
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
      '?input=$country'
      '&inputtype=textquery'
      '&fields=photos'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final photoRef =
              data['candidates'][0]['photos'][0]['photo_reference'];
          return photoRef;
        } else {
          throw Exception('No photos found for the country: $country');
        }
      } else {
        throw Exception('Error fetching data: ${data["status"]}');
      }
    } else {
      throw Exception('Error fetching coordinates: ${response.statusCode}');
    }
  }

  Future<String> getImageUrl(TripModel trip) async {
    String url = '';
    if (trip.imageRef != null) {
      url = 'https://maps.googleapis.com/maps/api/place/photo'
          '?maxheight=500'
          '&maxwidth=500'
          '&photo_reference=${trip.imageRef}'
          '&key=$apiKey';

      //check if url is still valid
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode != 200) {
          print('UPDATE for imageREf needed');
          //update imageRef
          final country = (trip.nations?.isNotEmpty ?? false)
              ? trip.nations!.first['name'] ?? 'Italy'
              : 'Italy';
          final newImageRef = await getCountryImageRef(country);
          //store new image ref
          //TODO: verify correct update
          trip.imageRef = newImageRef;
          await DatabaseService().updateTrip(trip);
          //update url with new image ref
          url = 'https://maps.googleapis.com/maps/api/place/photo'
              '?maxheight=500'
              '&maxwidth=500'
              '&photo_reference=$newImageRef'
              '&key=$apiKey';
        }
      } catch (e) {
        return '';
      }
    }
    return url;
  }

   */
}
