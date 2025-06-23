import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:nextbus/Providers/authentication.dart';


// SnackBar widget with optional undo action and Haptic feedback for user actions
void customSnackBar(BuildContext context, String text, {VoidCallback? onUndo}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      action: onUndo != null ?
      SnackBarAction(label: "Undo", onPressed: onUndo,) : null,
      duration: const Duration(seconds: 3),
    ),
  );
  HapticFeedback.lightImpact();
}

void logoutUser(BuildContext context) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  await authService.signOut();
  if (!context.mounted) return;
  Navigator.pushReplacementNamed(context, '/login');
}

enum NavigationDestinations {
  login,
  home,
  route,
  entries,
  settings,
}

class AppRoutes {
  static const String home = '/home'; // Often the initial route
  static const String login = '/login';
  static const String route = '/route';
  static const String entries = '/entries';
  static const String settings = '/settings';

  // Helper to get route from our enum (optional but can be handy)
  static String fromDestination(NavigationDestinations destination) {
    switch (destination) {
      case NavigationDestinations.home:
        return home;
      case NavigationDestinations.login:
        return login;
      case NavigationDestinations.route:
        return route;
      case NavigationDestinations.entries:
        return entries;
      case NavigationDestinations.settings:
        return settings;
    }
  }
}

class NavigationItem {
  final NavigationDestinations destination;
  final IconData icon;
  final String label;

  NavigationItem({
    required this.destination,
    required this.icon,
    required this.label,
  });
}

final List<NavigationItem> appDestinations = [
  // NavigationItem(destination: NavigationDestinations.login, icon: Icons.logout, label: 'Logout'),
  NavigationItem(destination: NavigationDestinations.home, icon: Icons.home, label: 'Home'),
  NavigationItem(destination: NavigationDestinations.route, icon: Icons.route, label: 'Profile'),
  NavigationItem(destination: NavigationDestinations.entries, icon: Icons.bookmark, label: 'Entries'),
  NavigationItem(destination: NavigationDestinations.settings, icon: Icons.settings, label: 'Settings'),
];

class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      final logMessage = message;
      debugPrint(logMessage);
    }
  }
}
