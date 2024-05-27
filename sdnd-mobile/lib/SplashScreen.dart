import 'dart:async';
import 'package:airsafe/page/homepage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3), // Change the duration as needed
          () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => homePage()), // Navigate to your main screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change the background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/icon.png', // Replace 'icon.png' with your image path
              width: 400, // Increase the width as needed
              height: 400, // Increase the height as needed
            ),

            CircularProgressIndicator(), // Add a CircularProgressIndicator
          ],
        ),
      ),
    );
  }
}