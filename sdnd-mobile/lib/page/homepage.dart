import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import '../View/sign_in/sign_in_screen.dart';



class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Image.asset(
                      'images/img_10.png',
                      height: 187,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const Text(
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Image.asset(
                      'images/img_11.png',
                      height: 187,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const Text(
                    'Hold your device steady and capture the entire page in one shot. Make sure all corners are visible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Texte en gras
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignInScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                        child: const Text('I\'m Ready To Go'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Quitter l'application lorsqu'on appuie sur "Not Now"
                          if (Platform.isAndroid || Platform.isIOS) {
                            SystemNavigator.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                        child: const Text('Not Now'),
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
