import 'package:connectivity_plus/connectivity_plus.dart' show Connectivity, ConnectivityResult;
import 'package:firebase_analytics/firebase_analytics.dart' show FirebaseAnalytics, FirebaseAnalyticsObserver;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_crashlytics/firebase_crashlytics.dart' show FirebaseCrashlytics;
import 'package:flutter/foundation.dart' show kIsWeb, PlatformDispatcher, TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart' show InternetCheckOption, InternetConnection;

import 'package:nextbus/pages/pages.dart' show ErrorScreen;
import 'package:nextbus/providers/providers.dart';
import 'package:nextbus/common.dart' show AppLogger;
import 'package:nextbus/config.dart' show Config;
import 'package:nextbus/entry.dart' show NextBusApp;
import 'package:provider/provider.dart' show ChangeNotifierProvider, MultiProvider;

void main() async {
  // Ensure bindings are initialized before doing anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app with the initializer widget
  runApp(const AppInitializer());
}

enum AppStatus { loading, success, error }

/// This widget will handle the async initialization and show the correct UI
/// based on the state (loading, error, or success).
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppStatus _status = AppStatus.loading;
  String _errorTitle = "";
  String _errorMessage = "";

  // Define analytics and observer here as 'late final'
  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;
  late final User? _initialUser;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Sends a non-blocking request to wake up the server.
  /// We don't await this in the main init logic.
  Future<void> _wakeUpServer() async {
    try {
      // Use your custom instance here, with a short timeout.
      final connection = InternetConnection.createInstance(
        checkInterval: const Duration(seconds: 60), // Give it 60s to wake up
        customCheckOptions: [
          InternetCheckOption(
            // UPDATED: Use Config.apiUrl to ping the correct server
            uri: Uri.parse(Config.apiUrl),
          ),
        ],
      );

      // We 'await' it here, but this function itself is not
      // awaited in _initializeApp, so it won't block startup.
      await connection.hasInternetAccess;
      AppLogger.onlyLocal("Server wake-up ping sent to ${Config.apiUrl}");
    } catch (e) {
      // This is not a critical error, so we just log it.
      // The server will just wake up on the first "real" API call.
      AppLogger.onlyLocal("Server wake-up ping failed or timed out: $e");
    }
  }

  /// Runs all initialization logic and updates the state.
  Future<void> _initializeApp() async {
    // Set state to loading when retrying
    if (mounted) {
      setState(() {
        _status = AppStatus.loading;
      });
    }

    // "No Wi-Fi/Mobile" Check
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      AppLogger.onlyLocal("No Internet Connection (Instant Check)");
      if (mounted) {
        setState(() {
          _status = AppStatus.error;
          _errorTitle = "No Connection";
          _errorMessage = "Please check your network settings and try again.";
        });
      }
      return;
    }

    // Real "Has Internet" Check (pings Google/Cloudflare by default)
    final bool isConnected = await InternetConnection().hasInternetAccess;

    if (!isConnected) {
      AppLogger.onlyLocal("No Internet Access");
      if (mounted) {
        setState(() {
          _status = AppStatus.error;
          _errorTitle = "No Internet Access";
          _errorMessage = "Please check your internet connection and try again.";
        });
      }
      return;
    }

    // Wake up the server
    _wakeUpServer();

    // Set app orientation
    if (TargetPlatform.android == defaultTargetPlatform) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    // Set Up Firebase and Crashlytics
    try {

      // --- FIX START: Check for existing instance ---
      if (Firebase.apps.isEmpty) {
        // Only initialize if no apps exist
        await Firebase.initializeApp(options: Config.firebaseOptions);
        AppLogger.onlyLocal("Firebase initialized successfully.");
      } else {
        // If already initialized (e.g. by Android native layer or Hot Restart), use existing
        AppLogger.onlyLocal("Firebase was already initialized. Using existing instance.");
      }

      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);

      // Initialize Crashlytics right after Firebase
      final crashlytics = FirebaseCrashlytics.instance;

      if (!kIsWeb) {
        // Crashlytics Error Handlers for non-web platforms
        FlutterError.onError = (errorDetails) {
          crashlytics.recordFlutterFatalError(errorDetails);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          crashlytics.recordError(error, stack, fatal: true);
          return true;
        };
      }
      AppLogger.initialize(crashlytics);
    } catch (e) {
      AppLogger.onlyLocal("error : $e");
      if (mounted) {
        setState(() {
          _status = AppStatus.error;
          _errorTitle = "Failed to Initialize Firebase";
          _errorMessage = "An error occurred while connecting to our services.";
        });
      }
      return;
    }

    // Get Initial Auth State
    _initialUser = await FirebaseAuth.instance.authStateChanges().first;

    // If all successful
    if (mounted) {
      setState(() {
        _status = AppStatus.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case AppStatus.loading:
        // Show a simple loading screen
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      case AppStatus.error:
        // Show the error screen with a retry button
        return ErrorScreen(
          title: _errorTitle,
          message: _errorMessage,
          onRetry:
              _initializeApp, // Pass the init function as the retry callback
        );
      case AppStatus.success:
        // Show the main app
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthService()),
            ChangeNotifierProvider(create: (context) => RouteProvider()),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => UserDetails()),
            ChangeNotifierProvider(create: (context) => TimetableProvider()),
            ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
            ChangeNotifierProvider(create: (context) => NavigationProvider()),
          ],
          child: NextBusApp(observer: _observer, initialUser: _initialUser),
        );
    }
  }
}
