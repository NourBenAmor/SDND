import 'dart:io';
import 'dart:typed_data';
import 'package:airsafe/page/saving.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'base_layout.dart';

class MultipleImage extends StatefulWidget {
  final String token;

  const MultipleImage({Key? key, required this.token}) : super(key: key);

  @override
  _MultipleImageState createState() => _MultipleImageState();
}

class _MultipleImageState extends State<MultipleImage> {
  final picker = ImagePicker();
  List<File> _image = [];
  late String token;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      token = widget.token;
    }
  }
  final BoxDecoration _imageDecoration = BoxDecoration(
    border: Border.all(
      width: 1,
      color: Colors.black,
      style: BorderStyle.solid,
    ),
    borderRadius: BorderRadius.circular(12),
  );

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        token: widget.token,
        currentIndex: 3,
        child: Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              createPdfFile();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            InkWell(
              onTap: pickImages,
              child: Container(
                alignment: Alignment.center,
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 1,
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "  Click here ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _image.isNotEmpty
                  ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _image.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.all(4),
                      decoration: _imageDecoration,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          removeImage(index);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Center(
                child: Text("No images selected"),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> pickImages() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image.add(File(pickedFile.path));
      } else {
        print('No image selected');
      }
    });
  }

  void removeImage(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  Future<void> createPdfFile() async {
    final pdf = pw.Document();

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

      await openDownloadedFile(saveFile);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavingPage(pdfFile: saveFile, token: widget.token),
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
