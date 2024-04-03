import 'package:airsafe/page/homepage.dart';

import 'package:flutter/material.dart';
// Importer la nouvelle page WelcomePage

void main() {
  runApp(const AirSafeApp());
}

class AirSafeApp extends StatelessWidget {
  const AirSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'airsafe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const homePage(),
    );
  }
}
