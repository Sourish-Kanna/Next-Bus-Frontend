import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String? _baseUrl = dotenv.env['API_LINK'];
  final String? _apiKey = dotenv.env['API_KEY'];

  Future<void> fetchData() async {
    if (_baseUrl == null || _apiKey == null) {
      print('API URL or Key not found in .env');
      return;
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/some_endpoint'),
      headers: {
        'Authorization': 'Bearer $_apiKey', // Example usage of API key
      },
    );

    if (response.statusCode == 200) {
      // Process the response
      print('Data fetched successfully: ${response.body}');
    } else {
      // Handle error
      print('Failed to fetch data: ${response.statusCode}');
    }
  }
}
