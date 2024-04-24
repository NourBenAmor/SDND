import 'dart:io';
import 'package:flutter/material.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';



class ListPdfPage extends StatefulWidget {
  @override
  _ListPdfPageState createState() => _ListPdfPageState();
}

class _ListPdfPageState extends State<ListPdfPage> {
  List<File> _pdfFiles = [];
  TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }


  Future<void> _loadPdfFiles() async {
    // Charger la liste des fichiers PDF depuis le répertoire de téléchargement sur Android
    Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
    List<FileSystemEntity> entities = downloadsDirectory.listSync(recursive: false);
    List<File> pdfFiles = [];
    for (FileSystemEntity entity in entities) {
      if (entity is File && entity.path.endsWith('.pdf')) {
        pdfFiles.add(entity);
      }
    }
    setState(() {
      _pdfFiles = pdfFiles;
    });
  }

  void _renamePdfFile(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentName = _pdfFiles[index].path.split('/').last; // Nom actuel du fichier PDF
        _editingController.text = currentName; // Initialiser le contrôleur de texte avec le nom actuel
        return AlertDialog(
          title: Text("Renommer le fichier"),
          content: TextField(
            controller: _editingController,
            decoration: InputDecoration(hintText: 'Nouveau nom'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              child: Text("Valider"),
              onPressed: () {
                File oldFile = _pdfFiles[index];
                String newPath = oldFile.path.replaceFirst(oldFile.path.split('/').last, _editingController.text);
                oldFile.renameSync(newPath); // Renommer le fichier sur le système de fichiers
                setState(() {
                  _pdfFiles[index] = File(newPath); // Mettre à jour la liste avec le nouveau nom
                });
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePdfFile(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Êtes-vous sûr de vouloir supprimer ce fichier ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: Text("Supprimer"),
              onPressed: () {
                File fileToDelete = _pdfFiles[index];
                fileToDelete.deleteSync(); // Supprimer le fichier du système de fichiers
                _pdfFiles.removeAt(index); // Supprimer le fichier de la liste
                setState(() {}); // Mettre à jour l'interface utilisateur
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sharePdfFile(File file) async {
    await Share.file('Share PDF', 'pdf_file.pdf', file.readAsBytesSync(), 'application/pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des PDF'),
      ),
      body: _pdfFiles != null
          ? ListView.builder(
        itemCount: _pdfFiles.length,
        itemBuilder: (context, index) {
          File pdfFile = _pdfFiles[index];
          return ListTile(
            title: GestureDetector(
              onDoubleTap: () {
                _renamePdfFile(index);
              },
              child: Text(
                pdfFile.path.split('/').last, // Nom du fichier PDF
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            leading: Icon(Icons.picture_as_pdf),
            subtitle: Text(
              'Taille: ${(pdfFile.lengthSync() / 1024).toStringAsFixed(2)} KB', // Taille du fichier PDF
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (String choice) {
                if (choice == 'Delete') {
                  _deletePdfFile(index);
                } else if (choice == 'Share') {
                  _sharePdfFile(pdfFile);
                }
              },
              itemBuilder: (BuildContext context) {
                return ['Delete', 'Share'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        choice == 'Delete'
                            ? Icon(Icons.delete)
                            : Icon(Icons.share),
                        SizedBox(width: 8),
                        Text(choice),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}