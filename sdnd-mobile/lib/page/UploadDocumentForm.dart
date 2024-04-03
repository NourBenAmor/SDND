import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class Document {
  String name;
  String description;
  String contentType;
  File file;

  Document({
    required this.name,
    required this.description,
    required this.contentType,
    required this.file,
  });
}

class ApiService {
  static const String baseUrl = "https://4f96-165-51-181-40.ngrok-free.app/api";
  static late final Dio _dio;

  static Future<void> initDio() async {
    const storage = FlutterSecureStorage();
    var tokens = await storage.read(key: 'jwt_token');
    if (tokens == null) {
      throw Exception("Error getting token!");
    }
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $tokens",
      },
    ));
  }

  static Future<Response<dynamic>> addDocument(Document document) async {
    try {
      FormData formData = FormData.fromMap({
        'Name': document.name,
        'Description': document.description,
        'contentType': document.contentType,
        'file': await MultipartFile.fromFile(document.file.path),
      });

      Response response = await _dio.post("/Document/upload", data: formData);

      print(response.data);
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Document'),
        ),
        body: const UploadDocumentForm(),
      ),
    );
  }
}

class UploadDocumentForm extends StatefulWidget {
  const UploadDocumentForm({super.key});

  @override
  _UploadDocumentFormState createState() => _UploadDocumentFormState();
}

class _UploadDocumentFormState extends State<UploadDocumentForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contentTypeController = TextEditingController();
  late File file;

  void _chooseFile() async {
    // Implement file picker logic here
    // For simplicity, let's assume a file is picked from the device
    // Replace this with your file picker logic
    // In actual implementation, you can use packages like file_picker
  }

  void _submit() async {
    Document document = Document(
      name: nameController.text,
      description: descriptionController.text,
      contentType: contentTypeController.text,
      file: file,
    );

    try {
      Response response = await ApiService.addDocument(document);
      // Handle success response, navigate to desired screen
      print(response.data);
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: contentTypeController,
            decoration: const InputDecoration(labelText: 'Content Type'),
          ),
          ElevatedButton(
            onPressed: _chooseFile,
            child: const Text('Choose File'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
