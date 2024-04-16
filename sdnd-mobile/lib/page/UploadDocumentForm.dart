import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Document {
  String name;
  String description;

  Document({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
    };
  }
}

class ApiService {
  static const String baseUrl = "https://10.0.2.2:7278/api";

  static Future<http.Response> addDocument(Document document) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Document/add'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(document.toJson()),
    );

    return response;
  }
}





void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Document'),
        ),
        body: UploadDocumentForm(),
      ),
    );
  }
}

class UploadDocumentForm extends StatefulWidget {
  const UploadDocumentForm({Key? key});

  @override
  _UploadDocumentFormState createState() => _UploadDocumentFormState();
}

class _UploadDocumentFormState extends State<UploadDocumentForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _submitDocument() async {
    Document document = Document(
      name: nameController.text,
      description: descriptionController.text,
    );

    final response = await ApiService.addDocument(document);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload document')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: Padding(
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
            ElevatedButton(
              onPressed: _submitDocument,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

