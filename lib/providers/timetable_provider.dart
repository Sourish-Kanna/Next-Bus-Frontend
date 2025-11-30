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

  Future<Map<String, dynamic>> addRoute(String routeName, List<String> stops, String timing, String start, String end) async {

    Map<String, dynamic> data = {
      "route_name": routeName,
      "stops": stops,
      "start": start,
      "end": end,
      "timing": timing,
    };

    try {
      var response = await _apiService.post(urls['addRoute']!, data: data);

      if (response.statusCode == 200 && response.data != null && response.data is Map<String, dynamic>) {
        // Optional: You might want to refresh the local timetable list here if necessary
        return {'success': true, 'data': response.data['data']};
      } else {
        return {'success': false, 'message': response.data['detail'] ?? 'Failed to add route'};
      }
    } catch (e) {
      AppLogger.info("Error adding route: $e");
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> updateTime(String routeName, String stopName, String timing) async {
    Map<String, dynamic> data = {
      "route_name": routeName,
      "timing": timing,
      "stop": stopName
    };

    try {
      var response = await _apiService.put(urls['updateTime']!, data: data);

      if (response.statusCode == 200 && response.data != null && response.data is Map<String, dynamic>) {

        // Optional: Invalidate the cache for this route so the next fetch gets updated data
        if (_timetables.containsKey(routeName)) {
          _timetables.remove(routeName);
          notifyListeners();
        }

        return {'success': true, 'data': response.data['data']};
      } else {
        return {'success': false, 'message': response.data['detail'] ?? 'Failed to update time'};
      }
    } catch (e) {
      AppLogger.info("Error updating time: $e");
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}