import 'dart:convert';

import 'package:airsafe/View/DashboardView.dart';
import 'package:airsafe/View/home_pageView.dart';
import 'package:airsafe/page/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:airsafe/page/commun/custom_input_field.dart';
import 'package:airsafe/page/compte/forget_password_page.dart';
import 'package:airsafe/page/compte/signup_page.dart';
import 'package:airsafe/page/commun/page_heading.dart';
import 'package:airsafe/page/commun/custom_form_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const storage = FlutterSecureStorage();
class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(), // You can customize the loading indicator here
    );
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String baseUrl = 'https://10.0.2.2:7278/api';
  bool _isLoading = false; // Flag to track loading state

  Future<void> _handleLoginUser(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    final url = Uri.parse('$baseUrl/Account/login');
    final headers = {'Content-Type': 'application/json'};

    // Check if both username and password are provided
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      print('Username and Password are required');
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      return; // Return early if either field is empty
    }

    final body = jsonEncode({
      'username': usernameController.text,
      'password': passwordController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      setState(() {
        _isLoading = false; // Hide loading indicator after response
      });
      if (response.statusCode == 200) {
        // Handle successful login
        final responseData = jsonDecode(response.body);
        print('User ID: ${responseData['id']}');
        print('Username: ${responseData['username']}');
        print('Email: ${responseData['email']}');
        print('Token: ${responseData['token']}');
        String token = responseData['token']; // Extract the token
        await storage.write(key: 'jwt_token', value: token);

        // Navigate to homepage with the token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home_PageView(token: token), // Pass token to HomePage
          ),
        );
      } else if (response.statusCode == 400) {
        // Bad request, probably validation error
        print('Failed to login: ${response.body}');
        // Show error message in pop-up dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Incorrect username or password'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        // Add further error handling logic here (e.g., displaying error message)
      } else {
        // Other errors
        print('Failed to login: ${response.statusCode}');
        // Show error message in pop-up dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Username or Password is incorrect.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        // Add further error handling logic here (e.g., displaying error message)
      }
    } catch (e) {
      // Exception occurred during HTTP request
      print('Error during login: $e');
      // Show error message in pop-up dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred during login. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
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
                  suffixIcon: true,

                ),
                const SizedBox(height: 20),
                CustomFormButton(
                    innerText: 'Login',
                    onPressed: () => _handleLoginUser(context)),
                const SizedBox(height: 18),
                if (_isLoading) LoadingWidget(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ForgetPasswordPage())),
                      child: const Text(
                        'Forget password?',
                        style: TextStyle(
                            color: Color(0xff939393),
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupPage())),
                      child: const Text(
                        'Sign-up',
                        style: TextStyle(
                            color: Color(0xff748288),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
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
