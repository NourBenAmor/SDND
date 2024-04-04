import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show ByteData, kIsWeb;

import 'camera_page.dart';
import 'editing_page.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> scanImage(BuildContext context, XFile photo) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      File rotatedImage = await FlutterExifRotation.rotateImage(path: photo.path);
      photo = XFile(rotatedImage.path);
    }

    final fileBytes = await photo.readAsBytes();

    // Naviguer vers la page d'édition avec l'image sélectionnée
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditingPage(imageFile: File(photo.path)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.only(top: 32),
            ),
            SizedBox(height: 44),

            const Padding(
              padding: EdgeInsets.only(top: 32),

            ),

            const SizedBox(height: 44),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!kIsWeb && Platform.isLinux) {
                      // Afficher une alerte si l'OS n'est pas supporté
                      showAlert(context, "Warning", "${Platform.operatingSystem} is not supported");
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const CameraPage();
                    }));
                  },
                  child: Container(
                    width: 150,
                    height: 125,
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/icon-camera.png",
                          width: 90,
                          height: 60,
                        ),
                        const Text(
                          "Camera Scan",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    XFile? photo = await picker.pickImage(source: ImageSource.gallery);
                    if (photo != null) {
                      await scanImage(context, photo);
                    }
                  },
                  child: Container(
                    width: 150,
                    height: 125,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/icon-image.png",
                          width: 90,
                          height: 60,
                        ),
                        const Text(
                          "Image Scan",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Image.asset(
              "images/image-document.png",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
