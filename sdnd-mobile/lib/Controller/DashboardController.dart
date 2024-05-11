import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../Model/DashboardData.dart';
import '../Model/document_upload_stats.dart';

class DashboardController {
  Future<DashboardData> fetchFileData(String token) async {
    String url = 'https://10.0.2.2:7278/api/File/files/total-count';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        int totalFiles = int.parse(response.body);
        return DashboardData(
          myTask: 0,
          totalDocuments: 0,
          totalFiles: totalFiles,
          totalUsers: 0,

        );
      } else {
        throw Exception('Failed to load file data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch file data: $error');
    }
  }

  Future<DashboardData> fetchUserData(String token) async {
    String url = 'https://10.0.2.2:7278/api/Account/users/total-count'; // Update with your API endpoint for user data
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        int totalUsers = int.parse(response.body);
        return DashboardData(
          myTask: 0,
          totalDocuments: 0,
          totalFiles: 0,
          totalUsers: totalUsers, // Set the totalUsers field to the fetched value
        );
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch user data: $error');
    }
  }


  Future<Map<String, dynamic>> fetchDocumentStatistics(String token) async {
    String url = 'https://10.0.2.2:7278/api/Document/statistics';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load document statistics: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch document statistics: $error');
    }
  }


  Future<List<dynamic>> fetchDocumentsCountByStatus(String token) async {
    String url = 'https://10.0.2.2:7278/api/Document/status/count';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load documents count by status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch documents count by status: $error');
    }
  }
  Future<DocumentUploadStats> fetchDocumentUploadStats(String token) async {
    final url = 'https://10.0.2.2:7278/api/Document/added-document-stats';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Document upload stats response: $data'); // Log the response data
        return DocumentUploadStats.fromJson(data);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching document upload stats: $error');
      throw Exception('Failed to fetch document upload stats: $error');
    }
  }


}