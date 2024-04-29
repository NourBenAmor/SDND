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
        builder: (context) => SavingPage(pdfFile: output),
      ),
    );
  }


  void navigateToTextDisplayPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TextDisplayPage(
                text: recognizedText), // Pass recognizedText instead of recognizedText object
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: widget.imageFile != null
            ? Image.file(widget.imageFile!)
            : Container(), // Remplacer par votre contenu principal
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[100], // Fond de la barre de navigation en bas en jaune clair
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Call the function to generate the PDF when the user presses the import button
                generatePdf(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.yellow[700], // Texte en blanc
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bord arrondi
                  // Vous pouvez ajouter une ombre ou d'autres styles ici si nécessaire
                ),
              ),
              icon: Icon(Icons.file_upload, size: 24),
              label: Text(
                'Import PDF',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton.icon(
              onPressed: navigateToTextDisplayPage,
              icon: Icon(Icons.text_fields),
              label: Text('Generate Text'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.yellow[700], // Texte en blanc
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bord arrondi
                  // Vous pouvez ajouter une ombre ou d'autres styles ici si nécessaire
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




}
