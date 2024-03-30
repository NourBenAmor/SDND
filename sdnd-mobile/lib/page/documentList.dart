import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocumentList extends StatefulWidget {
  @override
  _DocumentListScreenState createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentList> {
  List<dynamic> _documents = [];

  @override
  void initState() {
    super.initState();

    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {

      var response = await http.get(Uri.parse('https://api.com/api/documents'));
      if (response.statusCode == 200) {

        setState(() {
          _documents = jsonDecode(response.body);
        });
      } else {

        print('Erreur lors de la récupération des documents: ${response.reasonPhrase}');
      }
    } catch (error) {

      print('Erreur lors de la récupération des documents: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Documents'),
      ),
      body: ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {

          return ListTile(
            title: Text(_documents[index]['nom']),
            subtitle: Text(_documents[index]['type']),

          );
        },
      ),
    );
  }
}
