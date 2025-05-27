// for checking if user is admin, logged in, guest

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetails with ChangeNotifier {
  // if user is admin
  // if user is logged in
  // if user is guest
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  void setIsAdmin(bool isAdmin) {
    _isAdmin = isAdmin;
    notifyListeners();
  }

  void setIsLoggedIn(bool isLoggedIn) {
    _isLoggedIn = isLoggedIn;
    notifyListeners();
  }

  void setIsGuest(bool isGuest) {
    _isGuest = isGuest;
    notifyListeners();
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isLoggedIn = true;
      // Check if the user is an admin (you'll need to implement this logic)
      // For example, you might check a custom claim or a Firestore document
      _isAdmin = await checkAdminStatus(user.uid);
    } else {
      _isLoggedIn = false;
      _isAdmin = false;
      // If no user is logged in, you might consider them a guest
      // _isGuest = true;
    }
    notifyListeners();
  }

  Future<bool> checkAdminStatus(String uid) async {
    // Implement your logic to check if the user is an admin
    // This is just a placeholder example, you'll need to adapt it
    // to your specific Firebase setup (e.g., checking a custom claim
    // or a field in a Firestore document).
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists && userDoc['isAdmin'] == true;
  }
}
