import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, PlatformDispatcher;
import 'package:provider/provider.dart' show ChangeNotifierProvider, MultiProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:nextbus/Providers/providers.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/start.dart';

// static instances for Analytics
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Internet connection check
  final connection = InternetConnection.createInstance(
    // enableStrictCheck: true,
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse(const String.fromEnvironment('API_LINK'))),
    ],
  );

  final bool isConnected = await connection.hasInternetAccess;

  if (!isConnected) {
    AppLogger.log("No Internet Connection");
    runApp(const ErrorScreen(
      title: "No Internet Connection",
      message: "Please check your internet connection and try again.",
    ));
    return;
  }

  // Set app orientation to portrait mode only if platform is Android
  if (TargetPlatform.android == defaultTargetPlatform) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Set Up Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    AppLogger.log("error : $e");
    runApp(const ErrorScreen(
      title: "Failed to Initialize Firebase",
      message: "An error occurred while connecting to our services.",
    ));
    return;
  }

  // Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance
        .recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance
        .recordError(error, stack, fatal: true);
    return true;
  };

  // Run App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => BusTimingList()),
        ChangeNotifierProvider(create: (context) => RouteProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserDetails()),
        ChangeNotifierProvider(create: (context) => TimetableProvider()),
      ],
        child: NextBusApp(observer: observer)
    ),
  );
}
