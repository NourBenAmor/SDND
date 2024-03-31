import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> sharePDF(int index) async {
    try {
      final file = pdfFiles[index];
      await Share.shareFiles([file.path]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share PDF'),
        ),
      );
    }
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
            title: Text(pdfFile.path.split('/').last),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavingPage(pdfFile: pdfFile),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () => sharePDF(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deletePDF(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SavingPage extends StatelessWidget {
  final File pdfFile;

  const SavingPage({Key? key, required this.pdfFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View PDF'),
      ),
      body: Center(
        child: PDFView(
          filePath: pdfFile.path,
          onViewCreated: (PDFViewController controller) {},
        ),
      ),
    );
  }
}
