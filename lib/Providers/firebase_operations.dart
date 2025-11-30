import 'package:nextbus/Providers/api_caller.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';

class NewFirebaseOperations {

  static final NewFirebaseOperations _instance = NewFirebaseOperations._internal();
  factory NewFirebaseOperations() {
    return _instance;
  }
  NewFirebaseOperations._internal();

  final ApiService _apiService = ApiService();


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
