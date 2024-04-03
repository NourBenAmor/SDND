import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class DocumentService {
  static const String baseUrl = 'http://';

  // Endpoint pour télécharger un document avec des informations supplémentaires
  static Future<String> uploadDocument(
      String name, String, Map<String, dynamic> autresInfos) async {
    try {
      var tokens = await storage.read(key: 'jwt_token');
      if (tokens == null) {
        throw Exception("Erreur getting token ! ");
      }
      var url = Uri.parse('$baseUrl/upload');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $tokens",
        },
        body: jsonEncode({
          'nom': name,
          'type': ContentType,
          ...autresInfos,
        }),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Erreur lors du téléchargement du document: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Erreur lors du téléchargement du document: $error');
    }
  }

  // Endpoint pour récupérer tous les documents avec leurs détails et informations supplémentaires
  static Future<List<dynamic>> fetchAllDocuments() async {
    try {
      var url = Uri.parse(baseUrl);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erreur lors de la récupération des documents: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Erreur lors de la récupération des documents: $error');
    }
  }

  // Endpoint pour récupérer un document spécifique par son ID avec ses détails et informations supplémentaires
  static Future<dynamic> fetchDocumentById(String id) async {
    try {
      var url = Uri.parse('$baseUrl/$id');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erreur lors de la récupération du document: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Erreur lors de la récupération du document: $error');
    }
  }

  // Endpoint pour mettre à jour les informations d'un document spécifique par son ID
  static Future<void> updateDocument(
      String id, Map<String, dynamic> updatedData) async {
    try {
      var url = Uri.parse('$baseUrl/$id');
      var response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour du document: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Erreur lors de la mise à jour du document: $error');
    }
  }

  // Endpoint pour supprimer un document spécifique par son ID
  static Future<void> deleteDocument(String id) async {
    try {
      var url = Uri.parse('$baseUrl/$id');
      var response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la suppression du document: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Erreur lors de la suppression du document: $error');
    }
  }
}
