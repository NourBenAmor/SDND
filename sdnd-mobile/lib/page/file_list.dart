import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';


class ListPDFsScreen extends StatefulWidget {
  const ListPDFsScreen({Key? key}) : super(key: key);

  @override
  State<ListPDFsScreen> createState() => _ListPDFsScreenState();
}

class _ListPDFsScreenState extends State<ListPDFsScreen> {
  List<File> mypdfs = [];

  Future<void> _loadPdfFiles() async {
    // Load PDF files from the device storage
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
    // Return the selected file path to the previous screen
    Navigator.pop(context, filePath);
  }

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // Handle file selection when tapped
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
    );
  }
}
