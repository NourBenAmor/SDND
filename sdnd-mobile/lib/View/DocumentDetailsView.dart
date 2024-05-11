

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Controller/DocumentController.dart';
import '../Model/DocumentDetails.dart';

class DocumentDetailsView extends StatefulWidget {
  final String token;
  final String documentId;
  final String documentName;
  final String documentDescription;

  const DocumentDetailsView({
    Key? key,
    required this.token,
    required this.documentId,
    required this.documentName,
    required this.documentDescription,
  }) : super(key: key);

  @override
  _DocumentDetailsViewState createState() => _DocumentDetailsViewState();
}

class _DocumentDetailsViewState extends State<DocumentDetailsView> {
  late DocumentController _controller;
  late List<DocumentDetails> _documents;
  Map<String, String> get documentFilesMap => _controller.documentFilesMap;
  late String _token; // Add this line

  @override
  void initState() {
    super.initState();
    _controller = DocumentController(widget.token, context);
    _documents = [];
    _token = widget.token;
    fetchDocumentFiles(widget.token);
  }

  Future<void> fetchDocumentFiles(String token) async {
    try {
      await _controller.fetchDocumentFiles(widget.documentId, _token);
      setState(() {}); // Rebuild the widget with updated data
    } catch (e) {
      print('Error fetching document files: $e');
    }
  }



  Future<void> _addNewFile() async {
    await _controller.addNewFile(widget.documentId);
    // Update the state to trigger a rebuild after uploading a new file
    setState(() {});
  }


  Future<void> _openFile(String fileId) async {
    await _controller.openFile(fileId); // Call the method from the controller
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
      body: FutureBuilder<void>(
        future: Future<void>.value(null), // Dummy future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return SingleChildScrollView(
              child: Container(
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: documentFilesMap.length,
                      itemBuilder: (context, index) {
                        final List<String> fileIds = documentFilesMap.keys
                            .toList();
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
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFile,
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[700], // Adjusted to yellow shade
      ),
    );
  }
}