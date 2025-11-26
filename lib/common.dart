import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/Providers/authentication.dart';

// --- Navigation Config ---

enum NavigationDestinations {
  login,
  home,
  route,
  settings,
  admin,
}

int selectedIndex = 0;

final List<NavigationItem> appDestinations = [
  NavigationItem(
      destination: NavigationDestinations.home,
      icon: Icons.home,
      label: 'Home'),
  NavigationItem(
      destination: NavigationDestinations.route,
      icon: Icons.route,
      label: 'Route'),
  NavigationItem(
      destination: NavigationDestinations.settings,
      icon: Icons.settings,
      label: 'Settings'),
];

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

// --- Route Definitions ---

final List<Widget> newRoutes = [
  const HomePage(),
  const RouteSelect(),
  const SettingPage(),
  const AdminPage(),
  const ErrorScreen(),
  const AuthScreen(),
];

// final Map<String, WidgetBuilder> routes = {
//   AppRoutes.login: (context) => AuthScreen(),
//   AppRoutes.route: (context) => AppLayout(),
//   AppRoutes.home: (context) => AppLayout(),
//   AppRoutes.settings: (context) => AppLayout(),
//   AppRoutes.admin: (context) => AppLayout(),
// };

// --- App Bar Helper ---


// --- Utility Classes ---

/// A utility class for creating a custom SnackBar.
class CustomSnackBar {
  /// Shows a custom SnackBar.
  static void show(BuildContext context, String text, {VoidCallback? onUndo}) {
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
        action: onUndo != null
            ? SnackBarAction(
                label: "Undo",
                onPressed: onUndo,
              )
            : null,
        duration: const Duration(seconds: 3),
      ),
    );
    HapticFeedback.lightImpact();
  }
}

/// A utility class for handling user logout.
class LogoutUser {
  /// Handles signing out the user and navigating to the login screen.
  static void execute(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const AuthScreen();
    }));
  }
}

/// A utility class for logging and crash reporting.
class AppLogger {
  static FirebaseCrashlytics? _crashlytics;

  /// Initialize the logger with the Crashlytics instance.
  static void initialize(FirebaseCrashlytics instance) {
    _crashlytics = instance;
  }

  static void onlyLocal(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Legacy log method.
  /// Consider migrating to info(), warn(), or error() for more specific context.
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
    // Log to Crashlytics as a breadcrumb
    if (!kIsWeb) {
      _crashlytics?.log(message);
    }
  }

  /// For simple informational messages.
  static void info(String message) {
    if (kDebugMode) {
      debugPrint("ℹ️ [INFO] $message");
    }
    // Log to Crashlytics as a breadcrumb
    if (!kIsWeb) {
      _crashlytics?.log("[INFO] $message");
    }
  }

  /// For warnings that don't stop the app.
  static void warn(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint("⚠️ [WARN] $message");
      if (error != null) {
        debugPrint(error.toString());
      }
      if (stack != null) {
        debugPrint(stack.toString());
      }
    }
    // Log to Crashlytics as a breadcrumb
    if (!kIsWeb) {
      _crashlytics?.log("[WARN] $message");
    }
  }

  /// For errors that should be reported as non-fatal issues.
  static void error(String reason, Object error, [StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint("🔥 [ERROR] $reason");
      debugPrint(error.toString());
      if (stack != null) {
        debugPrint(stack.toString());
      }
    }

    // Log the error to Crashlytics. This will show up as a
    // "non-fatal" issue in your Firebase dashboard.
    if (!kIsWeb) {
      _crashlytics?.recordError(
        error,
        stack,
        reason: reason,
        fatal: false, // false because the app isn't crashing
      );
    }
  }
}
