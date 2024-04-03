import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'editing_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late Future<void> _cameraFuture;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
    );

    await _cameraController.initialize();
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
            return Stack(
              children: [
                Center(
                  child: CameraPreview(_cameraController),
                ),
                Positioned(
                  bottom: 16.0, // Ajustez la marge inférieure selon vos besoins
                  right: 16.0, // Ajustez la marge droite selon vos besoins
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      backgroundColor: Colors.yellow[700],
                      onPressed: () async {
                        final capturedImage = await _capturePhoto();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditingPage(imageFile: capturedImage),
                          ),
                        );
                      },
                      child: const Icon(Icons.camera_alt),
                      shape: const CircleBorder(), // Rend le bouton sous forme de cercle
                    ),
                  ),
                ),
              ],
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


  Future<File> _capturePhoto() async {
    if (!_cameraController.value.isInitialized) {
      throw 'La caméra n\'est pas initialisée.';
    }

    try {
      final XFile capturedImage = await _cameraController.takePicture();
      return File(capturedImage.path);
    } catch (e) {
      print('Erreur lors de la capture de l\'image: $e');
      rethrow;
    }
  }
}
