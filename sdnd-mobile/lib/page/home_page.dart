import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'UploadDocumentForm.dart';
import 'camera_page.dart';
import 'document_details.dart';
import 'editing_page.dart';

import 'history_page.dart';
import 'multiple_image.dart'; // Import the new page class to display document content
class Document {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime addedDate;
  final DateTime updatedDate;
  final String documentState;
  final List<String> files;

  Document({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.addedDate,
    required this.updatedDate,
    required this.documentState,
    required this.files,
  });

}
class DocumentQueryObject {
  final String? name;
  final String? description;
  final State? documentState;
  final DateTime? addedDateBefore;
  final DateTime? addedDateAfter;
  final DateTime? updatedDateBefore;
  final DateTime? updatedDateAfter;

  DocumentQueryObject({
    this.name,
    this.description,
    this.documentState,
    this.addedDateBefore,
    this.addedDateAfter,
    this.updatedDateBefore,
    this.updatedDateAfter,
  });
}
enum documentState {
  Blank,
  Filled,
  Shared,
  Archived,
}

class HomePage extends StatefulWidget {
  final String token; // Define _token as a parameter for the HomePage widget

  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _token; // Define _token within the state class
  List<Document> _documents = []; // State variable to store documents
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _fetchDocuments(_token);
  }

  Future<void> _fetchDocuments(String token) async {
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
        if (responseBody != null && responseBody is List<dynamic>) { // Check if responseBody is not null and is a List
          final List<dynamic> data = responseBody;
          setState(() {
            _documents = data.map((doc) {
              // Extracting file paths from the list of maps
              List<String> files = (doc['files'] as List<dynamic>?)
                  ?.map<String>((file) => file['path'].toString())
                  .toList() ?? [];

              return Document(
                id: doc['id'].toString(), // Convert GUID to String
                name: doc['name'],
                description: doc['description'].toString() ?? '',
                ownerId: doc['ownerId'].toString() ?? '',
                addedDate: DateTime.parse(doc['addedDate'].toString()),
                updatedDate: DateTime.parse(doc['updatedDate'].toString()),
                documentState: doc['documentState'].toString(),
                files: files,
              );
            }).toList();


            // Log the documents here
            print('Documents: $_documents');
          });
        } else {
          print('Response body from API is null or not a List');
        }
      } else {
        throw Exception('Failed to load documents (Status Code: ${response.statusCode})');
      }
    } on SocketException catch (e) {
      // Handle network errors
      print('Socket Exception: $e');
      // Show error message to the user
    } catch (e) {
      // Handle other exceptions
      print('Exception: $e');
      // Show error message to the user
    }
  }


  Future<void> _createNewFolder(BuildContext context) async {
    // Navigation vers la page d'importation de documents
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadDocumentForm()),
    );
  }



  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Utilisez la méthode scanImage pour naviguer vers la page d'édition avec l'image sélectionnée
        await scanImage(context, pickedFile);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> scanImage(BuildContext context, XFile photo) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      File rotatedImage = await FlutterExifRotation.rotateImage(path: photo.path);
      photo = XFile(rotatedImage.path);
    }

    final fileBytes = await photo.readAsBytes();

    // Naviguer vers la page d'édition avec l'image sélectionnée
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingPage(imageFile: File(photo.path)),
      ),
    );
  }

  void _deleteFolder(int index) {
    setState(() {
      folders.removeAt(index);
    });
  }

  void _shareFolder(int index) {

  }

  void _navigateToListPdfPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListPdfPage()), // Créez une instance de ListPdfPage
    );
  }
  void _navigateToDocumentDetailsPage(
      BuildContext context,
      String documentId,
      String documentName,
      String documentDescription,
      List<String> documentFiles,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetails(
          documentId: documentId,
          documentName: documentName,
          documentDescription: documentDescription,
          documentFiles: documentFiles,
            token: _token// Pass documentFiles here
        ),
      ),
    );
  }







  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure you want to delete this folder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteFolder(index);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 4,
            child: Image.asset(
              'images/image-document.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200]?.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Container()),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _createNewFolder(context);
                      },
                      icon: Icon(Icons.create_new_folder),
                      tooltip: 'Create a new folder',
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        _navigateToListPdfPage(context); // Logique pour importer un fichier
                      },
                      icon: Icon(Icons.file_download_rounded),
                      tooltip: 'Import a file',
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        // Navigate to the MultipleImage page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MultipleImage()),
                        );
                      },
                      icon: Icon(Icons.photo_library),
                      tooltip: 'Select Multiple Images',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _documents.isNotEmpty
                      ? ListView.builder(
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final document = _documents[index];
                      return ListTile(
                        leading: Icon(Icons.folder),
                        title: Text(document.name),
                        subtitle: Text(document.description),
                        // Add more info to subtitle as needed
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {
                                _shareFolder(index);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _navigateToDocumentDetailsPage(
                            context,
                            document.id,
                            document.name,
                            document.description,
                            document.files,
                          );
                        },


                      );
                    },
                  )
                      : Center(child: Text('No documents found')),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        // Naviguer vers la page de la caméra
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CameraPage()),
                        );
                      },
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.camera_alt),
                    ),
                    SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: _pickImage, // Utilisez _pickImage pour gérer le clic sur le bouton
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.image),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
