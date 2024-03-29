
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:open_file/open_file.dart';
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
    final output = await File(imageFile.path.replaceAll('.jpg', '.pdf')).writeAsBytes(await pdf.save());

    // Navigate to the SavingPage after generating the PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPage(pdfFile: output),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing Page'),
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
              child: ElevatedButton(
                onPressed: () {
                  // Call the function to generate the PDF when the user presses the import button
                  generatePdf(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700], // Set button background color to yellow
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Increase padding to make the button larger
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_upload), // Import icon
                      SizedBox(width: 8), // Add spacing between icon and text
                      Text('Import PDF'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
