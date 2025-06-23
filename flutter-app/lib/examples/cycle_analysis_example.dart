import '../services/cycle_analysis_service.dart';

/// Exemple d'utilisation du CycleAnalysisService
class CycleAnalysisExample {
  static Future<void> demonstrateAnalysis() async {
    print('🚀 Démonstration du CycleAnalysisService\n');

    final service = CycleAnalysisService();

    // 1. Générer des données de test
    print('📊 Génération de données de test...');
    final testData = service.generateTestData();
    print('✅ ${testData.length} jours de données générées\n');

    // 2. Afficher quelques exemples de données
    print('📋 Exemples de données:');
    for (int i = 0; i < 3; i++) {
      final day = testData[i];
      print('Jour ${i + 1}:');
      print('  - Stress: ${day['stressLevel']}/100');
      print('  - Sommeil: ${day['sleepQuality']}/100');
      print(
          '  - Bouffées: ${day['hotFlashes']['frequency']}x (intensité: ${day['hotFlashes']['intensity']})');
      print(
          '  - Humeur: ${day['mood']['stabilityScore']}/100 (sautes: ${day['mood']['moodSwings']})');
      print('');
    }

    // 3. Analyser les données avec Gemini
    print('🤖 Analyse avec Gemini...');
    try {
      final analysisResult = await service.analyzeCycleData(testData);

      print('✅ Analyse terminée!\n');
      print('📈 Résultats de l\'analyse hebdomadaire:');
      print('  - Stress: ${analysisResult['stress']?.toStringAsFixed(1)}%');
      print('  - Sommeil: ${analysisResult['sleep']?.toStringAsFixed(1)}%');
      print(
          '  - Bouffées de chaleur: ${analysisResult['hotFlashes']?.toStringAsFixed(1)}%');
      print(
          '  - Stabilité de l\'humeur: ${analysisResult['moodStability']?.toStringAsFixed(1)}%');

      // 4. Interpréter les résultats
      print('\n💡 Interprétation:');
      _interpretResults(analysisResult);
    } catch (e) {
      print('❌ Erreur lors de l\'analyse: $e');
      print('🔄 Utilisation de l\'analyse locale de fallback...');

      final fallbackResult = await service.analyzeCycleData(testData);
      print('✅ Analyse locale terminée:');
      print('  - Stress: ${fallbackResult['stress']?.toStringAsFixed(1)}%');
      print('  - Sommeil: ${fallbackResult['sleep']?.toStringAsFixed(1)}%');
      print(
          '  - Bouffées de chaleur: ${fallbackResult['hotFlashes']?.toStringAsFixed(1)}%');
      print(
          '  - Stabilité de l\'humeur: ${fallbackResult['moodStability']?.toStringAsFixed(1)}%');
    }
  }

  /// Interpréter les résultats de l'analyse
  static void _interpretResults(Map<String, double> results) {
    print('');

    // Stress
    final stress = results['stress'] ?? 0;
    if (stress < -5) {
      print(
          '🎉 Excellent! Votre niveau de stress a diminué de ${stress.abs().toStringAsFixed(1)}%');
    } else if (stress > 5) {
      print(
          '⚠️ Attention: Votre niveau de stress a augmenté de ${stress.toStringAsFixed(1)}%');
    } else {
      print(
          '✅ Votre niveau de stress est stable (variation: ${stress.toStringAsFixed(1)}%)');
    }

    // Sommeil
    final sleep = results['sleep'] ?? 0;
    if (sleep > 5) {
      print(
          '😴 Amélioration! Votre qualité de sommeil a augmenté de ${sleep.toStringAsFixed(1)}%');
    } else if (sleep < -5) {
      print(
          '😴 Dégradation: Votre qualité de sommeil a diminué de ${sleep.abs().toStringAsFixed(1)}%');
    } else {
      print(
          '😴 Votre qualité de sommeil est stable (variation: ${sleep.toStringAsFixed(1)}%)');
    }

    // Bouffées de chaleur
    final hotFlashes = results['hotFlashes'] ?? 0;
    if (hotFlashes < -5) {
      print(
          '🔥 Réduction! Vos bouffées de chaleur ont diminué de ${hotFlashes.abs().toStringAsFixed(1)}%');
    } else if (hotFlashes > 5) {
      print(
          '🔥 Augmentation: Vos bouffées de chaleur ont augmenté de ${hotFlashes.toStringAsFixed(1)}%');
    } else {
      print(
          '🔥 Vos bouffées de chaleur sont stables (variation: ${hotFlashes.toStringAsFixed(1)}%)');
    }

    // Humeur
    final moodStability = results['moodStability'] ?? 0;
    if (moodStability > 5) {
      print(
          '😊 Amélioration! Votre stabilité d\'humeur a augmenté de ${moodStability.toStringAsFixed(1)}%');
    } else if (moodStability < -5) {
      print(
          '😔 Dégradation: Votre stabilité d\'humeur a diminué de ${moodStability.abs().toStringAsFixed(1)}%');
    } else {
      print(
          '😊 Votre stabilité d\'humeur est stable (variation: ${moodStability.toStringAsFixed(1)}%)');
    }
  }

  /// Exemple avec des données personnalisées
  static Future<void> demonstrateWithCustomData() async {
    print('\n🔧 Démonstration avec des données personnalisées\n');

    final service = CycleAnalysisService();

    // Créer des données personnalisées pour simuler une amélioration
    final customData = [
      // Semaine précédente (jours 1-7) - données plus mauvaises
      for (int i = 6; i >= 0; i--)
        {
          'date':
              DateTime.now().subtract(Duration(days: i + 7)).toIso8601String(),
          'stressLevel': 80, // Stress élevé
          'sleepQuality': 50, // Sommeil médiocre
          'hotFlashes': {
            'frequency': 8, // Beaucoup de bouffées
            'intensity': 4.0, // Intensité élevée
          },
          'mood': {
            'stabilityScore': 40, // Humeur instable
            'moodSwings': true, // Sautes d'humeur
          },
        },
      // Semaine courante (jours 8-14) - données meilleures
      for (int i = 6; i >= 0; i--)
        {
          'date': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
          'stressLevel': 50, // Stress réduit
          'sleepQuality': 80, // Meilleur sommeil
          'hotFlashes': {
            'frequency': 3, // Moins de bouffées
            'intensity': 2.5, // Intensité réduite
          },
          'mood': {
            'stabilityScore': 75, // Humeur plus stable
            'moodSwings': false, // Pas de sautes d'humeur
          },
        },
    ];

    print('📊 Analyse de données personnalisées (amélioration simulée)...');
    final result = await service.analyzeCycleData(customData);

    print('✅ Résultats:');
    print(
        '  - Stress: ${result['stress']?.toStringAsFixed(1)}% (attendu: négatif)');
    print(
        '  - Sommeil: ${result['sleep']?.toStringAsFixed(1)}% (attendu: positif)');
    print(
        '  - Bouffées de chaleur: ${result['hotFlashes']?.toStringAsFixed(1)}% (attendu: négatif)');
    print(
        '  - Stabilité de l\'humeur: ${result['moodStability']?.toStringAsFixed(1)}% (attendu: positif)');

    _interpretResults(result);
  }
}

/// Fonction principale pour exécuter les exemples
Future<void> main() async {
  await CycleAnalysisExample.demonstrateAnalysis();
  await CycleAnalysisExample.demonstrateWithCustomData();
}
