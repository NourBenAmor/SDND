import 'package:flutter/material.dart';


import '../Controller/UserController.dart';
import '../Model/User.dart';

class ProfilePageView extends StatefulWidget {
  final String token;

  ProfilePageView({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageView> {
  final UserController _userController = UserController();
  User? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _userController.getCurrentUser(widget.token);
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
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
                    backgroundImage: AssetImage('images/profile_image.jpg'),
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : _currentUser != null
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
