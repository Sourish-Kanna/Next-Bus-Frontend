import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = const String.fromEnvironment('API_LINK');

  Future<Response> post(String path, {Map<String,dynamic>? data}) async {
    final trace = FirebasePerformance.instance.newTrace('post_request');
    await trace.start();
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
    await trace.stop();

    return response;
  }

  Future<Response> get(String path, {Map<String,dynamic>? queryParameters}) async {
    final trace = FirebasePerformance.instance.newTrace('get_request');
    await trace.start();
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
    await trace.stop();
    return response;
  }
}
