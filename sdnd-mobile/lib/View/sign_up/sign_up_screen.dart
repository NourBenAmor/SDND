import 'package:flutter/material.dart';
import '../constants.dart';
import 'components/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                   Text("Register Account",style: TextStyle(
                  color: Colors.yellow.shade800,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
            ),
                  const Text(
                    "Complete your details or continue \nwith social media",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const SignUpForm(),
                  const SizedBox(height: 16),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}