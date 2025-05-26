import 'package:flutter/material.dart';
import 'package:mapapps/home_sereen.dart';

import 'gps_screen.dart';
import 'maps_screen.dart';

void main() {
  runApp(const GoogleMapsApp());
}
class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/gps': (context) => GpsScreen(),
        '/map': (context) => MapsScreen(),
      },
      home: const HomeScreen(),
    );
  }
}