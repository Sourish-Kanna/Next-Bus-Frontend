import 'package:nextbus/Providers/api_caller.dart';
import 'package:nextbus/common.dart';

class NewFirebaseOperations {

  static final NewFirebaseOperations _instance = NewFirebaseOperations._internal();
  factory NewFirebaseOperations() {
    return _instance;
  }
  NewFirebaseOperations._internal();

  final ApiService _apiService = ApiService();
  final _urls = {
    'addRoute': '/route/add',
    'updateTime': '/timings/update',
    'busRoutes': '/route/routes',
    'busTimes': '/timings/{route}'
  };

  Future<Map<String, dynamic>> addRoute(String routeName, List<String> stops, String timing, String start, String end) async {
    Map<String, dynamic> time = {
      "stop_name": start,
      "time": timing,
      "delay_by": 0,
      "deviation_count": 1,
      "deviation_sum": 0
    };

    Map<String, dynamic> data = {
      "route_name": routeName,
      "stops": stops,
      "start": start,
      "end": end,
      "timing":time,
    };

    try {
      var response = await _apiService.post(_urls['addRoute']!, data: data);
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
      var response = await _apiService.put(_urls['updateTime']!, data: data);
      if (response.statusCode == 200 && response.data != null && response.data is Map<String, dynamic>) {
        return {'success': true, 'data': response.data['data']};
      } else {
        return {'success': false, 'message': response.data['detail'] ?? 'Failed to update time'};
      }
    } catch (e) {
      AppLogger.info("Error updating time: $e");
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<List<String>> getBusRoutes() async {
    try {
      var response = await _apiService.get(_urls['busRoutes']!);
      if (response.data != null &&
          response.data["data"] is List) {
        return List<String>.from(response.data["data"]);
      } else {
        AppLogger.info("Invalid data format received from API");
        return [];
      }
    } catch (e) {
      AppLogger.info("Error fetching bus routes: $e");
      return [];
    }
  }

  // ✅ Best Practice: Return a list of your strongly-typed model
  Future<List<TimingDetail>> getBusTimings(String routeName) async {
    try {
      final url = _urls["busTimes"]!.replaceAll('{route}', routeName);
      var response = await _apiService.get(url);

      if (response.data != null && response.data["data"] is List) {
        final List rawData = response.data["data"];

        // Map the raw list of maps to a list of TimingDetail objects
        return rawData
            .map((json) => TimingDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        AppLogger.info("Invalid data format received from API");
        return [];
      }
    } catch (e) {
      AppLogger.info("Error fetching bus timings: $e");
      return [];
    }
  }
}

// Template Class for a model
class TimingDetail {
  final String time;
  final String stop;
  final num delay; // Use 'num' to handle both int (90) and double (90.0)

  TimingDetail({
    required this.time,
    required this.stop,
    required this.delay,
  });

  // Factory constructor to safely parse a map into a TimingDetail object
  factory TimingDetail.fromJson(Map<String, dynamic> json) {
    return TimingDetail(
      time: json['time'] as String? ?? 'N/A',
      stop: json['stop'] as String? ?? 'Unknown',
      delay: json['delay'] as num? ?? 0,
    );
  }

  // ✅ Add this method to your class
  @override
  String toString() {
    return 'TimingDetail(time: $time, stop: $stop, delay: $delay)';
  }
}
