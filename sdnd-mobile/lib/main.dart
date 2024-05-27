import 'dart:io';


import 'package:airsafe/page/homepage.dart';

import 'package:flutter/material.dart';

import 'SplashScreen.dart';
// Importer la nouvelle page WelcomePage

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const AirSafeApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class AirSafeApp extends StatelessWidget {
  const AirSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This line removes the debug banner
      title: 'DocuStream',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
