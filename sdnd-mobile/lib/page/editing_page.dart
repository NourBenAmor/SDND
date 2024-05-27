import 'dart:io';
import 'package:airsafe/page/ocr_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'saving.dart'; // Import the SavingPage
// Import the TextDisplayPage

class EditingPage extends StatefulWidget {
  final File? imageFile; // Change to nullable File
  final String token;

  const EditingPage({Key? key, this.imageFile, required this.token}) : super(key: key);

  @override
  _EditingPageState createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  late TextRecognizer textRecognizer;
  String recognizedText = "";
  late String token;

  @override
  void initState() {
    super.initState();
    token = widget.token; // Initialize token in initState
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

    navigateToTextDisplayPage();
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
              child: pdfLib.Text(
                  'No image available'), // Utiliser pdfLib.Text au lieu de Text
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
        builder: (context) => SavingPage(pdfFile: output, token: token),
      ),
    );
  }


  void navigateToTextDisplayPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TextDisplayPage(
                text: recognizedText, token: token), // Pass recognizedText instead of recognizedText object
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(''),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: widget.imageFile != null
                  ? Image.file(widget.imageFile!)
                  : Text('No image available'),
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[100], // Fond de la barre de navigation en bas en jaune clair
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await generatePdf(context);
              },
              icon: Icon(Icons.file_upload),
              label: Text('Generate PDF'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                navigateToTextDisplayPage();
              },
              icon: Icon(Icons.text_fields),
              label: Text('Generate Text'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
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
}