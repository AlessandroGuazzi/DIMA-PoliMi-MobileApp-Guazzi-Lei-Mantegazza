import 'dart:convert';
import 'package:http/http.dart' as http;


class UnsplashService {
  final String apiKey = 'jBAwN65bY2ETmCOMli2N1EQ-HP1yiVZSYatzdSF8cIA';

  Future<String> getPhotoUrl(String? query) async {
    final response = await http.get(
      Uri.parse('https://api.unsplash.com/search/photos?query=$query&client_id=$apiKey&orientation=landscape&per_page=1'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['urls']['regular'];
      } else {
        throw Exception('No images found for $query');
      }
    } else {
      throw Exception('Failed to load image');
    }
  }
}