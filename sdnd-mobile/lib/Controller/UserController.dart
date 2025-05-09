import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../Model/User.dart';


class UserController {
  Future<User?> getCurrentUser(String token) async {
    if (token.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7278/api/Account/me'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == HttpStatus.ok) {
        final userData = jsonDecode(response.body);
        if (userData != null && userData is Map<String, dynamic>) {
          final String id = userData['id'] ?? '';
          final String username = userData['userName'] ?? '';
          final String email = userData['email'] ?? '';
          return User(token, id: id, username: username, email: email);
        }
      }
      return null;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }
}
