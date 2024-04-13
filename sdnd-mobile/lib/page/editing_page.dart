import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'formulaireFile.dart';
import 'saving.dart'; // Import the SavingPage

class EditingPage extends StatelessWidget {
  final File imageFile;

  const EditingPage({Key? key, required this.imageFile}) : super(key: key);

  Future<void> generatePdf(BuildContext context) async {
    // Create a PDF document
    final pdf = pdfLib.Document();

    // Add a page to the PDF document
    pdf.addPage(
      pdfLib.Page(
        build: (pdfLib.Context context) {
          return pdfLib.Image(pdfLib.MemoryImage(imageFile.readAsBytesSync()));
        },
      ),
    );

    // Save the PDF file on the device
    final output = await File(imageFile.path.replaceAll('.jpg', '.pdf'))
        .writeAsBytes(await pdf.save());

    // Navigate to the SavingPage after generating the PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulairePage(pdfFile: output),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editing Page'),
      ),
      body: Stack(
        children: [
          Center(
            child: Image.file(imageFile),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20, // Adjust bottom position as needed
            child: Container(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Call the function to generate the PDF when the user presses the import button
                  generatePdf(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  // Set button background color to yellow
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  // Increase padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Round the button corners
                  ),
                ),
                icon: Icon(Icons.file_upload, size: 28), // Larger icon size
                label: Text(
                  'Import PDF',
                  style: TextStyle(fontSize: 18), // Increase text size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
