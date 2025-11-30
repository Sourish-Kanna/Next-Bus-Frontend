import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextbus/Providers/api_caller.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';


// Route Provider with String-based Route Persistence
class RouteProvider with ChangeNotifier {
  String _route = "56"; // Default route
  List<String> _availableRoutes = ["56"]; // Initial default

  String get route => _route;
  List<String> get availableRoutes => _availableRoutes;

  RouteProvider() {
    _loadAvailableRoutes();
    _loadRoute();
  }

  void _loadAvailableRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedRoutes = prefs.getStringList('availableRoutes');

    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      _availableRoutes = savedRoutes;
    } else {
      // Fallback to API if not found in SharedPreferences
      ApiService apiService = ApiService();
      try {
        var response = await apiService.get(urls['busRoutes']!);
        if (response.statusCode == 200) {
          _availableRoutes = List<String>.from(response.data['data']);
          await prefs.setStringList('availableRoutes', _availableRoutes);
        }
        else {
          AppLogger.warn("Error loading routes from API: ${response.statusCode}");
        }
      } catch (e) {
        AppLogger.error("Error loading routes from API",e);
      }
    }

    if (_availableRoutes.isNotEmpty && !_availableRoutes.contains(_route)) {
      _route = _availableRoutes.first;
    }
    notifyListeners();
  }

  void _loadRoute() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedRoute = prefs.getString('selectedRoute');
    if (savedRoute != null && _availableRoutes.contains(savedRoute)) {
      _route = savedRoute;
    } else if (_availableRoutes.isNotEmpty) {
      _route = _availableRoutes.first;
    }
    notifyListeners();
  }

  void setRoute(String newRoute) async {
    if (_route == newRoute || !_availableRoutes.contains(newRoute)) return;
    _route = newRoute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoute', newRoute);
    notifyListeners();
  }
}
