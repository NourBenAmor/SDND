import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:airsafe/page/saving.dart';

class TextDisplayPage extends StatelessWidget {
  final String text;
  final String token;

  const TextDisplayPage({Key? key, required this.text, required this.token}) : super(key: key);

  Future<void> generatePdf(BuildContext context) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No text found")),
      );
      return;
    }

    final pdf = pdfLib.Document();

    final chunkSize = 1000; // Example: Each page contains up to 1000 characters

    for (var i = 0; i < text.length; i += chunkSize) {
      final chunk = text.substring(i, i + chunkSize < text.length ? i + chunkSize : text.length);
      pdf.addPage(
        pdfLib.Page(
          build: (pdfLib.Context context) {
            return pdfLib.Center(
              child: pdfLib.Text(
                chunk,
                style: pdfLib.TextStyle(fontSize: 18),
              ),
            );
          },
        ),
      );
    }

    Directory? appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir?.path ?? '';
    final output = File('$appDocPath/text_pdf.pdf');
    await output.writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPage(pdfFile: output, token: token),
      ),
    );
  }

  Future<String> summarizeText(String text) async {
    final apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyDrKAyOoTZqct-gCqg1ltZLUE13VvqUcG8';

    final headers = {
      'Content-Type': 'application/json',
    };

    final data = {
      "contents": [
        {
          "parts": [
            {
              'text': text,
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final summarizedText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        return summarizedText;
      } else {
        throw Exception('Failed to summarize text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error summarizing text: $e');
    }
  }

  Future<void> generateSummarizedPdf(BuildContext context, String summarizedText) async {
    if (summarizedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No text found")),
      );
      return;
    }

    final pdf = pdfLib.Document();

    final chunkSize = 1000; // Example: Each page contains up to 1000 characters

    for (var i = 0; i < summarizedText.length; i += chunkSize) {
      final chunk = summarizedText.substring(i, i + chunkSize < summarizedText.length ? i + chunkSize : summarizedText.length);
      pdf.addPage(
        pdfLib.Page(
          build: (pdfLib.Context context) {
            return pdfLib.Center(
              child: pdfLib.Text(
                chunk,
                style: pdfLib.TextStyle(fontSize: 18), // Change text color here
              ),
            );
          },
        ),
      );
    }

    Directory? appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir?.path ?? '';
    final output = File('$appDocPath/summarized_text_pdf.pdf');
    await output.writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPage(pdfFile: output, token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Recognition'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: Future.delayed(Duration(seconds: 2), () => text), // Simulate OCR text recognition
            builder: (BuildContext context, AsyncSnapshot<String> ocrSnapshot) {
              if (ocrSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show loading indicator while performing OCR text recognition
              } else if (ocrSnapshot.hasError) {
                return Text('Error: ${ocrSnapshot.error}');
              } else {
                return SelectableText(
                  ocrSnapshot.data ?? "",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.left,
                );
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: text.isNotEmpty
          ? BottomAppBar(
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: ElevatedButton.icon(
                onPressed: () {
                  generatePdf(context);
                },
                icon: Icon(Icons.file_upload, size: 24),
                label: Text('Generate PDF', style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.yellow[700]),
                ),
              ),
            ),
            Flexible(
              child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Prevent dismissing dialog on outside tap
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(), // Show loading indicator in dialog
                            SizedBox(width: 20),
                            Text("Summarizing..."), // Display text indicating summarization process
                          ],
                        ),
                      );
                    },
                  );

                  try {
                    final summarizedText = await summarizeText(text);
                    Navigator.pop(context); // Close loading dialog

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Summarized Text'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(summarizedText, style: TextStyle(fontSize: 18, color: Colors.black)), // Display summarized text
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    generateSummarizedPdf(context, summarizedText);
                                  },
                                  child: Text('Generate PDF'),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.yellow[700]), // Change button color
                                  ),
                                ),
                              ],
                            ),
                          ),
                          backgroundColor: Colors.yellow[200], // Change dialog background color
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white, // Change text color
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error summarizing text: $e')),
                    );
                  }
                },
                icon: Icon(Icons.summarize),
                label: Text('Summarize', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.yellow[700]), // Change button color
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