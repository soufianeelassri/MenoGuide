import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ask/services/auth_service.dart';

class ReasoningEngineService {
  static const String _queryUrl =
      'https://us-central1-aiplatform.googleapis.com/v1/projects/menovibe/locations/us-central1/reasoningEngines/4109789746673221632:query';

  final AuthService _authService = AuthService();

  Future<String> sendMessage(String message) async {
    final accessToken = await _authService.getGCloudAccessToken();
    if (accessToken == null) {
      throw Exception('Erreur: Impossible d\'obtenir le jeton d\'accès.');
    }

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'input': {
        'text': message,
      },
    });

    try {
      final response = await http
          .post(
            Uri.parse(_queryUrl),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

        if (decodedResponse['output'] != null &&
            decodedResponse['output'] is Map) {
          final outputMap = decodedResponse['output'] as Map<String, dynamic>;

          // First, check for an error field from the API
          if (outputMap['error'] != null) {
            throw Exception('Erreur de l\'agent: ${outputMap['error']}');
          }

          // If no error, check for a 'text' or 'content' key
          if (outputMap['text'] != null) {
            return outputMap['text'] as String;
          } else if (outputMap['content'] != null) {
            return outputMap['content'] as String;
          } else {
            // Add a debug print to see what the actual response is
            print('--- DEBUG: UNKNOWN API RESPONSE STRUCTURE ---');
            print(outputMap.toString());
            print('-------------------------------------------');
            throw Exception(
                'Réponse invalide de l\'API: La réponse ne contient ni "text", ni "content", ni "error".');
          }
        } else if (decodedResponse['output'] != null) {
          // Fallback if output is a direct string
          return decodedResponse['output'].toString();
        } else {
          throw Exception(
              'Réponse invalide de l\'API: champ "output" manquant.');
        }
      } else {
        throw Exception(
            'Erreur HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
