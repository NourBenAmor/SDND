import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/Document.dart';
import '../Model/DocumentDetails.dart';
import '../page/file_list.dart';

class DocumentController {
  final String token;
  final BuildContext _context;
  Map<String, String> documentFilesMap = {};

  DocumentController(this.token, this._context);

  Future<List<Document>> fetchDocuments() async {
    List<Document> documents = [];

    final url = Uri.parse('https://10.0.2.2:7278/api/Document/me');

    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        if (responseBody != null && responseBody is List<dynamic>) {
          final List<dynamic> data = responseBody;
          documents = data.map((doc) {
            List<String> files = (doc['files'] as List<dynamic>?)
                ?.map<String>((file) => file['path'].toString())
                .toList() ??
                [];

            return Document(
              id: doc['id'].toString(),
              documentId: doc['documentId'].toString(),
              name: doc['name'],
              description: doc['description'].toString() ?? '',
              ownerId: doc['ownerId'].toString() ?? '',
              addedDate: DateTime.parse(doc['addedDate'].toString()),
              updatedDate: DateTime.parse(doc['updatedDate'].toString()),
              documentState: doc['documentState'].toString(),
              files: files,
            );
          }).toList();
        } else {
          print('Response body from API is null or not a List');
        }
      } else {
        throw Exception(
            'Failed to load documents (Status Code: ${response.statusCode})');
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
    } catch (e) {
      print('Exception: $e');
    }

    return documents;
  }

  Future<void> fetchDocumentFiles(String documentId, String token) async {
    final url = Uri.parse(
        'https://10.0.2.2:7278/api/Document/$documentId/files');
    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonFiles = jsonDecode(response.body);
        final Map<String, String> filesMap = {};
        jsonFiles.forEach((file) {
          final String fileId = file['id'].toString();
          final String fileName = file['name'].toString();
          filesMap[fileId] = fileName;
        });

        documentFilesMap = filesMap;
        print('Fetched document files: $documentFilesMap');

      } else {
        throw Exception(
            'Failed to load document files. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching document files: $e');
    }
  }


  Future<void> openFile(String fileId) async {
    try {
      final String apiUrl =
          'https://10.0.2.2:7278/api/File/view/$fileId'; // Use 'fileId' in the URL
      final http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Create a temporary directory to store the PDF file
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/document.pdf';

        // Write the response body to a file
        await File(filePath).writeAsBytes(response.bodyBytes);

        // Open the PDF file using the PDF viewer plugin
        OpenFile.open(filePath);
      } else {
        throw Exception(
            'Failed to load PDF file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error opening PDF file: $e');
    }
  }

  Future<void> addNewFile(String documentId) async {
    try {
      // Navigate to the file list page to select a file
      String? selectedFilePath = await Navigator.push(
        _context,
        MaterialPageRoute(builder: (context) => ListPDFsScreen(token: token)),
      );

      if (selectedFilePath != null) {
        // Fetch the selected file and upload it to the document
        File selectedFile = File(selectedFilePath);
        await _uploadFileToApi(selectedFile, documentId); // Pass documentId here

        // Fetch updated document files after uploading
        await fetchDocumentFiles(documentId, token);
      } else {
        // User canceled the file picking
        print('User canceled file picking');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }


  Future<void> _uploadFileToApi(File file, String documentId) async {
    try {
      var url = 'https://10.0.2.2:7278/api/File/upload'; // Update the endpoint to match your API

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path, filename: file.path.split('/').last),
      );
      request.fields['DocumentId'] = documentId; // Use the documentId parameter
      request.headers['Authorization'] = 'Bearer $token';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(_context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully', style: TextStyle(color: Colors.green)), // Green for success
          ),
        );
        await fetchDocumentFiles(documentId, token);


        // Save the filename to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? fileNames = prefs.getStringList('pdf_names');
        fileNames ??= []; // If null, initialize to empty list
        fileNames.add(file.path.split('/').last); // Add the filename
        await prefs.setStringList('pdf_names', fileNames); // Save the updated list
      } else {
        ScaffoldMessenger.of(_context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload file. Status code: ${response.statusCode}', style: TextStyle(color: Colors.red)), // Red for error
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: $e', style: TextStyle(color: Colors.red)), // Red for error
        ),
      );
    }
  }

}