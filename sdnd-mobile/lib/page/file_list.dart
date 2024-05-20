import 'dart:io';
import 'package:airsafe/page/synchronisation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';

import '../View/DashboardView.dart';
import '../View/ProfilePageView.dart';
import 'addDocument.dart';
import 'base_layout.dart';
import 'multiple_image.dart';

class ListPDFsScreen extends StatefulWidget {
  final String token;

  const ListPDFsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ListPDFsScreen> createState() => _ListPDFsScreenState();
}

class _ListPDFsScreenState extends State<ListPDFsScreen> {
  List<File> mypdfs = [];
  late String token;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      token = widget.token;
      _loadPdfFiles();
    }
  }


  Future<void> _loadPdfFiles() async {
    Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
    List<FileSystemEntity> entities = downloadsDirectory.listSync(recursive: false);
    List<File> pdfFiles = [];
    for (FileSystemEntity entity in entities) {
      if (entity is File && entity.path.endsWith('.pdf')) {
        pdfFiles.add(entity);
      }
    }
    setState(() {
      mypdfs = pdfFiles;
    });
  }

  Future<void> _handleFileSelection(String filePath) async {
    Navigator.pop(context, filePath);
  }
  void _navigateToListPdfPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListPDFsScreen(token: token,)),
    );
  }
  void _navigateToDashboardPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardView(token: token)),
    );
  }



  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePageView(token: token)),
    );
  }

  void _navigateToCreateDocumentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateDocumentPage( createDocumentCallback: (String , description ) {  },)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        token: token,
        currentIndex: 1, // Set currentIndex to 4 for ListPDFsScreen
        child: Scaffold(
        appBar: AppBar(
        title: Text("PDFs"),
    ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: mypdfs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _handleFileSelection(mypdfs[index].path);
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 1),
                ),
                child: Center(
                  child: PdfThumbnail.fromFile(
                    mypdfs[index].path,
                    currentPage: 1,
                    height: 150,
                    backgroundColor: Colors.transparent,
                    loadingIndicator: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ));
  }
}




