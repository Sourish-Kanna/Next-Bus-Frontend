import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart' show ColorSchemeHarmonization, DynamicColorBuilder;
import 'package:provider/provider.dart' show Consumer;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:nextbus/Providers/providers.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/app_layout.dart';
import 'package:nextbus/constant.dart';

class NextBusApp extends StatelessWidget {
  final FirebaseAnalyticsObserver observer;
  final User? initialUser; // Accept the initial user

  const NextBusApp({
    super.key,
    required this.observer,
    required this.initialUser, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            final ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            // Step 1: Generate the initial color schemes
            if (themeProvider.isDynamicColor &&
                lightDynamic != null &&
                darkDynamic != null) {
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
              theme:
              ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
              darkTheme:
              ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
              themeMode: themeProvider.themeMode,
              debugShowCheckedModeBanner: true,
              navigatorObservers: [
                observer,
              ],
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                initialData: initialUser, // Use the pre-fetched user data
                builder: (context, snapshot) {
                  // We no longer need the 'waiting' check, as initialData is provided.
                  final User? user = snapshot.data;

                  if (user != null) {
                    // User is logged in
                    return AppLayout();
                  } else {
                    // User is not logged in
                    return const AuthScreen();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
