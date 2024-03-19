import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _cameraController.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<String> takePicture() async {
    try {
      await _initializeControllerFuture;

      final XFile picture = await _cameraController.takePicture();

      return picture.path;
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<void> savePdfToGallery(pw.Document pdf) async {
    final bytes = await pdf.save();
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/document.pdf');
    await file.writeAsBytes(bytes);

    final Uint8List uint8list = file.readAsBytesSync();
    await ImageGallerySaver.saveImage(uint8list);
  }

  Future<void> createAndSavePdf(String imagePath) async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(File(imagePath).readAsBytesSync());
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    await savePdfToGallery(pdf);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final imagePath = pickedFile.path;
      if (imagePath.isNotEmpty) {
        setState(() {
          _selectedImage = File(imagePath);
        });
        await createAndSavePdf(imagePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameras == null || _cameras.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 54,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(width: 14),
            Text(
              'Feed',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 67),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Place your document on a contrasting surface. Hold still and the app will take care of the rest.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      children: [
                        if (_selectedImage != null) Image.file(_selectedImage!),
                        if (_selectedImage == null) CameraPreview(_cameraController),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final imagePath = await takePicture();
                      if (imagePath.isNotEmpty) {
                        setState(() {
                          _selectedImage = File(imagePath);
                        });
                        await createAndSavePdf(imagePath);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFFFFD600)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.camera);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.camera),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.image),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
