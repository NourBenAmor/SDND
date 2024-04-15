import 'dart:io';
import 'package:flutter/material.dart';

class FormulairePage extends StatefulWidget {
  final File pdfFile;

  const FormulairePage({Key? key, required this.pdfFile}) : super(key: key);

  @override
  _FormulairePageState createState() => _FormulairePageState();
}

class _FormulairePageState extends State<FormulairePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String name = '';
  double size = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Taille du fichier: ${(widget.pdfFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} Mo',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Naviguer vers SavingPage en passant les données nécessaires
                  }
                },
                child: Text('Terminer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
