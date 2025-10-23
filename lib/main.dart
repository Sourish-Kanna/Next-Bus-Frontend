import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Brightness, DeviceOrientation, SystemChrome;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:dynamic_color/dynamic_color.dart' show ColorSchemeHarmonization, DynamicColorBuilder;
import 'package:provider/provider.dart' show ChangeNotifierProvider, Consumer, MultiProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:nextbus/Providers/providers.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/app_layout.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Internet connection check
  final connection = InternetConnection.createInstance(
    enableStrictCheck: true,
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
  // Run App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => BusTimingList()),
        ChangeNotifierProvider(create: (context) => RouteProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserDetails()),
        ChangeNotifierProvider(create: (context) => Timetable()),
      ],
      child: const NextBusApp()
    ),
  );
}

class NextBusApp extends StatelessWidget {
  const NextBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            final ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            // Step 1: Generate the initial color schemes
            if (themeProvider.isDynamicColor && lightDynamic != null && darkDynamic != null) {
              lightColorScheme = lightDynamic.harmonized();
              darkColorScheme = darkDynamic.harmonized();
            } else {
              final seed = themeProvider.selectedSeedColor ?? fallbackColor;
              lightColorScheme = ColorScheme.fromSeed(seedColor: seed);
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: seed,
                brightness: Brightness.dark,
              );
            }
          // Step 2: Define the base theme
          // final baseTheme = ThemeData(useMaterial3: true, useSystemColors: true);

          // Step 3: Build the MaterialApp
          return MaterialApp(
            title: 'Next Bus',
            theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
            darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: true,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    // User is logged in
                    return AppLayout();
                  } else {
                    // User is not logged in
                    return const AuthScreen();
                  }
                },
              ),
            );
          }
        );
      }
    );
  }
}
