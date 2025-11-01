import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, PlatformDispatcher;
import 'package:provider/provider.dart' show ChangeNotifierProvider, MultiProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;

import 'package:nextbus/Providers/providers.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/start.dart';

void main() async {
  // Ensure bindings are initialized before doing anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app with the initializer widget
  runApp(AppInitializer());
}

enum AppStatus { loading, success, error }

/// This widget will handle the async initialization and show the correct UI
/// based on the state (loading, error, or success).
class AppInitializer extends StatefulWidget {
  // Removed observer from constructor
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

  /// Runs all initialization logic and updates the state.
  Future<void> _initializeApp() async {
    // Set state to loading when retrying
    if (mounted) {
      setState(() {
        _status = AppStatus.loading;
      });
    }

    // 1. Internet connection check
    final connection = InternetConnection.createInstance(
      // enableStrictCheck: true,
      customCheckOptions: [
        InternetCheckOption(
            uri: Uri.parse(const String.fromEnvironment('API_LINK'))),
      ],
    );

    final bool isConnected = await connection.hasInternetAccess;

    if (!isConnected) {
      AppLogger.onlyLocal("No Internet Connection");
      if (mounted) {
        setState(() {
          _status = AppStatus.error;
          _errorTitle = "No Internet Connection";
          _errorMessage = "Please check your internet connection and try again.";
        });
      }
      return;
    }

    // 2. Set app orientation
    if (TargetPlatform.android == defaultTargetPlatform) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    // 3. Set Up Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);

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

    // 4. Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // 5. Get Initial Auth State
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
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      case AppStatus.error:
      // Show the error screen with a retry button
        return ErrorScreen(
          title: _errorTitle,
          message: _errorMessage,
          onRetry: _initializeApp, // Pass the init function as the retry callback
        );
      case AppStatus.success:
      // Show the main app
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthService()),
            ChangeNotifierProvider(create: (context) => BusTimingList()),
            ChangeNotifierProvider(create: (context) => RouteProvider()),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => UserDetails()),
            ChangeNotifierProvider(create: (context) => TimetableProvider()),
          ],
          // Pass the initialized observer and user to NextBusApp
          child: NextBusApp(
            observer: _observer,
            initialUser: _initialUser,
          ),
        );
    }
  }
}
