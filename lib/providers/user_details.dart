import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';
import 'package:nextbus/providers/api_caller.dart';

class UserDetails with ChangeNotifier {
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  bool _isGuest = true;

  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  Future<void> fetchUserDetails() async {
    ApiService api = ApiService();
    try {
      var result = await api.get(urls["user"]!);
      if (result.data != null && result.data["data"] != null){
        Map<String, dynamic> data = result.data["data"];
        AppLogger.info("User Details fetched: $data");

        _isAdmin = data["isAdmin"] ?? false;
        _isLoggedIn = data["isLoggedIn"] ?? false;
        _isGuest = data["isGuest"] ?? true;
      } else {
        AppLogger.error("Error fetching user details: Invalid response structure.", result.data);
        _setDefaultGuest();
      }
    } catch (e) {
      AppLogger.error("Error fetching user details", e);
      _setDefaultGuest();
    }
    // This updates the UI
    notifyListeners();
  }

  void _setDefaultGuest() {
    _isAdmin = false;
    _isLoggedIn = false;
    _isGuest = true;
  }
}