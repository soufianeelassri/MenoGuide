import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/menovibe_agent.dart';

class MenovibeApiService {
  static const String _baseUrl = 'http://localhost:8080/v1';

  // Create a task for user
  Future<String> createTask(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['task_id'] ?? '';
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      // For now, return a mock task ID for development
      return 'task_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Stream message updates for user
  Stream<List<MenovibeMessage>> streamMessageUpdates(
      String userId, String message) async* {
    try {
      final request = http.Request(
        'GET',
        Uri.parse(
            '$_baseUrl/tasks/$userId/updates?message=${Uri.encodeComponent(message)}'),
      );

      final streamedResponse = await request.send();

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        if (chunk.isNotEmpty) {
          try {
            final data = jsonDecode(chunk);
            final messages = _parseMessages(data);
            yield messages;
          } catch (e) {
            // Handle parsing errors
            print('Error parsing chunk: $e');
          }
        }
      }
    } catch (e) {
      // For development, yield mock responses
      yield await _generateMockResponses(message);
    }
  }

  // Parse messages from API response
  List<MenovibeMessage> _parseMessages(Map<String, dynamic> data) {
    final messages = <MenovibeMessage>[];

    if (data['messages'] != null) {
      for (final messageData in data['messages']) {
        try {
          final message = MenovibeMessage.fromJson(messageData);
          messages.add(message);
        } catch (e) {
          print('Error parsing message: $e');
        }
      }
    }

    return messages;
  }

  // Generate mock responses for development
  Future<List<MenovibeMessage>> _generateMockResponses(
      String userMessage) async {
    final responses = <MenovibeMessage>[];
    final lowerMessage = userMessage.toLowerCase();

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    // Determine which agents should respond based on the message
    if (lowerMessage.contains('nutrition') ||
        lowerMessage.contains('diet') ||
        lowerMessage.contains('food')) {
      responses.add(MenovibeMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'As your Nutrition Expert, I recommend focusing on phytoestrogen-rich foods like soy products, flaxseeds, and legumes. These can help balance hormones naturally during menopause.',
        type: MessageType.agent,
        timestamp: DateTime.now(),
        agentType: MenovibeAgentType.nutritionExpert,
        agentName: 'Nutrition Expert',
        suggestions: [
          'What foods help with hot flashes?',
          'Supplements for bone health',
          'Meal planning tips',
        ],
      ));
    }

    if (lowerMessage.contains('stress') ||
        lowerMessage.contains('anxiety') ||
        lowerMessage.contains('mood')) {
      responses.add(MenovibeMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content:
            'I\'m here to support you emotionally. Stress and anxiety are very common during this transition. Let\'s start with some breathing exercises and mindfulness practices.',
        type: MessageType.agent,
        timestamp: DateTime.now(),
        agentType: MenovibeAgentType.lifeCoach,
        agentName: 'Life Coach',
        suggestions: [
          'Stress management techniques',
          'Sleep improvement strategies',
          'Building self-confidence',
        ],
      ));
    }

    if (lowerMessage.contains('community') ||
        lowerMessage.contains('group') ||
        lowerMessage.contains('support')) {
      responses.add(MenovibeMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        content:
            'I can help you find local support groups and resources! There are several options including online communities and in-person meetups specifically for menopause support.',
        type: MessageType.agent,
        timestamp: DateTime.now(),
        agentType: MenovibeAgentType.communityConnector,
        agentName: 'Community Connector',
        suggestions: [
          'Find local support groups',
          'Healthcare provider recommendations',
          'Online community resources',
        ],
      ));
    }

    // Always add Maestro's integration response
    if (responses.isNotEmpty) {
      responses.add(MenovibeMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        content:
            'I\'ve coordinated responses from our specialists to give you comprehensive support. These approaches work together to provide holistic care for your menopause journey.',
        type: MessageType.agent,
        timestamp: DateTime.now(),
        agentType: MenovibeAgentType.maestro,
        agentName: 'Maestro',
        suggestions: [
          'Ask a follow-up question',
          'Get more specific advice',
          'Explore other areas of support',
        ],
      ));
    } else {
      // Default response if no specific agents were triggered
      responses.add(MenovibeMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Thank you for sharing that with me. I\'m here with our team of specialists to support your menopause wellness journey. How can I help you today?',
        type: MessageType.agent,
        timestamp: DateTime.now(),
        agentType: MenovibeAgentType.maestro,
        agentName: 'Maestro',
        suggestions: [
          'I\'m having hot flashes',
          'My mood has been unstable',
          'I\'m having trouble sleeping',
          'Tell me about nutrition for menopause',
        ],
      ));
    }

    return responses;
  }
}
