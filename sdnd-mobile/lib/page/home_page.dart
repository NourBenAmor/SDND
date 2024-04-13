import 'dart:io';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'UploadDocumentForm.dart';
import 'camera_page.dart';
import 'editing_page.dart';

import 'history_page.dart'; // Importez la nouvelle classe de page pour afficher le contenu du document


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> folders = [];

  Future<void> _createNewFolder(BuildContext context) async {
    // Navigation vers la page d'importation de documents
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadDocumentForm()),
    );
  }



  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Utilisez la méthode scanImage pour naviguer vers la page d'édition avec l'image sélectionnée
        await scanImage(context, pickedFile);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

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

  void _deleteFolder(int index) {
    setState(() {
      folders.removeAt(index);
    });
  }

  void _shareFolder(int index) {

  }

  void _navigateToListPdfPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListPdfPage()), // Créez une instance de ListPdfPage
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure you want to delete this folder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteFolder(index);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            width: double.infinity, // Prend toute la largeur de l'écran
            height: MediaQuery.of(context).size.height / 4, // Un quart de la hauteur de l'écran
            child: Image.asset(
              'images/image-document.png', // Chemin vers votre image
              fit: BoxFit.cover, // Ajustez la façon dont l'image est affichée
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200]?.withOpacity(0.5), // Rendre la couleur grise semi-transparente
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligner les éléments sur la ligne
              children: [
                // Ajouter un conteneur vide pour pousser les boutons vers la gauche
                Expanded(child: Container()),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _createNewFolder(context);
                      },
                      icon: Icon(Icons.create_new_folder),
                      tooltip: 'Créer un nouveau dossier',
                    ),
                    SizedBox(width: 4), // Réduire l'espace entre les boutons
                    IconButton(
                      onPressed: () {
                        _navigateToListPdfPage(context); // Logique pour importer un fichier
                      },
                      icon: Icon(Icons.file_download_rounded),
                      tooltip: 'Importer un fichier',
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.folder),
                        title: Text(folders[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {
                                _shareFolder(index);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigation vers la page de contenu du document lorsque l'utilisateur clique sur un document

                        },
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        // Naviguer vers la page de la caméra
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CameraPage()),
                        );
                      },
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.camera_alt),
                    ),
                    SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: _pickImage, // Utilisez _pickImage pour gérer le clic sur le bouton
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.image),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

