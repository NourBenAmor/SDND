import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'saving.dart'; // Import the SavingPage

class EditingPage extends StatefulWidget {
  final File? imageFile; // Change to nullable File

  const EditingPage({Key? key, this.imageFile}) : super(key: key);

  @override
  _EditingPageState createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  late TextRecognizer textRecognizer;
  String recognizedText = "";

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    // Call doTextRecognition only if an image is provided
    if (widget.imageFile != null) {
      doTextRecognition();
    }
  }

  Future<void> doTextRecognition() async {
    if (widget.imageFile != null) {
      InputImage inputImage = InputImage.fromFile(widget.imageFile!);
      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      setState(() {
        this.recognizedText = recognizedText.text;
      });
    }
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.Page(
        build: (pdfLib.Context context) {
          if (widget.imageFile != null) {
            return pdfLib.Center(
              child: pdfLib.Image(
                  pdfLib.MemoryImage(widget.imageFile!.readAsBytesSync())),
            );
          } else {
            return pdfLib.Center(
              child: pdfLib.Text('No image available'), // Utiliser pdfLib.Text au lieu de Text
            );
          }
        },
      ),
    );

    final output = await File(widget.imageFile!.path.replaceAll('.jpg', '.pdf'))
        .writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPage(pdfFile: output),
      ),
    );
  }

  void copyTextToClipboard() {
    Clipboard.setData(ClipboardData(text: recognizedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editing Page'),
        actions: [],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: widget.imageFile != null
                  ? Image.file(widget.imageFile!)
                  : Text('No image available'),
            ),
          ),
          GestureDetector(
            onTap: copyTextToClipboard,
            child: Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Couleur de fond
                borderRadius: BorderRadius.circular(8.0), // Bordures arrondies
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      recognizedText,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: copyTextToClipboard,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Call the function to generate the PDF when the user presses the import button
              generatePdf(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.yellow[900],
              backgroundColor: Colors.yellow[700],
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bordure arrondie
                // Ajouter une ombre
              ),
            ),
            icon: Icon(Icons.file_upload, size: 24, color: Colors.white),
            label: Text(
              'Import PDF',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
