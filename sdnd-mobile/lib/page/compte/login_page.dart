import 'dart:convert';
import 'package:airsafe/page/UploadDocumentForm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:airsafe/page/commun/custom_input_field.dart';
import 'package:airsafe/page/compte/forget_password_page.dart';
import 'package:airsafe/page/compte/signup_page.dart';
import 'package:airsafe/page/commun/page_heading.dart';
import 'package:airsafe/page/commun/custom_form_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home_page.dart';

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
        final responseData = jsonDecode(response.body);
        print('User ID: ${responseData['id']}');
        print('Username: ${responseData['username']}');
        print('Email: ${responseData['email']}');
        print('Token: ${responseData['token']}');
        String token = responseData['token']; // Extract the token
        await storage.write(key: 'jwt_token', value: token);

        // Show snackbar indicating successful login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Align(
              alignment: Alignment.center,
              child: Text(
                'Login successful',
                style: TextStyle(color: Colors.white),
              ),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            padding: EdgeInsets.symmetric(vertical: 15.0),
          ),
        );

        // Delay navigation to allow SnackBar display
        await Future.delayed(Duration(seconds: 2)); // Adjust delay as needed

        // Navigate to homepage with the token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(token: token), // Pass token to HomePage
          ),
        );
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
