import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../helper/keyboard.dart';
import '../../constants.dart';
import '../../home_pageView.dart';


const storage = FlutterSecureStorage();

class SignForm extends StatefulWidget {
  const SignForm({Key? key}) : super(key: key);

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String baseUrl = 'https://10.0.2.2:7278/api';
  bool _isLoading = false; // Flag to track loading state
  bool? remember = false;
  final List<String?> errors = [];

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future<void> _handleLoginUser(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    final url = Uri.parse('$baseUrl/Account/login');
    final headers = {'Content-Type': 'application/json'};

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      addError(error: "Username and Password are required");
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
        String token = responseData['token'];
        await storage.write(key: 'jwt_token', value: token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home_PageView(token: token),
          ),
        );
      } else if (response.statusCode == 400) {
        addError(error: 'Incorrect username or password');
        _showErrorDialog(context, 'Incorrect username or password');
      } else {
        addError(error: 'Failed to login: ${response.statusCode}');
        _showErrorDialog(context, 'Username or Password is incorrect.');
      }
    } catch (e) {
      addError(
          error: 'An error occurred during login. Please try again later.');
      _showErrorDialog(
          context, 'An error occurred during login. Please try again later.');
    }
  }


  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Username",
              labelStyle: TextStyle(color: Colors.yellow.shade800),
              hintText: "Enter your username",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "images/Mail.svg"),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kPassNullError);
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: Colors.yellow.shade800),
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "images/Lock.svg"),
            ),
          ),
          FormError(errors: errors),
          if (_isLoading) CircularProgressIndicator(),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                KeyboardUtil.hideKeyboard(context);
                _handleLoginUser(context);
              }
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}
