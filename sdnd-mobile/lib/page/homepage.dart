import 'package:airsafe/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:airsafe/page/scan.dart';
import 'dart:io';

import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.yellow[700],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.yellow[700],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: Image.asset(
                        'assets/images/img_10.png',
                        height: 187,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Text(
                      'Please follow the instructions below to capture the entire page',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: Image.asset(
                        'assets/images/img_11.png',
                        height: 187,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Text(
                      'Hold your device steady and capture the entire page in one shot. Make sure all corners are visible',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Text('I\'m Ready To Go'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellow[700],
                            onPrimary: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Quitter l'application lorsqu'on appuie sur "Not Now"
                            if (Platform.isAndroid || Platform.isIOS) {
                              SystemNavigator.pop();
                            }
                          },
                          child: Text('Not Now'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // Couleur du bouton "Not Now"
                            onPrimary: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
