import 'package:flutter/material.dart';
import 'package:airsafe/page/homepage.dart'; // Importez la page principale de votre application ici

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ajoutez ici votre logo ou votre image de chargement
            // Par exemple :
            Image.asset('assets/img_3.png', width: 200, height: 200),
            CircularProgressIndicator(), // Indicateur de chargement
          ],
        ),
      ),
    );
  }

  // Utilisez un FutureBuilder ou un Future.delayed pour passer à l'application principale après un certain délai
  Future<void> navigateToMainApp(BuildContext context) async {
    await Future.delayed(Duration(seconds: 3)); // Attendez 3 secondes
    Navigator.pushReplacement( // Remplacez la page actuelle par la page principale de votre application
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
