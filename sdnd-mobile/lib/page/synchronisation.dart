import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SynchronizationPage extends StatelessWidget {
  const SynchronizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text("Back"),
            SizedBox(width: 10), // Espacement entre les textes
            Text("Synchronization options"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 34.0),
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
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 267.0,
                      child: Text(
                        "Automatically sync your documents",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  const Align(
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
              const SizedBox(height: 41.0),
              const Text(
                "Settings",
                style: TextStyle(fontSize: 32.0),
              ),
              const SizedBox(height: 10.0),
              InkWell(
                onTap: () {
                  // Action when "Share with collaborators" is tapped
                },
                child: const Row(
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
              const SizedBox(height: 20.0),
              InkWell(
                onTap: () {
                  // Action when "Manage my account" is tapped
                },
                child: const Row(
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
      margin: const EdgeInsets.symmetric(horizontal: 11.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10.0), // Espacement supplémentaire
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
