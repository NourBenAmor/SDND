import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart' as esysShare;

class PDFListPage extends StatefulWidget {
  @override
  _PDFListPageState createState() => _PDFListPageState();
}

class _PDFListPageState extends State<PDFListPage> {
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    loadPDFs();
  }

  Future<void> loadPDFs() async {
    try {
      final directory = await getExternalStorageDirectory();
      final files = directory!.listSync().whereType<File>().toList();
      setState(() {
        pdfFiles = files;
      });
    } catch (e) {
      print('Failed to load PDFs: $e');
    }
  }

  Future<void> deletePDF(int index) async {
    try {
      await pdfFiles[index].delete();
      setState(() {
        pdfFiles.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete PDF'),
        ),
      );
    }
  }

  void sharePDF(String path, String filename) {
    esysShare.Share.file(
        'Sharing PDF', filename, File(path).readAsBytesSync(), 'application/pdf');
  }

  void openPDF(File pdfFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFView(
          filePath: pdfFile.path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF List'),
      ),
      body: ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final pdfFile = pdfFiles[index];
          return ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text(pdfFile.path.split('/').last),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () =>
                      sharePDF(pdfFile.path, pdfFile.path.split('/').last),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deletePDF(index),
                ),
              ],
            ),
            onTap: () {
              openPDF(pdfFile);
            },
          );
        },
      ),
    );
  }
}
