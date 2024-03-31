import 'package:airsafe/page/homepage.dart';

import 'package:airsafe/page/tab_page.dart';
import 'package:flutter/material.dart';
import 'package:airsafe/page/synchronisation.dart'; // Importer la nouvelle page WelcomePage

void main() {
  runApp(AirSafeApp());
}

class AirSafeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'airsafe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homePage(),
    );
  }
}
