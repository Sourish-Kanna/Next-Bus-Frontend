import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/api_caller.dart';

class UserDetails with ChangeNotifier {
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  Future<void> fetchUserDetails() async {
    ApiService API = ApiService();
    try {
      var result = await API.get("/user/get-user-details");
      if (result.data != null && result.data["data"] != null){
        Map<String, dynamic> data = result.data["data"];
        _isAdmin = data["isAdmin"] ?? false;
        _isLoggedIn = data["isLoggedIn"] ?? false;
        _isGuest = data["isGuest"] ?? false;
      } else {
        // Handle cases where the data structure is not as expected
        AppLogger.log("Error fetching user details: Invalid response structure or null data.");
        _isAdmin = false;
        _isLoggedIn = false;
        _isGuest = true; // Default to guest
      }
    } catch (e) {
      // Handle error, e.g., log it or set default values
      AppLogger.log("Error fetching user details: $e");
      _isAdmin = false;
      _isLoggedIn = false;
      _isGuest = true; // Default to guest if there's an error
    }
    notifyListeners();
  }
}
