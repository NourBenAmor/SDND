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
      backgroundColor: Colors.yellow, // Set your preferred background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/icon.png', // Replace 'icon.png' with your image path
              width: 200, // Set the width as needed
              height: 200, // Set the height as needed
            ),
            SizedBox(height: 20),
            Text(
              'InnoScan', // Set your app name
              style: TextStyle(
                color: Colors.white, // Set your preferred text color
                fontSize: 24, // Set the font size as needed
                fontWeight: FontWeight.bold, // Set the font weight as needed
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Add a CircularProgressIndicator
          ],
        ),
      ),
    );
  }
}
