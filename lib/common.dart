import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
