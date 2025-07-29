import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/firebase_operations.dart';


String dateToString(DateTime time) {
  return DateFormat('h:mm a').format(time);
}

DateTime stringToDate(String time) {
  return DateFormat('h:mm a').parse(time);
}

DateTime dateToFormat(DateTime now) {
  String formattedTime = DateFormat('h:mm a').format(now);
  return DateFormat('h:mm a').parse(formattedTime);
}

class BusTimingList with ChangeNotifier {
  final FirestoreService _firebaseService = FirestoreService();
  final Map<String, List<String>> _routeBusTimings = {};


  /// Get bus timings for a specific route
  List<String> getBusTimings(String route) {
    fetchBusTimings(route);
    return _routeBusTimings[route] ?? [];
  }

  /// Fetch bus timings from Firestore for a specific route
  Future<void> fetchBusTimings(String route) async {
    if (route.isEmpty) return;
    try {
      final List<String> timings = await _firebaseService.getBusTimings(route);
      _routeBusTimings[route] = timings
        ..sort((a, b) => stringToDate(a).compareTo(stringToDate(b)));

      notifyListeners();
    } catch (e) {
      AppLogger.log('🔥 Error fetching bus timings: $e');
    }
  }

  /// Add a new bus timing for a specific route
  Future<void> addBusTiming(String route, String newTime, String user) async {
    if (route.isEmpty) return;
    try {
      await _firebaseService.addBusTiming(route, newTime, user);
      _routeBusTimings.putIfAbsent(route, () => []);
      _routeBusTimings[route]!
        ..add(newTime)
        ..sort((a, b) => stringToDate(a).compareTo(stringToDate(b)));

      notifyListeners();
    } catch (e) {
      AppLogger.log('🔥 Error adding bus timing: $e');
    }
  }

  /// Delete a bus timing from a specific route
  Future<void> deleteBusTiming(String route, int index, String user) async {
    if (route.isEmpty || index < 0 || !_routeBusTimings.containsKey(route)) return;

    String timeToDelete = _routeBusTimings[route]![index];

    try {
      await _firebaseService.deleteBusTiming(route, timeToDelete, user);
      _routeBusTimings[route]!.removeAt(index);
      notifyListeners();
    } catch (e) {
      AppLogger.log('🔥 Error deleting bus timing: $e');
    }
  }

  /// Undo last added bus timing for a specific route
  Future<void> undoAddBusTiming(String route, String time, String user) async {
    if (route.isEmpty || !_routeBusTimings.containsKey(route) || !_routeBusTimings[route]!.contains(time)) return;

    try {
      await _firebaseService.deleteBusTiming(route, time, user);
      _routeBusTimings[route]!.remove(time);
      notifyListeners();
    } catch (e) {
      AppLogger.log('🔥 Error undoing add bus timing: $e');
    }
  }

  /// Edit an existing bus timing for a specific route
  Future<void> editBusTiming(String route, int index, String newTime, String user) async {
    if (route.isEmpty || index < 0 || !_routeBusTimings.containsKey(route)) return;

    String oldTime = _routeBusTimings[route]![index];

    try {
      await _firebaseService.updateBusTiming(route, oldTime, newTime, user);
      _routeBusTimings[route]![index] = newTime;
      _routeBusTimings[route]!.sort((a, b) => stringToDate(a).compareTo(stringToDate(b)));

      notifyListeners();
    } catch (e) {
      AppLogger.log('🔥 Error editing bus timing: $e');
    }
  }
}

class Timetable with ChangeNotifier {
  final NewFirebaseOperations _firebaseService = NewFirebaseOperations();
  final Map<String, List<TimingDetail>> _routeTimetables = {};

  // ✅ Getter: Only returns what's already in the cache.
  List<TimingDetail>? getTimetableForRoute(String route) {
    return _routeTimetables[route];
  }

  // ✅ Fetch Method: Fetches data and notifies listeners when done.
  Future<void> fetchTimetable(String route) async {
    if (route.isEmpty) return;
    try {
      final List<TimingDetail> timetable = await _firebaseService.getBusTimings(route);

      // ✅ Sort the list by time before storing it
      timetable.sort((a, b) => stringToDate(a.time).compareTo(stringToDate(b.time)));
      _routeTimetables[route] = timetable;
      notifyListeners();
    } catch (e) {
      AppLogger.log('🔥 Error fetching and parsing timetable: $e');
    }
  }
}
