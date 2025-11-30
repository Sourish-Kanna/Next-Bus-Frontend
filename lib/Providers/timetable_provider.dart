import 'package:flutter/material.dart';
import 'package:nextbus/Providers/api_caller.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';

class TimetableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  final Map<String, List<dynamic>> _timetables = {};
  Map<String, List<dynamic>> get timetables => _timetables;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTimetable(String route) async {
    if (route.isEmpty || _timetables.containsKey(route)) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(urls['busTimes']!.replaceAll('{route}', route));
      if (response.statusCode == 200) {
        _timetables[route] = response.data['data'];
      }
    } catch (e, stack) {
      // Here is the fix:
      AppLogger.error(
        "Failed to fetch timetable for route: $route",
        e,
        stack,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
