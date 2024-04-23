import 'dart:io';
import 'dart:typed_data';
import 'package:airsafe/page/saving.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart'; // Import the open_file package
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MultipleImage extends StatefulWidget {
  @override
  _MultipleImageState createState() => _MultipleImageState();
}

class _MultipleImageState extends State<MultipleImage> {
  final picker = ImagePicker();
  List<File> _image = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image to PDF"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              createPdfFile();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: pickImages,
      ),
      body: _image.isNotEmpty
          ? ListView.builder(
        itemCount: _image.length,
        itemBuilder: (context, index) => Container(
          height: 400,
          width: double.infinity,
          margin: EdgeInsets.all(8),
          child: Image.file(
            _image[index],
            fit: BoxFit.cover,
          ),
        ),
      )
          : Center(
        child: Text("No images selected"),
      ),
    );
  }

  Future<void> pickImages() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image.add(File(pickedFile.path));
      } else {
        print('No image selected');
      }
    });
  }

  Future<void> createPdfFile() async {
    final pdf = pw.Document(); // Initialize PDF document

    for (var img in _image) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          }));
    }

    try {
      final dir = await getExternalStorageDirectory();
      final fileName = 'images.pdf';
      final saveFile = File('${dir?.path}/$fileName');
      await saveFile.writeAsBytes(await pdf.save());

      // Open the downloaded PDF file
      await openDownloadedFile(saveFile);

      // Navigate to SavingPage after saving the PDF
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavingPage(pdfFile: saveFile),
        ),
      );
    } catch (e) {
      print('Failed to save PDF: $e');
    }
  }

  Future<void> openDownloadedFile(File pdfFile) async {
    final filePath = pdfFile.path;
    final result = await OpenFile.open(filePath);
    print(result);
  }
}
