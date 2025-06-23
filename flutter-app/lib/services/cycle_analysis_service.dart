import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CycleAnalysisService {
  /// Analyser les données de cycle et générer des statistiques hebdomadaires
  Future<Map<String, double>> analyzeCycleData(
      List<Map<String, dynamic>> cycleData) async {
    try {
      print('🔍 Début de l\'analyse des données de cycle...');

      // Préparer les données pour Gemini
      final prompt = _createAnalysisPrompt(cycleData);

      // Appel à Gemini API
      final response = await http
          .post(
            Uri.parse(
                '${ApiConfig.geminiApiEndpoint}?key=${ApiConfig.geminiApiKey}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'contents': [
                {
                  'parts': [
                    {
                      'text': prompt,
                    }
                  ]
                }
              ],
              'generationConfig': {
                'temperature':
                    0.1, // Faible température pour des résultats cohérents
                'topP': 0.8,
                'topK': 40,
                'candidateCount': 1,
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('🤖 Gemini API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final analysisResult = _parseGeminiResponse(data);

        if (analysisResult != null) {
          print('✅ Analyse des données de cycle terminée avec succès');
          return analysisResult;
        }
      }

      print('⚠️ Utilisation de l\'analyse locale de fallback');
      return _getLocalAnalysis(cycleData);
    } catch (e) {
      print('❌ Erreur dans l\'analyse des données: $e');
      return _getLocalAnalysis(cycleData);
    }
  }

  /// Créer le prompt pour Gemini
  String _createAnalysisPrompt(List<Map<String, dynamic>> cycleData) {
    final dataJson = jsonEncode(cycleData);

    return '''
Tu es un agent d'analyse bien-être spécialisé dans le suivi de la ménopause.

Analyse les données de cycle suivantes pour les 14 derniers jours et compare la semaine courante (7 derniers jours) à la semaine précédente.

Données: $dataJson

Calcule pour chaque métrique:

1. **Stress** : variation en % du niveau de stress moyen (négatif = amélioration)
2. **Sommeil** : variation en % de la qualité moyenne du sommeil  
3. **Bouffées de Chaleur** : variation de la fréquence moyenne (prendre en compte l'intensité)
4. **Stabilité de l'humeur** : % de stabilité basé sur stabilityScore et mood swings

Rends UNIQUEMENT un objet JSON avec ces 4 clés:
{
  "stress": -8.3,
  "sleep": 12.5, 
  "hotFlashes": -5.0,
  "moodStability": 7.1
}

(positive = amélioration, negative = dégradation)

Ne réponds que l'objet JSON, rien d'autre.
''';
  }

  /// Parser la réponse de Gemini
  Map<String, double>? _parseGeminiResponse(Map<String, dynamic> data) {
    try {
      // Strategy 1: Standard Gemini response structure
      if (data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        final text =
            data['candidates'][0]['content']['parts'][0]['text']?.toString();
        if (text != null && text.trim().isNotEmpty) {
          return _extractJsonFromText(text.trim());
        }
      }
    } catch (e) {
      print('❌ Erreur parsing standard Gemini response: $e');
    }

    try {
      // Strategy 2: Alternative response structures
      if (data['text'] != null) {
        return _extractJsonFromText(data['text'].toString().trim());
      }
      if (data['content'] != null && data['content']['text'] != null) {
        return _extractJsonFromText(data['content']['text'].toString().trim());
      }
    } catch (e) {
      print('❌ Erreur parsing alternative Gemini response: $e');
    }

    return null;
  }

  /// Extraire JSON du texte de réponse
  Map<String, double>? _extractJsonFromText(String text) {
    try {
      // Nettoyer le texte
      String cleanedText =
          text.replaceAll('```json', '').replaceAll('```', '').trim();

      // Chercher le JSON dans le texte
      final jsonMatch = RegExp(
              r'\{[^{}]*"stress"[^{}]*"sleep"[^{}]*"hotFlashes"[^{}]*"moodStability"[^{}]*\}')
          .firstMatch(cleanedText);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0);
        final jsonData = jsonDecode(jsonString!);

        return {
          'stress': (jsonData['stress'] as num).toDouble(),
          'sleep': (jsonData['sleep'] as num).toDouble(),
          'hotFlashes': (jsonData['hotFlashes'] as num).toDouble(),
          'moodStability': (jsonData['moodStability'] as num).toDouble(),
        };
      }
    } catch (e) {
      print('❌ Erreur extraction JSON: $e');
    }

    return null;
  }

  /// Analyse locale de fallback
  Map<String, double> _getLocalAnalysis(List<Map<String, dynamic>> cycleData) {
    try {
      if (cycleData.length < 14) {
        print(
            '⚠️ Données insuffisantes pour l\'analyse (${cycleData.length}/14 jours)');
        return _getDefaultStats();
      }

      // Séparer les deux semaines
      final week1 = cycleData.take(7).toList(); // Semaine précédente
      final week2 = cycleData.skip(7).take(7).toList(); // Semaine courante

      // Calculer les moyennes pour chaque semaine
      final week1Stats = _calculateWeekStats(week1);
      final week2Stats = _calculateWeekStats(week2);

      // Calculer les variations
      final stressVariation = _calculateVariation(
          week1Stats['stress'] ?? 0, week2Stats['stress'] ?? 0);
      final sleepVariation = _calculateVariation(
          week1Stats['sleep'] ?? 0, week2Stats['sleep'] ?? 0);
      final hotFlashesVariation = _calculateVariation(
          week1Stats['hotFlashes'] ?? 0, week2Stats['hotFlashes'] ?? 0);
      final moodStabilityVariation = _calculateVariation(
          week1Stats['moodStability'] ?? 0, week2Stats['moodStability'] ?? 0);

      return {
        'stress': stressVariation,
        'sleep': sleepVariation,
        'hotFlashes': hotFlashesVariation,
        'moodStability': moodStabilityVariation,
      };
    } catch (e) {
      print('❌ Erreur analyse locale: $e');
      return _getDefaultStats();
    }
  }

  /// Calculer les statistiques d'une semaine
  Map<String, double> _calculateWeekStats(List<Map<String, dynamic>> weekData) {
    double totalStress = 0;
    double totalSleep = 0;
    double totalHotFlashes = 0;
    double totalMoodStability = 0;
    int validDays = 0;

    for (final day in weekData) {
      try {
        // Stress
        if (day['stressLevel'] != null) {
          totalStress += (day['stressLevel'] as num).toDouble();
        }

        // Sommeil
        if (day['sleepQuality'] != null) {
          totalSleep += (day['sleepQuality'] as num).toDouble();
        }

        // Bouffées de chaleur
        if (day['hotFlashes'] != null) {
          final hotFlashes = day['hotFlashes'] as Map<String, dynamic>;
          final frequency = (hotFlashes['frequency'] as num).toDouble();
          final intensity = (hotFlashes['intensity'] as num).toDouble();
          totalHotFlashes += frequency * intensity; // Pondérer par l'intensité
        }

        // Humeur
        if (day['mood'] != null) {
          final mood = day['mood'] as Map<String, dynamic>;
          final stabilityScore = (mood['stabilityScore'] as num).toDouble();
          final moodSwings = mood['moodSwings'] as bool;

          // Réduire la stabilité si il y a des sautes d'humeur
          totalMoodStability +=
              moodSwings ? stabilityScore * 0.8 : stabilityScore;
        }

        validDays++;
      } catch (e) {
        print('⚠️ Erreur traitement jour: $e');
      }
    }

    if (validDays == 0) {
      return {
        'stress': 0,
        'sleep': 0,
        'hotFlashes': 0,
        'moodStability': 0,
      };
    }

    return {
      'stress': totalStress / validDays,
      'sleep': totalSleep / validDays,
      'hotFlashes': totalHotFlashes / validDays,
      'moodStability': totalMoodStability / validDays,
    };
  }

  /// Calculer la variation en pourcentage
  double _calculateVariation(double oldValue, double newValue) {
    if (oldValue == 0) {
      return newValue > 0 ? 100.0 : 0.0;
    }

    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// Statistiques par défaut
  Map<String, double> _getDefaultStats() {
    return {
      'stress': 0.0,
      'sleep': 0.0,
      'hotFlashes': 0.0,
      'moodStability': 0.0,
    };
  }

  /// Générer des données de test
  List<Map<String, dynamic>> generateTestData() {
    final List<Map<String, dynamic>> testData = [];
    final now = DateTime.now();

    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Simuler des variations réalistes
      final baseStress = 60 + (i % 3) * 10; // Variation autour de 60
      final baseSleep = 70 + (i % 2) * 15; // Variation autour de 70
      final baseHotFlashes = 3 + (i % 4); // 0-6 bouffées
      final baseMoodStability = 75 + (i % 3) * 8; // Variation autour de 75

      testData.add({
        'date': date.toIso8601String(),
        'stressLevel': baseStress,
        'sleepQuality': baseSleep,
        'hotFlashes': {
          'frequency': baseHotFlashes,
          'intensity': 2.5 + (i % 3) * 0.5, // 2.5-4.0
        },
        'mood': {
          'stabilityScore': baseMoodStability,
          'moodSwings': i % 4 == 0, // Sautes d'humeur occasionnelles
        },
      });
    }

    return testData;
  }
}
