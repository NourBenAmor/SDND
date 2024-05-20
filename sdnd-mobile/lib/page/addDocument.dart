import 'package:flutter/material.dart';

class CreateDocumentPage extends StatefulWidget {
  final Function(String, String) createDocumentCallback;

  const CreateDocumentPage({Key? key, required this.createDocumentCallback}) : super(key: key);

  @override
  _CreateDocumentPageState createState() => _CreateDocumentPageState();
}

class _CreateDocumentPageState extends State<CreateDocumentPage> {
  String name = '';
  String description = '';
  bool isPreviewMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Document'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                enabled: !isPreviewMode,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter document name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.yellow[700]!, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                enabled: !isPreviewMode,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter document description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.yellow[700]!, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isPreviewMode)
                ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && description.isNotEmpty) {
                      widget.createDocumentCallback(name, description);
                      Navigator.pop(context);
                      _showSuccessDialog(context); // Show success dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter both name and description.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Create',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    isPreviewMode = !isPreviewMode;
                  });
                },
                child: Text(
                  isPreviewMode ? 'Back to Edit Mode' : 'Preview',
                  style: TextStyle(color: Colors.yellow[700]),
                ),
              ),
              if (isPreviewMode)
                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(name),
                        SizedBox(height: 8),
                        Text(
                          'Description:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(description),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Document Added'),
          content: Text('The document has been successfully added.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}