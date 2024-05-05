
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:airsafe/page/commun/page_heading.dart';

import 'package:airsafe/page/commun/custom_form_button.dart';
import 'package:airsafe/page/commun/custom_input_field.dart';

import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _signupFormKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Form(
            key: _signupFormKey,
            child: Column(
              children: [
                Container(

                  child: Column(
                    children: [
                      const PageHeading(title: 'Sign-up',),
                      const SizedBox(height: 16,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            CustomInputField(
                              labelText: 'Name',
                              hintText: 'Your name',
                              isDense: true,
                              controller: _nameController,
                              validator: (textValue) {
                                if (textValue == null || textValue.isEmpty) {
                                  return 'Name field is required!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16,),
                            CustomInputField(
                              labelText: 'Email',
                              hintText: 'Your email id',
                              isDense: true,
                              controller: _emailController,
                              validator: (textValue) {
                                if (textValue == null || textValue.isEmpty) {
                                  return 'Email is required!';
                                }
                                if (!EmailValidator.validate(textValue)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16,),
                            CustomInputField(
                              labelText: 'Password',
                              hintText: 'Your password',
                              isDense: true,
                              obscureText: true,
                              controller: _passwordController,
                              validator: (textValue) {
                                if (textValue == null || textValue.isEmpty) {
                                  return 'Password is required!';
                                }
                                return null;
                              },
                              suffixIcon: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8,), // Add some spacing
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '- At least 6 characters long',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            '- Contains at least one lowercase letter',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            '- Contains at least one uppercase letter',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            '- Contains at least one digit',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            '- Contains at least one non-alphanumeric character',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22,),
                      CustomFormButton(innerText: 'Signup', onPressed: _handleSignupUser,),
                      const SizedBox(height: 18,),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Already have an account ? ', style: TextStyle(fontSize: 13, color: Color(0xff939393), fontWeight: FontWeight.bold),),
                            GestureDetector(
                              onTap: () => {
                                //Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()))
                              },
                              child: const Text('Log-in', style: TextStyle(fontSize: 15, color: Color(0xff748288), fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _handleSignupUser() async {
    if (_signupFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );

      final userData = {
        'Username': _nameController.text,
        'Email': _emailController.text,
        'Password': _passwordController.text,
      };

      final jsonData = jsonEncode(userData);

      // Validate password requirements
      final passwordErrors = _validatePassword(_passwordController.text);
      if (passwordErrors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(passwordErrors.join('\n'))),
        );
        return; // Stop execution if password requirements are not met
      }

      try {
        final response = await http.post(
          Uri.parse('https://10.0.2.2:7278/api/Account/register'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Align(
                alignment: Alignment.center,
                child: Text(
                  'Sign Up successful',
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
          await Future.delayed(Duration(seconds: 2));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.body}')),
          );
        }
      } catch (error) {
        print('Error during registration: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during registration: $error')),
        );
      }
    }
  }

  List<String> _validatePassword(String password) {
    final errors = <String>[];

    if (password.length < 6) {
      errors.add("Password must be at least 6 characters long.");
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add("Password must contain at least one lowercase letter.");
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add("Password must contain at least one uppercase letter.");
    }

    if (!password.contains(RegExp(r'\d'))) {
      errors.add("Password must contain at least one digit.");
    }

    if (!password.contains(RegExp(r'\W'))) {
      errors.add("Password must contain at least one non-alphanumeric character.");
    }

    return errors;
  }


}
