import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';


class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = kIsWeb
      ? const String.fromEnvironment('API_LINK')
      : (dotenv.env['API_LINK'] ?? '');

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
}
