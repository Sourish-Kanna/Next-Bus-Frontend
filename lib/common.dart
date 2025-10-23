import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/Providers/authentication.dart';

enum NavigationDestinations {
  login,
  home,
  route,
  settings,
  admin,
}

int selectedIndex = 0;

final List<NavigationItem> appDestinations = [
  NavigationItem(destination: NavigationDestinations.home, icon: Icons.home, label: 'Home'),
  NavigationItem(destination: NavigationDestinations.route, icon: Icons.route, label: 'Route'),
  NavigationItem(destination: NavigationDestinations.settings, icon: Icons.settings, label: 'Settings'),
];

// final Map<String, WidgetBuilder> routes = {
//   AppRoutes.login: (context) => AuthScreen(),
//   AppRoutes.route: (context) => AppLayout(),
//   AppRoutes.home: (context) => AppLayout(),
//   AppRoutes.settings: (context) => AppLayout(),
//   AppRoutes.admin: (context) => AppLayout(),
// };

final List<Widget> newRoutes = [
  const HomePage(),
  const RouteSelect(),
  const SettingPage(),
  const AdminPage(),
  const ErrorScreen(),
  const AuthScreen(),
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
      debugPrint(message);
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

PreferredSizeWidget? appbar(bool isMobile, BuildContext context,{bool isAdmin = false, List<NavigationItem> destination= const []}) {
  return isMobile ? AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    automaticallyImplyLeading: false,
    title: (!isAdmin) ? Text(appDestinations[selectedIndex].label): Text(destination[selectedIndex].label),
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
