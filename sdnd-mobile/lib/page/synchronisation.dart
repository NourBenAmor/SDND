import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SynchronizationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Back"),
            SizedBox(width: 10), // Espacement entre les textes
            Text("Synchronization options"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 34.0),
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Image.asset(
                      'images/img_2.png',
                      height: 51.0,
                      width: 47.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Image.asset(
                      'images/img_14.png',
                      height: 51.0,
                      width: 47.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 267.0,
                      child: Text(
                        "Automatically sync your documents",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Synchronization",
                          style: TextStyle(fontSize: 24.0),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Sync your scans automatically",
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10.0),
                        // Ajout d'un espace supplémentaire entre "Auto sync" et le texte en dessous
                        Text(
                          "Auto sync",
                          style: TextStyle(fontSize: 24.0),
                        ),
                        SizedBox(height:  20.0), // Espacement entre "Auto sync" et le texte en dessous
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 41.0),
              Text(
                "Settings",
                style: TextStyle(fontSize: 32.0),
              ),
              SizedBox(height: 10.0),
              InkWell(
                onTap: () {
                  // Action when "Share with collaborators" is tapped
                },
                child: Row(
                  children: [
                    Text(
                      "Share with collaborators",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              InkWell(
                onTap: () {
                  // Action when "Manage my account" is tapped
                },
                child: Row(
                  children: [
                    Text(
                      "Manage my account",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildBottomBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 11.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.0), // Espacement supplémentaire
          // Utilisation de SvgPicture.asset pour afficher le SVG
          SvgPicture.asset(
            'assets/images/img_tabs.svg',
            height: 32,
            width: 300,
          ),
        ],
      ),
    );
  }
}
