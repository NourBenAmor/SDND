import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'file_list.dart'; // Importez votre page ListPdfPage

class SavingPage extends StatefulWidget {
  final File pdfFile;
  final String token;

  const SavingPage({Key? key, required this.pdfFile, required this.token}) : super(key: key);

  @override
  _SavingPageState createState() => _SavingPageState();
}

class _SavingPageState extends State<SavingPage> {
  late PDFViewController _pdfViewController;
  int _currentPageNumber = 1;
  int _totalPages = 0;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _downloadPdfToDevice(BuildContext context) async {
    if (await _requestStoragePermission()) {
      try {
        final directory = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
        final fileName = widget.pdfFile.path.split('/').last;
        final saveFile = File('$directory/$fileName');
        await saveFile.writeAsBytes(await widget.pdfFile.readAsBytes());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully'),
          ),
        );

        // Rediriger vers ListPdfPage après le téléchargement réussi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListPDFsScreen(token: widget.token), // Remplacez ListPdfPage par votre nom de page
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied to download PDF'),
        ),
      );
    }
  }

  Future<void> _savePdfToDevice(BuildContext context) async {
    try {
      final dir = await getExternalStorageDirectory();
      final fileName = widget.pdfFile.path.split('/').last;
      final saveFile = File('$dir/$fileName');
      await saveFile.writeAsBytes(await widget.pdfFile.readAsBytes());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF saved successfully'),
        ),
      );

      // Naviguer simplement en arrière pour revenir à la page précédente
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save PDF'),
        ),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            onPressed: () => _downloadPdfToDevice(context),
            icon: Icon(Icons.save_alt),
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PDFView(
              filePath: widget.pdfFile.path,
              onViewCreated: (PDFViewController controller) {
                setState(() {
                  _pdfViewController = controller;
                });
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPageNumber = page ?? 1;
                  _totalPages = total ?? 0;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page $_currentPageNumber of $_totalPages',
                  style: TextStyle(fontSize: 16.0),
                ),
                IconButton(
                  onPressed: () {
                    if (_pdfViewController != null && _currentPageNumber > 1) {
                      _pdfViewController.setPage(_currentPageNumber - 1);
                    }
                  },
                  icon: Icon(Icons.keyboard_arrow_left),
                ),
                IconButton(
                  onPressed: () {
                    if (_pdfViewController != null &&
                        _currentPageNumber < _totalPages) {
                      _pdfViewController.setPage(_currentPageNumber + 1);
                    }
                  },
                  icon: Icon(Icons.keyboard_arrow_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

