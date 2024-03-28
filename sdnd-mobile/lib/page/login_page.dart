import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:airsafe/page/forget_password_page.dart';
import 'package:airsafe/page/signup_page.dart';
import 'package:airsafe/page/commun/page_heading.dart';
import 'package:airsafe/page/commun/custom_form_button.dart';
import 'package:airsafe/page/commun/custom_input_field.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _handleLoginUser(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:7278/api/Account/login');
    final headers = {'Content-Type': 'application/json'};

    print('Username: ${usernameController.text}');
    print('Password: ${passwordController.text}');

    // Check if both username and password are provided
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      print('Username and Password are required');
      return; // Return early if either field is empty
    }

    final body = jsonEncode({
      'username': usernameController.text,
      'password': passwordController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Login successful
        final responseData = jsonDecode(response.body);
        print('Login Successful');
        print('User ID: ${responseData['id']}');
        print('Username: ${responseData['username']}');
        print('Email: ${responseData['email']}');
        print('Token: ${responseData['token']}');

        // Add further logic here (e.g., navigation to home screen)
      } else if (response.statusCode == 400) {
        // Bad request, probably validation error
        print('Failed to login: ${response.body}');
        // Add further error handling logic here (e.g., displaying error message)
      } else {
        // Other errors
        print('Failed to login: ${response.statusCode}');
        // Add further error handling logic here (e.g., displaying error message)
      }
    } catch (e) {
      // Exception occurred during HTTP request
      print('Error during login: $e');
      // Add further error handling logic here (e.g., displaying error message)
    }
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PageHeading(title: 'Log-in'),
                const SizedBox(height: 20),
                CustomInputField(
                  labelText: 'Username',
                  hintText: 'Your username',
                  controller: usernameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Username is required';
                    }
                    return null; // Return null if the input is valid
                  },
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  labelText: 'Password',
                  hintText: 'Your password',
                  obscureText: true,
                  controller: passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    }
                    return null; // Return null if the input is valid
                  },
                ),
                const SizedBox(height: 20),
                CustomFormButton(innerText: 'Login', onPressed: () => _handleLoginUser(context)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPasswordPage())),
                      child: const Text(
                        'Forget password?',
                        style: TextStyle(color: Color(0xff939393), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())),
                      child: const Text(
                        'Sign-up',
                        style: TextStyle(color: Color(0xff748288), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
