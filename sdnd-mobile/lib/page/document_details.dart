import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart'; // Add this import
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class DocumentDetails extends StatefulWidget {
  final String documentId;
  final String documentName;
  final String documentDescription;
  final String token;

  const DocumentDetails({
    Key? key,
    required this.documentId,
    required this.documentName,
    required this.documentDescription,
    required this.token,
    required List<String> documentFiles,
  }) : super(key: key);

  @override
  _DocumentDetailsState createState() => _DocumentDetailsState();
}

class _DocumentDetailsState extends State<DocumentDetails> {
  Map<String, String> documentFilesMap = {};
  late String _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    fetchDocumentFiles(_token);
  }

  Future<void> fetchDocumentFiles(String token) async {
    final url = Uri.parse(
        'https://10.0.2.2:7278/api/Document/${widget.documentId}/files');
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
        setState(() {
          documentFilesMap = filesMap;
        });
      } else {
        throw Exception(
            'Failed to load document files. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching document files: $e');
    }
  }

  Future<void> _addNewFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first; // Get the first file

        File fileObject = File(file.path!);

        // Implement the logic to upload the selected file with its original name
        await _uploadFileToApi(fileObject); // Pass the original filename
      } else {
        // User canceled the file picking
        print('User canceled file picking');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _uploadFileToApi(File file) async {
    try {
      var url = 'https://10.0.2.2:7278/api/File/upload'; // Update the endpoint to match your API

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path, filename: file.path.split('/').last),
      );
      request.fields['DocumentId'] = widget.documentId; // Include the DocumentId in the request fields
      request.headers['Authorization'] = 'Bearer $_token';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully', style: TextStyle(color: Colors.green)), // Green for success
          ),
        );
        await fetchDocumentFiles(_token);

        // Save the filename to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? fileNames = prefs.getStringList('pdf_names');
        fileNames ??= []; // If null, initialize to empty list
        fileNames.add(file.path.split('/').last); // Add the filename
        await prefs.setStringList('pdf_names', fileNames); // Save the updated list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload file. Status code: ${response.statusCode}', style: TextStyle(color: Colors.red)), // Red for error
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: $e', style: TextStyle(color: Colors.red)), // Red for error
        ),
      );
    }
  }



  Future<void> _openFile(String fileId) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Document Details',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.yellow[700], // Adjusted to yellow shade
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '${widget.documentName}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${widget.documentDescription}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Files:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: documentFilesMap.length,
                itemBuilder: (context, index) {
                  final List<String> fileIds = documentFilesMap.keys.toList();
                  final fileId = fileIds[index];
                  final fileName = documentFilesMap[fileId] ?? 'Unknown';
                  return ListTile(
                    title: Text(
                      fileName,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      _openFile(fileId);
                    },
                    leading: Icon(
                      Icons.insert_drive_file,
                      color: Colors.blue,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFile,
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[700], // Adjusted to yellow shade
      ),
    );
  }



}
