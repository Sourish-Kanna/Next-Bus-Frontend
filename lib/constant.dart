import 'package:flutter/material.dart';

final List<Color> seedColorList = [
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.indigo,
  Colors.green
];
final double mobileBreakpoint = 600;
final fallbackColor = seedColorList[0];

final Map<String, String> urls = {
  'addRoute': '/route/add',
  'updateTime': '/timings/update',
  'busRoutes': '/route/routes',
  'busTimes': '/timings/{route}',
  "user": '/user/get-user-details'
};