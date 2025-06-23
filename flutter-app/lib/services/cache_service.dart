import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';

class CacheService {
  static const String _weatherCacheKey = 'weather_cache';
  static const String _adviceCacheKey = 'advice_cache';
  static const String _lastUpdateKey = 'last_update';

  // Durée de cache (en minutes)
  static const int _weatherCacheDuration = 30; // 30 minutes pour la météo
  static const int _adviceCacheDuration = 60; // 1 heure pour les conseils

  /// Sauvegarder les données météo
  Future<void> cacheWeatherData(WeatherData weatherData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = {
        'temperature': weatherData.temperature,
        'description': weatherData.description,
        'humidity': weatherData.humidity,
        'windSpeed': weatherData.windSpeed,
        'location': weatherData.location,
        'icon': weatherData.icon,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_weatherCacheKey, jsonEncode(weatherJson));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ Données météo sauvegardées en cache');
    } catch (e) {
      print('❌ Erreur sauvegarde cache météo: $e');
    }
  }

  /// Récupérer les données météo du cache
  Future<WeatherData?> getCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString(_weatherCacheKey);

      if (weatherJson == null) return null;

      final weatherData = jsonDecode(weatherJson);
      final timestamp = weatherData['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final cacheAgeMinutes = cacheAge / (1000 * 60);

      // Vérifier si le cache est encore valide
      if (cacheAgeMinutes > _weatherCacheDuration) {
        print('⚠️ Cache météo expiré (${cacheAgeMinutes.round()} minutes)');
        return null;
      }

      print(
          '✅ Données météo récupérées du cache (${cacheAgeMinutes.round()} minutes)');

      return WeatherData(
        temperature: weatherData['temperature'].toDouble(),
        description: weatherData['description'],
        humidity: weatherData['humidity'],
        windSpeed: weatherData['windSpeed'].toDouble(),
        location: weatherData['location'],
        icon: weatherData['icon'],
      );
    } catch (e) {
      print('❌ Erreur récupération cache météo: $e');
      return null;
    }
  }

  /// Sauvegarder les conseils Gemini
  Future<void> cacheAdvice(String weatherKey, String advice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adviceData = {
        'advice': advice,
        'weatherKey': weatherKey,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_adviceCacheKey, jsonEncode(adviceData));
      print('✅ Conseil Gemini sauvegardé en cache');
    } catch (e) {
      print('❌ Erreur sauvegarde cache conseil: $e');
    }
  }

  /// Récupérer les conseils Gemini du cache
  Future<String?> getCachedAdvice(String weatherKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adviceJson = prefs.getString(_adviceCacheKey);

      if (adviceJson == null) return null;

      final adviceData = jsonDecode(adviceJson);
      final timestamp = adviceData['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final cacheAgeMinutes = cacheAge / (1000 * 60);

      // Vérifier si le cache est encore valide et correspond à la météo actuelle
      if (cacheAgeMinutes > _adviceCacheDuration ||
          adviceData['weatherKey'] != weatherKey) {
        print('⚠️ Cache conseil expiré ou météo changée');
        return null;
      }

      print(
          '✅ Conseil Gemini récupéré du cache (${cacheAgeMinutes.round()} minutes)');
      return adviceData['advice'];
    } catch (e) {
      print('❌ Erreur récupération cache conseil: $e');
      return null;
    }
  }

  /// Créer une clé unique pour la météo (pour le cache des conseils)
  String createWeatherKey(WeatherData weatherData) {
    // Créer une clé basée sur la température et la description
    final temp = weatherData.temperature.round();
    final desc = weatherData.description.toLowerCase();
    return '${temp}_${desc}';
  }

  /// Vérifier si le cache est récent
  Future<bool> isCacheRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey);

      if (lastUpdate == null) return false;

      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdate;
      final cacheAgeMinutes = cacheAge / (1000 * 60);

      return cacheAgeMinutes < _weatherCacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// Nettoyer le cache expiré
  Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString(_weatherCacheKey);
      final adviceJson = prefs.getString(_adviceCacheKey);

      // Nettoyer cache météo expiré
      if (weatherJson != null) {
        final weatherData = jsonDecode(weatherJson);
        final timestamp = weatherData['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        final cacheAgeMinutes = cacheAge / (1000 * 60);

        if (cacheAgeMinutes > _weatherCacheDuration) {
          await prefs.remove(_weatherCacheKey);
          print('🗑️ Cache météo expiré supprimé');
        }
      }

      // Nettoyer cache conseil expiré
      if (adviceJson != null) {
        final adviceData = jsonDecode(adviceJson);
        final timestamp = adviceData['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        final cacheAgeMinutes = cacheAge / (1000 * 60);

        if (cacheAgeMinutes > _adviceCacheDuration) {
          await prefs.remove(_adviceCacheKey);
          print('🗑️ Cache conseil expiré supprimé');
        }
      }
    } catch (e) {
      print('❌ Erreur nettoyage cache: $e');
    }
  }

  /// Obtenir les statistiques du cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString(_weatherCacheKey);
      final adviceJson = prefs.getString(_adviceCacheKey);

      Map<String, dynamic> stats = {
        'weatherCacheExists': weatherJson != null,
        'adviceCacheExists': adviceJson != null,
      };

      if (weatherJson != null) {
        final weatherData = jsonDecode(weatherJson);
        final timestamp = weatherData['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        final cacheAgeMinutes = cacheAge / (1000 * 60);
        stats['weatherCacheAge'] = cacheAgeMinutes.round();
        stats['weatherCacheValid'] = cacheAgeMinutes < _weatherCacheDuration;
      }

      if (adviceJson != null) {
        final adviceData = jsonDecode(adviceJson);
        final timestamp = adviceData['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        final cacheAgeMinutes = cacheAge / (1000 * 60);
        stats['adviceCacheAge'] = cacheAgeMinutes.round();
        stats['adviceCacheValid'] = cacheAgeMinutes < _adviceCacheDuration;
      }

      return stats;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
