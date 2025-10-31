import 'package:flutter/material.dart';
import 'package:nextbus/Providers/api_caller.dart';

class TimetableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, List<dynamic>> _timetables = {};
  Map<String, List<dynamic>> get timetables => _timetables;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTimetable(String route) async {
    if (route.isEmpty || _timetables.containsKey(route)) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/timings/$route');
      if (response.statusCode == 200) {
        _timetables[route] = response.data['data'];
      }
    } catch (e) {
      print('Error fetching timetable: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
