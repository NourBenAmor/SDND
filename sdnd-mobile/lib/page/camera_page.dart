import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:edge_detection/edge_detection.dart';

import 'editing_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late Future<void> _cameraFuture;
  late CameraController _cameraController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _cameraFuture = _initializeCameraAndDetectEdge(); // Initialise la caméra et détecte les contours automatiquement
  }

  Future<void> _initializeCameraAndDetectEdge() async {
    // Initialisation de la caméra
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
    );

    await _cameraController.initialize();

    // Détecte les contours directement après l'initialisation de la caméra
    await _captureAndDetectEdge();
  }

  Future<void> _captureAndDetectEdge() async {
    if (!_cameraController.value.isInitialized) {
      throw 'La caméra n\'est pas initialisée.';
    }

    try {
      final XFile capturedImage = await _cameraController.takePicture();
      // Appel de la détection des contours
      bool success = await EdgeDetection.detectEdge(
        capturedImage.path,
        canUseGallery: true,
        androidScanTitle: 'Scanning',
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditingPage(imageFile: File(capturedImage.path)),
          ),
        );
      }


    } catch (e) {
      print('Erreur lors de la capture de l\'image: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<void>(
        future: _cameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Visibility(
              visible: _imagePath != null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(_imagePath ?? ''),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
