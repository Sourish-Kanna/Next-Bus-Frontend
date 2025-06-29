import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextbus/Providers/firebase_operations.dart';
import 'package:nextbus/common.dart';

// Route Provider with String-based Route Persistence
class RouteProvider with ChangeNotifier {
  String _route = "56"; // Default route as String, will be updated from Firebase
  List<String> _availableRoutes = ["56"]; // Initial default, will be updated from Firebase

  String get route => _route;
  List<String> get availableRoutes => _availableRoutes;

  RouteProvider() {
    _loadAvailableRoutes(); // Load routes from Firebase or SharedPreferences first
    _loadRoute();
  }

  void _loadAvailableRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedRoutes = prefs.getStringList('availableRoutes');

    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      _availableRoutes = savedRoutes;
    } else {
      // Fallback to Firebase if not found in SharedPreferences
      NewFirebaseOperations firebaseOps = NewFirebaseOperations();
      try {
        var routesFromFirebase = await firebaseOps.getBusRoutes();
        if (routesFromFirebase.isNotEmpty) {
          _availableRoutes = List<String>.from(routesFromFirebase); // Assuming getBusRoutes returns List<dynamic> or List<String>
          // Save to SharedPreferences for future use
          await prefs.setStringList('availableRoutes', _availableRoutes);
        }
      } catch (e) {
        AppLogger.log("Error loading routes from Firebase: $e");
        // Keep the default hardcoded routes if Firebase fails and nothing in SharedPreferences
      }
    }

    // If the current default route is not in the new list, update it
    if (_availableRoutes.isNotEmpty && !_availableRoutes.contains(_route)) {
      _route = _availableRoutes.first; // Or some other default logic
        }
    notifyListeners(); // Notify listeners after routes are potentially updated
  }


  void _loadRoute() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedRoute = prefs.getString('selectedRoute');
    // Ensure the saved route is one of the available routes
    if (savedRoute != null && _availableRoutes.contains(savedRoute)) {
      _route = savedRoute;
    } else if (_availableRoutes.isNotEmpty) {
      _route = _availableRoutes.first; // Fallback to the first available route if saved one is not valid or not set
    }
    // No need to save here, just loading
    notifyListeners();
  }

  void setRoute(String newRoute) async {
    if (_route == newRoute || !_availableRoutes.contains(newRoute)) return; // Only set if it's a valid and different route
    _route = newRoute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoute', newRoute);
    notifyListeners();
  }
}
