import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:airsafe/page/editing_page.dart';
import 'package:airsafe/page/camera_page.dart';
import 'package:path/path.dart';

import '../View/ProfilePageView.dart';
import '../View/home_pageView.dart';
import 'addDocument.dart';
import 'file_list.dart';
import 'multiple_image.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final String token;
  final int currentIndex;

  BaseLayout({
    required this.child,
    required this.token,
    required this.currentIndex,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await scanImage(context, pickedFile);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> scanImage(BuildContext context, XFile photo) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      File rotatedImage =
          await FlutterExifRotation.rotateImage(path: photo.path);
      photo = XFile(rotatedImage.path);
    }

    final fileBytes = await photo.readAsBytes();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditingPage(imageFile: File(photo.path), token: token),
      ),
    );
  }

  Future<void> _showCameraOptions(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Use Camera'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraPage(token: token)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Import Image'),
                onTap: () => _pickImage(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        elevation: 10, // Elevation of the bottom navigation bar
        selectedItemColor: Colors.amber[800], // Color of the selected item
        unselectedItemColor: Colors.black, // Icon color when unselected
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            _showCameraOptions(context);
          } else {
            _onItemTapped(context, index);
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded, size: 28), // Custom icon size
            label: 'Documents List', // Custom label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download_rounded, size: 28),
            label: 'File List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 28),
            label: 'Import Image',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library, size: 28),
            label: 'Merge Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }


  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home_PageView(token: token)),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ListPDFsScreen(token: token)),
          (route) => false,
        );
        break;

      case 2:
        break;

      case 3:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MultipleImage(token: token)),
          (route) => false,
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePageView(token: token),
          ),
        );
        break;

        break;
    }
  }
}
