import 'dart:io';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


class ListPdfPage extends StatefulWidget {
  @override
  _ListPdfPageState createState() => _ListPdfPageState();
}

class _ListPdfPageState extends State<ListPdfPage> {
  late List<File> _pdfFiles; // Liste des fichiers PDF

  @override
  void initState() {
    super.initState();
    _loadPdfFiles(); // Charger les fichiers PDF au démarrage de la page
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
            leading: Icon(Icons.picture_as_pdf), // Icône de fichier PDF
            title: Text(
              pdfFile.path.split('/').last, // Nom du fichier PDF
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            onTap: () {
              // Naviguer vers la page de visualisation du PDF lorsque l'utilisateur clique sur un élément de la liste
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavingPage(pdfFile: pdfFile),
                ),
              );
            },
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class SavingPage extends StatelessWidget {
  final File pdfFile;

  const SavingPage({Key? key, required this.pdfFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: Center(
        child: PDFView(
          filePath: pdfFile.path,
          onPageChanged: (int? page, int? total) {},
        ),
      ),
    );
  }
}

