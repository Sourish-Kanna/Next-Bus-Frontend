import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/api_caller.dart';

class UserDetails with ChangeNotifier {
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  Future<bool> get isAdmin async {
    await fetchUserDetails();
    return _isAdmin;
  }

  Future<bool> get isLoggedIn async {
    await fetchUserDetails();
    return _isLoggedIn;
  }

  Future<bool> get isGuest async {
    await fetchUserDetails();
    return _isGuest;
  }

  Future<void> fetchUserDetails() async {
    ApiService api = ApiService();
    try {
      var result = await api.get("/user/get-user-details");
      if (result.data != null && result.data["data"] != null){
        Map<String, dynamic> data = result.data["data"];
        debugPrint("User Details fetched: $data");
        AppLogger.info("User Details fetched: $data");
        _isAdmin = data["isAdmin"] ?? false;
        _isLoggedIn = data["isLoggedIn"] ?? false;
        _isGuest = data["isGuest"] ?? false;
      } else {
        // Handle cases where the data structure is not as expected
        AppLogger.error("Error fetching user details: Invalid response structure or null data.", result.data);
        _isAdmin = false;
        _isLoggedIn = false;
        _isGuest = true; // Default to guest
      }
    } catch (e) {
      // Handle error, e.g., log it or set default values
      AppLogger.error("Error fetching user details", e);
      _isAdmin = false;
      _isLoggedIn = false;
      _isGuest = true; // Default to guest if there's an error
    }
    notifyListeners();
  }
}
