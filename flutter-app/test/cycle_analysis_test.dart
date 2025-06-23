import 'package:flutter_test/flutter_test.dart';
import 'package:ask/services/cycle_analysis_service.dart';

void main() {
  group('CycleAnalysisService Tests', () {
    late CycleAnalysisService service;

    setUp(() {
      service = CycleAnalysisService();
    });

    test('should generate test data with correct structure', () {
      final testData = service.generateTestData();

      expect(testData.length, 14); // 14 jours de données

      for (final day in testData) {
        expect(day['date'], isA<String>());
        expect(day['stressLevel'], isA<int>());
        expect(day['sleepQuality'], isA<int>());
        expect(day['hotFlashes'], isA<Map<String, dynamic>>());
        expect(day['mood'], isA<Map<String, dynamic>>());

        // Vérifier les plages de valeurs
        expect(day['stressLevel'], greaterThanOrEqualTo(0));
        expect(day['stressLevel'], lessThanOrEqualTo(100));
        expect(day['sleepQuality'], greaterThanOrEqualTo(0));
        expect(day['sleepQuality'], lessThanOrEqualTo(100));

        final hotFlashes = day['hotFlashes'] as Map<String, dynamic>;
        expect(hotFlashes['frequency'], isA<int>());
        expect(hotFlashes['intensity'], isA<double>());
        expect(hotFlashes['intensity'], greaterThanOrEqualTo(1.0));
        expect(hotFlashes['intensity'], lessThanOrEqualTo(5.0));

        final mood = day['mood'] as Map<String, dynamic>;
        expect(mood['stabilityScore'], isA<int>());
        expect(mood['moodSwings'], isA<bool>());
        expect(mood['stabilityScore'], greaterThanOrEqualTo(0));
        expect(mood['stabilityScore'], lessThanOrEqualTo(100));
      }
    });

    test('should perform local analysis with test data', () async {
      final testData = service.generateTestData();
      final result = await service.analyzeCycleData(testData);

      expect(result, isA<Map<String, double>>());
      expect(result['stress'], isA<double>());
      expect(result['sleep'], isA<double>());
      expect(result['hotFlashes'], isA<double>());
      expect(result['moodStability'], isA<double>());

      print('📊 Résultats de l\'analyse locale:');
      print('Stress: ${result['stress']?.toStringAsFixed(1)}%');
      print('Sommeil: ${result['sleep']?.toStringAsFixed(1)}%');
      print(
          'Bouffées de chaleur: ${result['hotFlashes']?.toStringAsFixed(1)}%');
      print(
          'Stabilité de l\'humeur: ${result['moodStability']?.toStringAsFixed(1)}%');
    });

    test('should handle empty data gracefully', () async {
      final result = await service.analyzeCycleData([]);

      expect(result['stress'], 0.0);
      expect(result['sleep'], 0.0);
      expect(result['hotFlashes'], 0.0);
      expect(result['moodStability'], 0.0);
    });

    test('should handle incomplete data', () async {
      final incompleteData = [
        {
          'date': '2024-01-01',
          'stressLevel': 50,
          'sleepQuality': 70,
          // hotFlashes et mood manquants
        },
        {
          'date': '2024-01-02',
          'stressLevel': 60,
          'sleepQuality': 80,
          'hotFlashes': {
            'frequency': 3,
            'intensity': 2.5,
          },
          // mood manquant
        },
      ];

      final result = await service.analyzeCycleData(incompleteData);

      expect(result, isA<Map<String, double>>());
      // Le service devrait gérer les données manquantes sans erreur
    });
  });
}
