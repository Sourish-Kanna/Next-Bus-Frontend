import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextbus/providers/api_caller.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';

class TimetableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  final Map<String, List<dynamic>> _timetables = {};
  Map<String, List<dynamic>> get timetables => _timetables;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTimetable(String route) async {
    if (route.isEmpty) return; // Removed 'containsKey' check to allow refreshing

    // 1. Only set loading to true if we don't have data in memory yet.
    // This prevents the UI from flashing a spinner if we are just refreshing existing data.
    if (!_timetables.containsKey(route)) {
      _isLoading = true;
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'timetable_$route';

    // 2. CACHE LAYER: Try to load from disk first
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null && !_timetables.containsKey(route)) {
      try {
        List<dynamic> decoded = json.decode(cachedData);
        _timetables[route] = decoded;

        // Show cached data immediately, turn off loading
        _isLoading = false;
        notifyListeners();
        AppLogger.info("Loaded route $route from cache.");
      } catch (e) {
        AppLogger.warn("Failed to parse cached timetable for $route");
      }
    }

    // 3. NETWORK LAYER: Fetch fresh data in the background
    try {
      final response = await _apiService.get(urls['busTimes']!.replaceAll('{route}', route));

      if (response.statusCode == 200) {
        List<dynamic> newData = response.data['data'];

        // Update memory
        _timetables[route] = newData;

        // Update disk cache
        await prefs.setString(cacheKey, json.encode(newData));

        AppLogger.info("Fetched fresh timetable for route $route from API.");
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

        // Invalidate the cache (Memory & Disk) for this route so the next fetch gets updated data
        _timetables.remove(routeName);

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('timetable_$routeName');

        // Fetch fresh data immediately
        fetchTimetable(routeName);

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