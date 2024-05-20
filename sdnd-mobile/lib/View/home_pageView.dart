import 'dart:convert';
import 'dart:io';
import 'package:airsafe/View/DocumentDetailsView.dart';
import 'package:http/http.dart' as http;
import 'package:airsafe/View/DashboardView.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import '../Controller/DocumentController.dart';
import '../Model/Document.dart';
import '../page/addDocument.dart';
import '../page/editing_page.dart';
import '../page/base_layout.dart';

class Home_PageView extends StatefulWidget {
  final String token;

  const Home_PageView({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<Home_PageView> {
  late DocumentController _controller;
  List<Document> _documents = [];
  late String token; // Declare _token variable

  @override
  void initState() {
    super.initState();
    token = widget.token; // Assign the value of widget.token to token field
    _controller = DocumentController(widget.token, context);
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    List<Document> documents = await _controller.fetchDocuments();
    setState(() {
      _documents = documents;
    });
  }

  Future<void> scanImage(BuildContext context, XFile photo) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      File rotatedImage =
      await FlutterExifRotation.rotateImage(path: photo.path);
      photo = XFile(rotatedImage.path);
    }

    final fileBytes = await photo.readAsBytes();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingPage(imageFile: File(photo.path), token: token),
      ),
    );
  }

  void _navigateToDashboardPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardView(token: token)),
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
        builder: (context) => DocumentDetailsView(
          documentId: documentId,
          documentName: documentName,
          documentDescription: documentDescription,
          token: token,
        ),
      ),
    );
  }

  void _navigateToCreateDocumentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateDocumentPage(createDocumentCallback: _createDocument)),
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
        _fetchDocuments();
      } else {
        print(
            'Failed to create document (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error creating document: $e');
    }
  }

  void _deleteDocument(BuildContext context, String documentId) async {
    final url =
    Uri.parse('https://10.0.2.2:7278/api/Document/Delete/$documentId');

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
        print(
            'Failed to delete document (Status Code: ${response.statusCode})');
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
      _fetchDocuments(); // Reload all documents if search query is empty
      return;
    }

    final url = Uri.parse(
        'https://10.0.2.2:7278/api/Document/filterByName?Name=$searchQuery');

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
                  .toList() ??
                  [];

              return Document(
                id: doc['id'].toString(),
                // Convert GUID to String
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
        throw Exception(
            'Failed to search documents (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error searching documents: $e');
    }
  }

  void _showFullDescriptionModal(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Full Description'),
        content: SingleChildScrollView(
          child: Text(description),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      token: widget.token,
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Documents'),
            actions: [
            IconButton(
            onPressed: () {
      _navigateToDashboardPage(context); // Call function to navigate to dashboard
      },
        icon: Icon(Icons.dashboard), // Icon for dashboard
      ),
        ]),

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
                            color: Colors.yellow.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
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
                ],
              ),
            ),
            Expanded(
              child: _documents.isNotEmpty
                  ? ListView.builder(
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final document = _documents[index];
                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          document.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              document.description.length > 50
                                  ? '${document.description.substring(0, 50)}...'
                                  : document.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            if (document.description.length > 50)
                              TextButton(
                                onPressed: () =>
                                    _showFullDescriptionModal(
                                      context,
                                      document.description,
                                    ),
                                child: Text(
                                  'View More',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, document.id);
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
                      ),
                    ),
                  );
                },
              )
                  : Center(child: Text('No documents found')),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _navigateToCreateDocumentPage(context);
          },
          backgroundColor: Colors.yellow[700],
          label: Text('Add Document'),
        ),

      ),

    );
  }
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
