import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewScreen extends StatefulWidget {
  final String? path;
  final String? name;
  final bool isNet;

  PDFViewScreen({Key? key, this.path, this.name, required this.isNet})
      : super(key: key);

  @override
  _PDFViewScreenState createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  late String pdfUrl;

  int curruntPage = 0;
  int totalPages = 0;
  var errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isNet ? widget.name! : "PDF"),
        ),
        body: Stack(
          children: [
            widget.isNet
                ? Padding(
              padding: EdgeInsets.only(top: 0),
              child: PDF(
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                fitPolicy: FitPolicy.WIDTH,
                fitEachPage: true,
                onError: (error) {
                  setState(() {
                    errorMessage = '$error';
                  });
                  // Handle page rendering errors
                  print(error.toString());
                },
                onPageError: (page, error) {
                  setState(() {
                    errorMessage = 'Page $page: ${error.toString()}';
                  });
                  print('$page: ${error.toString()}');
                  print(error.toString());
                },
                onPageChanged: (int? page, int? total) {
                  setState(() {
                    print("Page is $page");
                    curruntPage = page! + 1;
                    totalPages = total!;
                    print(total);
                  });
                },
              ).cachedFromUrl(
                widget.path!,
                placeholder: (progress) =>
                    Center(child: Text('$progress %')),
                errorWidget: (error) {
                  print(error);
                  return Center(
                      child: Text(error.toString().contains(
                          "Failed host lookup: 'driving.xeetechpk.com'")
                          ? "Try again later"
                          : "Something wrong"));
                },
              ),
            )
                : Padding(
              padding: EdgeInsets.only(top: 0),
              child: PDF(
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                fitPolicy: FitPolicy.WIDTH,
                fitEachPage: true,
                onError: (error) {
                  setState(() {
                    errorMessage = '$error';
                  });
                  // Handle page rendering errors
                  print(error.toString());
                },
                onPageError: (page, error) {
                  setState(() {
                    errorMessage = 'Page $page: ${error.toString()}';
                  });
                  print('$page: ${error.toString()}');
                  print(error.toString());
                },
                onPageChanged: (int? page, int? total) {
                  setState(() {
                    print("Page is $page");
                    curruntPage = page! + 1;
                    totalPages = total!;
                    print(total);
                  });
                },
              ).fromPath(
                widget.path!,
              ),
            ),
            Positioned(
                top: 20,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(10),
                  color: Colors.black.withOpacity(0.2),
                  child: Text(
                    errorMessage ==
                        "java.io.IOException: cannot create document: File not in PDF format or corrupted."
                        ? "File not in PDF format or corrupted."
                        : errorMessage ??
                        "Total Pages  $curruntPage / $totalPages",
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ],
        ));
  }
}
