import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  static Future<http.Response> addDocument(Document document, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Document/add'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(document.toJson()),
      );
      return response;
    } catch (e) {
      print('Error connecting to API: $e');
      throw Exception('Failed to connect to the server');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Récupérer le token du FlutterSecureStorage
  final storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Upload Document'),
        ),
        body: UploadDocumentForm(token: token),
      ),
    );
  }
}

class UploadDocumentForm extends StatefulWidget {
  final String? token;

  const UploadDocumentForm({Key? key, this.token}) : super(key: key);

  @override
  _UploadDocumentFormState createState() => _UploadDocumentFormState();
}

class _UploadDocumentFormState extends State<UploadDocumentForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitDocument() async {
    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Document document = Document(
      name: nameController.text,
      description: descriptionController.text,
    );

    try {
      final response = await ApiService.addDocument(document, widget.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload document')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Clear text controllers after document submission
    nameController.clear();
    descriptionController.clear();
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
              onPressed: _isLoading ? null : _submitDocument,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
