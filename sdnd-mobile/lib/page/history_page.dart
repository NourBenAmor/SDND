import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PDFListPage extends StatefulWidget {
  const PDFListPage({super.key});

  @override
  _PDFListPageState createState() => _PDFListPageState();
}

class _PDFListPageState extends State<PDFListPage> {
  List<File> pdfFiles = [];
  Map<String, Image?> thumbnails = {};

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
        thumbnails.clear();
        for (var file in pdfFiles) {
          thumbnails[file.path] = Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
        }
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
        thumbnails.removeWhere((key, value) => key == pdfFiles[index].path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete PDF'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF List'),
      ),
      body: ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final pdfFile = pdfFiles[index];
          final thumbnail = thumbnails[pdfFile.path];
          return ListTile(
            leading: thumbnail,
            title: Text(pdfFile.path.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deletePDF(index),
            ),
            onTap: () {
              // Navigate to a page where you can modify the PDF
            },
          );
        },
      ),
    );
  }
}
