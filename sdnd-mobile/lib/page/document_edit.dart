import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class DocumentEditPage extends StatefulWidget {
  const DocumentEditPage({Key? key}) : super(key: key);

  @override
  _DocumentEditPageState createState() => _DocumentEditPageState();
}

class _DocumentEditPageState extends State<DocumentEditPage> {
  int _currentPage = 0;
  PDFViewController? _pdfViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Edit'),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: 'your_pdf_file_path.pdf', // Remplacez par le chemin de votre fichier PDF
            onRender: (pages) {
              setState(() {
                _isLoading = false;
              });
            },
            onError: (error) {
              setState(() {
                _isLoading = false;
              });
            },
            onPageError: (page, error) {
              setState(() {
                _isLoading = false;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              setState(() {
                _pdfViewController = pdfViewController;
              });
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
              });
            },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (_pdfViewController != null && !_isLoading)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${_currentPage + 1} of ${_pdfViewController!.getPageCount()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          if (_currentPage > 0 && _pdfViewController != null) {
                            _pdfViewController!.setPage(_currentPage - 1);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () async {
                          final pageCount = await _pdfViewController!.getPageCount();
                          if (pageCount != null && _currentPage < pageCount - 1 && _pdfViewController != null) {
                            _pdfViewController!.setPage(_currentPage + 1);
                          }
                        },


                      ),


                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
