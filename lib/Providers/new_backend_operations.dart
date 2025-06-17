import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = const String.fromEnvironment('API_LINK');

  Future<Response> verifyTest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    final idToken = await user.getIdToken();

    final url = '$baseUrl/test-done/verify_token';
    final response = await _dio.post(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  }

  Future<Response> post(String path, {Map<String,dynamic>? data}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final idToken = await user.getIdToken();
    final url = '$baseUrl/v1$path';

    final response = await _dio.post(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ),
      data: data
    );

    return response;
  }

  Future<Response> get(String path, {Map<String,dynamic>? queryParameters}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final idToken = await user.getIdToken();
    final url = '$baseUrl/v1$path';

    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ),
      queryParameters: queryParameters,
    );
    return response;
  }
}
