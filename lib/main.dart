import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Brightness, DeviceOrientation, SystemChrome;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:dynamic_color/dynamic_color.dart' show ColorSchemeHarmonization, DynamicColorBuilder;
import 'package:provider/provider.dart' show ChangeNotifierProvider, Consumer, MultiProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;

import 'package:nextbus/Providers/providers.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/app_layout.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set app orientation to portrait mode only if platform is Android
  if (TargetPlatform.android == defaultTargetPlatform) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    AppLogger.log("error : $e");
    runApp(const ErrorScreen());
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => BusTimingList()),
        ChangeNotifierProvider(create: (context) => RouteProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserDetails()),
      ],
      child: NextBusApp()
    ),
  );
}

class NextBusApp extends StatefulWidget{
  const NextBusApp({super.key});

  @override
  State<StatefulWidget> createState() => NextBusAppState();
}

class NextBusAppState extends State<NextBusApp> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return DynamicColorBuilder(
              builder: (lightDynamic, darkDynamic) {
                ColorScheme lightScheme;
                ColorScheme darkScheme;

                if (themeProvider.isDynamicColor) {
                  lightScheme = lightDynamic?.harmonized() ??
                      ColorScheme.fromSeed(seedColor: fallbackColor); // Fallback
                  darkScheme = darkDynamic?.harmonized() ??
                      ColorScheme.fromSeed(seedColor: fallbackColor, // Fallback
                        brightness: Brightness.dark,);
                } else {
                  // Use the selected seed color or a default if null
                  final seed = themeProvider.selectedSeedColor ??
                      fallbackColor;
                  lightScheme = ColorScheme.fromSeed(seedColor: seed);
                  darkScheme = ColorScheme.fromSeed(seedColor: seed,
                    brightness: Brightness.dark,
                  );
                }

                return MaterialApp(
                  title: 'Next Bus',
                  theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
                  darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
                  themeMode: themeProvider.themeMode,
                  debugShowCheckedModeBanner: true,
                  routes: routes,
                  onUnknownRoute: (_) {
                    return MaterialPageRoute(builder: (_) => ErrorScreen());
                  },
                  home: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return AppLayout(selectedIndex: 0,
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        // User is logged in
                        return AppLayout(selectedIndex: 0,
                            child: Center(child: HomePage()));
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
