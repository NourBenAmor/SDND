import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:airsafe/page/saving.dart';
import 'package:flutter/services.dart';

class TextDisplayPage extends StatelessWidget {
  final String text;

  const TextDisplayPage({Key? key, required this.text}) : super(key: key);

  Future<void> generatePdf(BuildContext context) async {
    if (text.isEmpty) {
      // Afficher un message si le texte est vide
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aucun texte trouvé dans l'image")),
      );
      return;
    }

    final pdf = pdfLib.Document();

    // Ajoutez le texte à la page PDF
    pdf.addPage(
      pdfLib.Page(
        build: (pdfLib.Context context) {
          return pdfLib.Center(
            child: pdfLib.Text(
              text,
              style: pdfLib.TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );

    // Obtenez le répertoire de stockage externe pour sauvegarder le PDF
    Directory? appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir?.path ?? '';

    // Écrivez le fichier PDF dans le répertoire de stockage externe
    final output = File('$appDocPath/text_pdf.pdf');
    await output.writeAsBytes(await pdf.save());

    // Naviguer vers la page SavingPage avec le fichier PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPage(pdfFile: output),
      ),
    );
  }

  void copyTextToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Texte copié dans le presse-papiers')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Display Page'),
        actions: [],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SelectableText( // Remplacez Text par SelectableText
            text,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.left,
          ),
        ),
      ),
      bottomNavigationBar: text.isNotEmpty // Vérifiez si le texte n'est pas vide
          ? BottomAppBar(
        color: Colors.grey[100], // Fond de la barre de navigation en bas en jaune clair
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Call the function to generate the PDF when the user presses the import button
                generatePdf(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.yellow[700], // Texte en blanc
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bord arrondi
                  // Vous pouvez ajouter une ombre ou d'autres styles ici si nécessaire
                ),
              ),
              icon: Icon(Icons.file_upload, size: 24),
              label: Text(
                'Import PDF',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Naviguer vers la page précédente lorsque l'utilisateur appuie sur le bouton Retour
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
              label: Text('Retour'), 
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.yellow[700], // Texte en blanc
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  // Vous pouvez ajouter une ombre ou d'autres styles ici si nécessaire
                ),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }
}
