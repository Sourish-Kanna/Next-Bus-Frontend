import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/app_layout.dart';
import 'package:nextbus/Providers/authentication.dart';

enum NavigationDestinations {
  login,
  home,
  route,
  settings,
}

final List<NavigationItem> appDestinations = [
  NavigationItem(destination: NavigationDestinations.home, icon: Icons.home, label: 'Home'),
  NavigationItem(destination: NavigationDestinations.route, icon: Icons.route, label: 'Route'),
  NavigationItem(destination: NavigationDestinations.settings, icon: Icons.settings, label: 'Settings'),
];

final Map<String, WidgetBuilder> routes = {
  AppRoutes.login: (context) => AuthScreen(),
  AppRoutes.route: (context) => AppLayout(selectedIndex: 1, child: RouteSelect()),
  AppRoutes.home: (context) => AppLayout(selectedIndex: 0, child: HomePage()),
  AppRoutes.settings: (context) => AppLayout(selectedIndex: 2, child: SettingPage()),
};

final List<Widget> new_routes = [
  AuthScreen(),
  RouteSelect(),
  HomePage(),
  SettingPage(),
  ErrorScreen(),
  AdminPage(),
];

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


class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      final logMessage = message;
      debugPrint(logMessage);
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

class AppRoutes {
  static const String home = '/home'; // Often the initial route
  static const String login = '/login';
  static const String route = '/route';
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
      case NavigationDestinations.settings:
        return settings;
    }
  }
}


Widget logoutButton(BuildContext context, VoidCallback logoutUser) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: ElevatedButton.icon(
      onPressed: () {logoutUser();},
      icon: Icon(
        Icons.logout,
      ),
      label: Text("Logout"),
    ),
  );
}

PreferredSizeWidget? appbar(bool isMobile, BuildContext context, AppLayout widget) {
  return isMobile ? AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    automaticallyImplyLeading: false,
    title: Text(appDestinations[widget.selectedIndex].label),
    // Label from current selected item
    leading: Builder(
      builder: (context) =>
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
    ),
  ): null;
}
