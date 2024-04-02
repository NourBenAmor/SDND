import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class SavingPage extends StatelessWidget {
  final File pdfFile;

  const SavingPage({super.key, required this.pdfFile});

  Future<void> _savePdfToDevice(BuildContext context) async {
    try {
      final dir = await getExternalStorageDirectory();
      final fileName = pdfFile.path.split('/').last;
      final saveFile = File('${dir!.path}/$fileName');
      await saveFile.writeAsBytes(await pdfFile.readAsBytes());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF saved successfully'),
        ),
      );

      // After saving, navigate to the PDF list page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PDFListPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save PDF'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            onPressed: () => _savePdfToDevice(context),
            icon: const Icon(Icons.save),
          ),
        ],
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

class PDFListPage extends StatefulWidget {
  const PDFListPage({super.key});

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
          return ListTile(
            title: Text(pdfFile.path.split('/').last),
            onTap: () {
              // Navigate to a page where you can modify the PDF
            },
          );
        },
      ),
    );
  }
}
