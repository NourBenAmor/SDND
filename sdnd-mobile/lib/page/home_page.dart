import 'dart:convert';
import 'dart:io';
import 'package:airsafe/page/synchronisation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'camera_page.dart';
import 'document_details.dart';
import 'editing_page.dart';
import 'file_list.dart';
import 'multiple_image.dart';

class Document {
  final String id;
  final String documentId;
  final String name;
  final String description;
  final String ownerId;
  final DateTime addedDate;
  final DateTime updatedDate;
  final String documentState;
  final List<String> files;

  Document({
    required this.id,
    required this.documentId,
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

enum DocumentState {
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
        if (responseBody != null && responseBody is List<dynamic>) {
          final List<dynamic> data = responseBody;
          setState(() {
            _documents = data.map((doc) {
              List<String> files = (doc['files'] as List<dynamic>?)
                  ?.map<String>((file) => file['path'].toString())
                  .toList() ?? [];

              return Document(
                id: doc['id'].toString(), // Convert GUID to String
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
          });
        } else {
          print('Response body from API is null or not a List');
        }
      } else {
        throw Exception('Failed to load documents (Status Code: ${response.statusCode})');
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingPage(imageFile: File(photo.path)),
      ),
    );
  }

  void _navigateToListPdfPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListPdfPage()),
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
          token: _token,
        ),
      ),
    );
  }

  void _showCreateDocumentDialog(BuildContext context) {
    String name = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create a New Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  description = value;
                },
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _createDocument(name, description);
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createDocument(String name, String description) async {
    if (name.isEmpty || description.isEmpty) {
      print('Name and description cannot be empty');
      return;
    }

    final url = Uri.parse('https://10.0.2.2:7278/api/Document/add');

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        print('Document created successfully');
        _fetchDocuments(widget.token);
      } else {
        print('Failed to create document (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error creating document: $e');
    }
  }

  void _deleteDocument(BuildContext context, String documentId) async {
    final url = Uri.parse('https://10.0.2.2:7278/api/Document/Delete/$documentId');

    try {
      final response = await http.delete(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 204) {
        // Document deleted successfully, update UI
        setState(() {
          _documents.removeWhere((doc) => doc.id == documentId);
        });
        print('Document deleted successfully');
      } else {
        print('Failed to delete document (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this document?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteDocument(context, documentId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _searchDocuments(String searchQuery) async {
    if (searchQuery.isEmpty) {
      _fetchDocuments(_token); // Reload all documents if search query is empty
      return;
    }

    final url = Uri.parse('https://10.0.2.2:7278/api/Document/filterByName?Name=$searchQuery');

    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        if (responseBody != null && responseBody is List<dynamic>) {
          final List<dynamic> data = responseBody;
          setState(() {
            _documents = data.map((doc) {
              List<String> files = (doc['files'] as List<dynamic>?)
                  ?.map<String>((file) => file['path'].toString())
                  .toList() ?? [];

              return Document(
                id: doc['id'].toString(), // Convert GUID to String
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
          });
        } else {
          print('Response body from API is null or not a List');
        }
      } else {
        throw Exception('Failed to search documents (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error searching documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SynchronizationPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
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
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              _searchDocuments(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showCreateDocumentDialog(context);
                      },
                      icon: Icon(Icons.create_new_folder),
                      tooltip: 'Create a new folder',
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        _navigateToListPdfPage(context);
                      },
                      icon: Icon(Icons.file_download_rounded),
                      tooltip: 'Import a file',
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
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
            child: _documents.isNotEmpty
                ? ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                return ListTile(
                  leading: Icon(Icons.folder),
                  title: Text(document.name),
                  subtitle: Text(document.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, document.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          //_shareFolder(index);
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
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
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
            onPressed: _pickImage,
            backgroundColor: Colors.yellow[700],
            child: Icon(Icons.image),
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
