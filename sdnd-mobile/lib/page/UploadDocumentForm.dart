import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'history_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
const storage = FlutterSecureStorage();

// Importez la nouvelle page de liste de fichiers

class Document {
  String name;
  String description;
  String contentType;
  File? file;

  Document({
    required this.name,
    required this.description,
    required this.contentType,
    this.file,
  });
}
/*
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
 */

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
  final TextEditingController contentTypeController = TextEditingController();
  File? file;

  void _importFile() {
    // Implémentez ici la logique pour importer un fichier
    // Par exemple, vous pouvez utiliser un sélecteur de fichiers ou une galerie
    // Une fois que l'utilisateur a sélectionné un fichier, vous pouvez effectuer une action appropriée
    // Pour l'exemple, nous allons simplement naviguer vers la page de liste de fichiers
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListPdfPage()),
    );
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
            TextField(
              controller: contentTypeController,
              decoration: const InputDecoration(labelText: 'Content Type'),
            ),
            ElevatedButton(
              onPressed: _importFile, // Utilisez la méthode _importFile pour gérer le clic sur le bouton
              child: const Text('Import File'),
            ),
            ElevatedButton(
              onPressed: () {
                Document document = Document(
                  name: nameController.text,
                  description: descriptionController.text,
                  contentType: contentTypeController.text,
                  file: file,
                );

                // Handle document submission here
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// Définition de la nouvelle page de liste de fichiers

