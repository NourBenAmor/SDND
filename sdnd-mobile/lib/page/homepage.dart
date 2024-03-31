import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:airsafe/page/compte/login_page.dart';
import 'package:airsafe/page/tab_page.dart';

class homePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.yellow[700],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.yellow[700],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Image.asset(
                      'images/img_10.png',
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
                      fontWeight: FontWeight.bold, // Texte en gras
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
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
                      'images/img_11.png',
                      height: 187,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  Text(
                    'Hold your device steady and capture the entire page in one shot. Make sure all corners are visible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Texte en gras
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
                            MaterialPageRoute(builder: (context) => TabPage()),
                          );
                        },
                        child: Text('I\'m Ready To Go'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow[700],
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
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
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
        ],
      ),
    );
  }
}
