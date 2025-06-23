import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';
import '../config/api_config.dart';
import '../models/weather_data.dart';
import 'cache_service.dart';

class WeatherService {
  final CacheService _cacheService = CacheService();

  /// Get current weather data based on user's location
  Future<WeatherData?> getCurrentWeather() async {
    try {
      print('🌍 Starting location detection...');

      // Vérifier d'abord le cache
      final cachedWeather = await _cacheService.getCachedWeatherData();
      if (cachedWeather != null) {
        print('✅ Données météo récupérées du cache');
        return cachedWeather;
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      print('📍 Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        print('🔐 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        print('📍 Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied by user');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. Please enable in device settings.');
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS.');
      }

      print('🎯 Getting current position...');
      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print(
          '📍 Location obtained: ${position.latitude}, ${position.longitude}');
      print('📍 Accuracy: ${position.accuracy}m');
      print('📍 Altitude: ${position.altitude}m');

      // Check if weather API is configured
      if (!ApiConfig.isConfigured) {
        print('⚠️ Weather API not configured, returning mock data');
        final mockData = _getMockWeatherData(position);
        // Sauvegarder les données mock en cache
        await _cacheService.cacheWeatherData(mockData);
        return mockData;
      }

      // Fetch weather data using OpenWeatherMap API
      print('🌤️ Fetching weather data from API...');
      final weatherResponse = await http
          .get(
            Uri.parse(
                '${ApiConfig.openWeatherBaseUrl}/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${ApiConfig.openWeatherApiKey}&units=metric'),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Weather API response status: ${weatherResponse.statusCode}');

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        print('✅ Weather data received successfully');
        final weatherDataObj = WeatherData.fromJson(weatherData);

        // Sauvegarder en cache
        await _cacheService.cacheWeatherData(weatherDataObj);

        return weatherDataObj;
      } else {
        print(
            '❌ Weather API error: ${weatherResponse.statusCode} - ${weatherResponse.body}');
        throw Exception(
            'Failed to load weather data: ${weatherResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting weather data: $e');
      return null;
    }
  }

  /// Get mock weather data when API is not configured
  WeatherData _getMockWeatherData(Position position) {
    return WeatherData(
      temperature: 22.0,
      description: 'Partly Cloudy',
      humidity: 65,
      windSpeed: 3.2,
      location: 'Your Location',
      icon: '02d',
    );
  }

  /// Get personalized advice based on weather conditions
  Future<String?> getPersonalizedAdvice(WeatherData weatherData) async {
    try {
      // Créer une clé unique pour cette météo
      final weatherKey = _cacheService.createWeatherKey(weatherData);

      // Vérifier d'abord le cache
      final cachedAdvice = await _cacheService.getCachedAdvice(weatherKey);
      if (cachedAdvice != null) {
        print('✅ Conseil Gemini récupéré du cache');
        return cachedAdvice;
      }

      const maxRetries = 3;
      int retryCount = 0;

      while (retryCount <= maxRetries) {
        try {
          print(
              '🤖 Generating personalized advice with Gemini... (attempt ${retryCount + 1})');

          // Use progressively shorter prompts
          final prompt = _getPromptForAttempt(retryCount, weatherData);

          // Call Gemini API without token limits
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
                    'temperature': 0.7,
                    'topP': 0.9,
                    'topK': 40,
                    'candidateCount': 1,
                  },
                }),
              )
              .timeout(const Duration(seconds: 15));

          print('🤖 Gemini API response status: ${response.statusCode}');
          print('🤖 Gemini API response body: ${response.body}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            // Check for finish reason
            if (data['candidates'] != null &&
                data['candidates'].isNotEmpty &&
                data['candidates'][0]['finishReason'] == 'MAX_TOKENS') {
              print(
                  '⚠️ Response hit MAX_TOKENS limit, trying shorter prompt...');
              retryCount++;
              continue;
            }

            // Try to parse response
            String? advice = _parseGeminiResponse(data);

            if (advice != null && advice.isNotEmpty && advice.length > 5) {
              print('✅ Gemini advice generated successfully: $advice');

              // Sauvegarder le conseil en cache
              await _cacheService.cacheAdvice(weatherKey, advice);

              return advice;
            } else {
              print('❌ No valid advice found in Gemini response');
              retryCount++;
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
          } else {
            print(
                '❌ Gemini API error: ${response.statusCode} - ${response.body}');
            retryCount++;
            await Future.delayed(Duration(seconds: 1));
            continue;
          }
        } catch (e) {
          print('❌ Error getting Gemini advice: $e');
          retryCount++;
          await Future.delayed(Duration(seconds: 1));
          continue;
        }
      }

      // All retries failed, use fallback
      print(
          '🔄 Using local fallback advice after ${retryCount} failed attempts');
      final fallbackAdvice = _getLocalAdvice(weatherData);

      // Sauvegarder le conseil de fallback en cache
      await _cacheService.cacheAdvice(weatherKey, fallbackAdvice);

      return fallbackAdvice;
    } catch (e) {
      print('❌ Error in getPersonalizedAdvice: $e');
      return _getLocalAdvice(weatherData);
    }
  }

  /// Get appropriate prompt based on retry attempt
  String _getPromptForAttempt(int attempt, WeatherData weatherData) {
    final temp = weatherData.temperature.round();

    switch (attempt) {
      case 0:
        return 'Weather: ${temp}°C. Give one wellness tip for menopause. Do not use asterisks (*) in your response.';
      case 1:
        return 'Weather: ${temp}°C. One menopause tip. No asterisks.';
      case 2:
        return '${temp}°C. Wellness tip. Plain text only.';
      default:
        return 'Tip.';
    }
  }

  /// Parse Gemini response using multiple strategies
  String? _parseGeminiResponse(Map<String, dynamic> data) {
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
          return _cleanAdviceText(text.trim());
        }
      }
    } catch (e) {
      print('❌ Error parsing standard Gemini response: $e');
    }

    try {
      // Strategy 2: Alternative response structures
      if (data['text'] != null) {
        return _cleanAdviceText(data['text'].toString().trim());
      }
      if (data['content'] != null && data['content']['text'] != null) {
        return _cleanAdviceText(data['content']['text'].toString().trim());
      }
      if (data['response'] != null) {
        return _cleanAdviceText(data['response'].toString().trim());
      }
    } catch (e) {
      print('❌ Error parsing alternative Gemini response: $e');
    }

    try {
      // Strategy 3: Deep nested search
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        if (candidate['text'] != null) {
          return _cleanAdviceText(candidate['text'].toString().trim());
        }
        if (candidate['content'] != null && candidate['content'] is String) {
          return _cleanAdviceText(candidate['content'].toString().trim());
        }
      }
    } catch (e) {
      print('❌ Error parsing deep nested response: $e');
    }

    return null;
  }

  /// Clean advice text by removing asterisks and other unwanted characters
  String _cleanAdviceText(String text) {
    // Remove asterisks
    String cleaned = text.replaceAll('*', '');

    // Remove multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Remove leading/trailing whitespace
    cleaned = cleaned.trim();

    // Remove common unwanted patterns
    cleaned =
        cleaned.replaceAll(RegExp(r'^\*+\s*'), ''); // Remove leading asterisks
    cleaned =
        cleaned.replaceAll(RegExp(r'\s*\*+$'), ''); // Remove trailing asterisks

    return cleaned;
  }

  /// Local fallback advice when AI service is unavailable
  String _getLocalAdvice(WeatherData weatherData) {
    final temp = weatherData.temperature;
    final description = weatherData.description.toLowerCase();

    if (temp > 25) {
      return "Il fait chaud aujourd'hui ! Restez hydratée et portez des vêtements légers et respirants pour gérer les bouffées de chaleur.";
    } else if (temp > 15) {
      return "Météo agréable ! Parfait pour une promenade douce à l'extérieur pour booster votre humeur et votre énergie.";
    } else if (temp > 5) {
      return "Journée fraîche ! Couvrez-vous avec des vêtements chauds et envisagez un thé chaud pour rester confortable.";
    } else {
      return "Alerte météo froide ! Couvrez-vous bien et restez active à l'intérieur pour maintenir votre température corporelle.";
    }
  }

  /// Test location services
  Future<Map<String, dynamic>> testLocationServices() async {
    try {
      final result = <String, dynamic>{};

      // Check location service enabled
      result['locationServiceEnabled'] =
          await Geolocator.isLocationServiceEnabled();

      // Check permission status
      result['permissionStatus'] = await Geolocator.checkPermission();

      // Try to get last known position
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        result['lastKnownPosition'] = lastPosition != null
            ? {
                'latitude': lastPosition.latitude,
                'longitude': lastPosition.longitude,
                'accuracy': lastPosition.accuracy,
              }
            : null;
      } catch (e) {
        result['lastKnownPosition'] = 'Error: $e';
      }

      return result;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cacheService.getCacheStats();
  }

  /// Clear expired cache
  Future<void> clearExpiredCache() async {
    await _cacheService.clearExpiredCache();
  }
}
