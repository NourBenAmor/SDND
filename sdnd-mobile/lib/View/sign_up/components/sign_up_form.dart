import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../constants.dart';
import '../../sign_in/sign_in_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? confirmPassword;
  String? name;
  bool remember = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  void _handleSignupUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );

      final userData = {
        'Username': _nameController.text,
        'Email': _emailController.text,
        'Password': _passwordController.text,
      };

      final jsonData = jsonEncode(userData);

      // Validate username length
      if (_nameController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Username must be at least 6 characters long.')),
        );
        return;
      }

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
            MaterialPageRoute(builder: (context) => SignInScreen()),
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

    if (password.length < 8) {
      errors.add("Password must be at least 8 characters long.");
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
      errors.add("Password must contain at least one special character.");
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildTextFormField(
            controller: _nameController,
            labelText: "Name",
            hintText: "Enter your name",
            svgIcon: "assets/icons/User.svg",
            validator: (value) {
              if (value!.isEmpty) {
                return "Name can't be empty";
              } else if (value.length < 6) {
                return "Username must be at least 6 characters long.";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            controller: _emailController,
            labelText: "Email",
            hintText: "Enter your email",
            svgIcon: "assets/icons/Mail.svg",
            validator: (value) {
              if (value!.isEmpty) {
                return "Email can't be empty";
              } else if (!EmailValidator.validate(value)) {
                return "Enter a valid email";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            controller: _passwordController,
            labelText: "Password",
            hintText: "Enter your password",
            svgIcon: "assets/icons/Lock.svg",
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return "Password can't be empty";
              }
              final passwordErrors = _validatePassword(value);
              if (passwordErrors.isNotEmpty) {
                return passwordErrors.join('\n');
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            controller: _confirmPasswordController,
            labelText: "Confirm Password",
            hintText: "Re-enter your password",
            svgIcon: "assets/icons/Lock.svg",
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return "Confirm Password can't be empty";
              } else if (value != _passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSignupUser,
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  TextFormField buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String svgIcon,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(color: Colors.yellow.shade800), // Set label text color

        suffixIcon: CustomSurffixIcon(svgIcon: svgIcon),
      ),
    );
  }
}
