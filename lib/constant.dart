import 'package:flutter/material.dart';
import 'package:nextbus/pages/pages.dart';

final List<Color> seedColorList = [
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.indigo,
  Colors.green
];

final double mobileBreakpoint = 600;
final fallbackColor = seedColorList[0];
int selectedIndex = 0;


final Map<String, String> urls = {
  'addRoute': '/route/add',
  'updateTime': '/timings/update',
  'busRoutes': '/route/routes',
  'busTimes': '/timings/{route}',
  "user": '/user/get-user-details'
};

enum NavigationDestinations {
  login,
  home,
  route,
  settings,
  admin,
}

final routesPage = {
  "home": HomePage(),
  "route": RouteSelect(),
  "settings": SettingPage(),
  "admin": AdminPage(),
  "login": AuthScreen(),
};