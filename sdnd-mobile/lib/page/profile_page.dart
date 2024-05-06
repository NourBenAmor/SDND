import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String token;

  User(this.token, {required this.id, required this.username, required this.email});
}

class ProfilePage extends StatefulWidget {
  final String token;

  ProfilePage({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(widget.token);
  }

  Future<void> _loadCurrentUser(String token) async {
    if (token.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final HttpClient httpClient = HttpClient();
      final Uri uri = Uri.parse('https://10.0.2.2:7278/api/Account/me');
      final HttpClientRequest request = await httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final HttpClientResponse response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final String responseBody = await response.transform(utf8.decoder)
            .join();
        final userData = jsonDecode(responseBody);
        if (userData != null && userData is Map<String, dynamic>) {
          final String id = userData['id'] ?? '';
          final String username = userData['userName'] ?? '';
          final String email = userData['email'] ?? '';
          setState(() {
            _currentUser =
                User(token, id: id, username: username, email: email);
            _isLoading = false;
          });
        }
      } else if (response.statusCode == HttpStatus.unauthorized) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unauthorized';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${response.reasonPhrase}';
        });
      }

      httpClient.close();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading user data: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 4,
              child: Image.asset(
                'images/image-document.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('images/compte.png'),
                  ),
                  SizedBox(height: 20),
                  _currentUser != null
                      ? Column(
                    children: [
                      SizedBox(height: 20),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        style: TextStyle(fontSize: 18),
                        initialValue: _currentUser!.username,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                        style: TextStyle(fontSize: 18),
                        initialValue: _currentUser!.email,
                      ),

                    ],
                  )
                      : _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                    _errorMessage.isNotEmpty ? _errorMessage : 'Error loading user data',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}