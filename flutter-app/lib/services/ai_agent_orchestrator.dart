import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

enum AgentType {
  luna, // Wellness Coach
  drSage, // Medical Expert
  maestro, // Conductor/Orchestrator
}

enum QueryCategory {
  lifestyle,
  medical,
  emotional,
  complex,
  unknown,
}

class AIAgent {
  final AgentType type;
  final String name;
  final String description;
  final String avatarUrl;
  final String personality;
  final List<String> specialties;
  final String systemPrompt;

  const AIAgent({
    required this.type,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.personality,
    required this.specialties,
    required this.systemPrompt,
  });
}

class AIResponse {
  final AgentType agentType;
  final String agentName;
  final String message;
  final DateTime timestamp;
  final bool isTyping;
  final List<String>? suggestions;
  final Map<String, dynamic>? metadata;

  const AIResponse({
    required this.agentType,
    required this.agentName,
    required this.message,
    required this.timestamp,
    this.isTyping = false,
    this.suggestions,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'agentType': agentType.name,
      'agentName': agentName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isTyping': isTyping,
      'suggestions': suggestions,
      'metadata': metadata,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      agentType: AgentType.values.firstWhere(
        (e) => e.name == json['agentType'],
        orElse: () => AgentType.luna,
      ),
      agentName: json['agentName'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isTyping: json['isTyping'] ?? false,
      suggestions: json['suggestions'] != null
          ? List<String>.from(json['suggestions'])
          : null,
      metadata: json['metadata'],
    );
  }
}

class AIAgentOrchestrator {
  static final AIAgentOrchestrator _instance = AIAgentOrchestrator._internal();
  factory AIAgentOrchestrator() => _instance;
  AIAgentOrchestrator._internal();

  // AI Agents Configuration
  static const Map<AgentType, AIAgent> _agents = {
    AgentType.luna: AIAgent(
      type: AgentType.luna,
      name: 'Luna',
      description: 'Your wellness coach and lifestyle guide',
      avatarUrl: 'assets/avatars/luna_avatar.png',
      personality:
          'Warm, supportive, and encouraging. Focuses on lifestyle, stress management, sleep, diet, and emotional well-being.',
      specialties: [
        'Lifestyle coaching',
        'Stress management',
        'Sleep optimization',
        'Nutrition guidance',
        'Emotional support',
        'Mindfulness practices',
        'Exercise recommendations',
      ],
      systemPrompt: '''
You are Luna, a compassionate wellness coach specializing in menopause support. Your role is to provide lifestyle guidance, emotional support, and practical advice for managing menopause symptoms through natural approaches.

Focus areas:
- Stress management and relaxation techniques
- Sleep hygiene and optimization
- Nutrition and dietary recommendations
- Exercise and physical activity
- Mindfulness and meditation practices
- Emotional well-being and mood support
- Lifestyle adjustments for menopause

Always be warm, encouraging, and supportive. Provide practical, actionable advice. Never give medical advice - refer to Dr. Sage for medical concerns.
''',
    ),
    AgentType.drSage: AIAgent(
      type: AgentType.drSage,
      name: 'Dr. Sage',
      description: 'Medical expert and hormone specialist',
      avatarUrl: 'assets/avatars/dr_sage_avatar.png',
      personality:
          'Professional, knowledgeable, and thorough. Focuses on medical information, hormone changes, treatments, and physical symptoms.',
      specialties: [
        'Hormone education',
        'Symptom explanation',
        'Treatment options',
        'Medical terminology',
        'Physical health',
        'Medication information',
        'When to see a doctor',
      ],
      systemPrompt: '''
You are Dr. Sage, a medical expert specializing in menopause and women's health. Your role is to provide accurate medical information, explain symptoms, and discuss treatment options.

Focus areas:
- Hormone changes and their effects
- Symptom explanation and causes
- Treatment options (HRT, supplements, etc.)
- Medical terminology and concepts
- Physical health concerns
- When to consult healthcare providers
- Evidence-based medical information

Always be professional and accurate. Provide evidence-based information. Recommend consulting healthcare providers for specific medical advice.
''',
    ),
    AgentType.maestro: AIAgent(
      type: AgentType.maestro,
      name: 'Maestro',
      description: 'AI conductor that orchestrates responses',
      avatarUrl: 'assets/avatars/maestro_avatar.png',
      personality:
          'Intelligent, analytical, and collaborative. Coordinates between agents for optimal responses.',
      specialties: [
        'Query analysis',
        'Agent coordination',
        'Response orchestration',
        'Complex question handling',
        'Multi-agent collaboration',
      ],
      systemPrompt: '''
You are Maestro, an AI conductor that analyzes user queries and determines the best agent(s) to respond. You coordinate between Luna (wellness coach) and Dr. Sage (medical expert).

Analysis criteria:
- Lifestyle/emotional queries → Luna
- Medical/hormone queries → Dr. Sage
- Complex queries → Both agents (collaborative response)
- Unclear queries → Ask for clarification

For complex queries, coordinate a collaborative response where both agents contribute their expertise.
''',
    ),
  };

  // Query Analysis Keywords
  static const Map<QueryCategory, List<String>> _categoryKeywords = {
    QueryCategory.lifestyle: [
      'sleep',
      'stress',
      'diet',
      'exercise',
      'lifestyle',
      'routine',
      'habits',
      'relaxation',
      'meditation',
      'mindfulness',
      'wellness',
      'self-care',
      'energy',
      'mood',
      'happiness',
      'confidence',
      'motivation',
    ],
    QueryCategory.medical: [
      'hormone',
      'estrogen',
      'progesterone',
      'testosterone',
      'treatment',
      'medication',
      'hrt',
      'supplement',
      'vitamin',
      'symptom',
      'pain',
      'doctor',
      'physician',
      'medical',
      'diagnosis',
      'test',
      'scan',
      'hot flash',
      'night sweat',
      'vaginal',
      'urinary',
      'bone',
      'heart',
    ],
    QueryCategory.emotional: [
      'anxiety',
      'depression',
      'mood swing',
      'irritability',
      'sadness',
      'worry',
      'fear',
      'stress',
      'overwhelm',
      'frustration',
      'anger',
      'loneliness',
      'isolation',
      'confidence',
      'self-esteem',
      'identity',
    ],
  };

  // Stream controllers for real-time communication
  final StreamController<AIResponse> _responseController =
      StreamController<AIResponse>.broadcast();
  final StreamController<bool> _typingController =
      StreamController<bool>.broadcast();

  Stream<AIResponse> get responseStream => _responseController.stream;
  Stream<bool> get typingStream => _typingController.stream;

  // Get agent by type
  AIAgent getAgent(AgentType type) {
    return _agents[type] ?? _agents[AgentType.luna]!;
  }

  // Analyze query category
  QueryCategory analyzeQuery(String query) {
    final lowerQuery = query.toLowerCase();

    // Check for medical keywords first (higher priority)
    for (final keyword in _categoryKeywords[QueryCategory.medical]!) {
      if (lowerQuery.contains(keyword)) {
        return QueryCategory.medical;
      }
    }

    // Check for lifestyle keywords
    for (final keyword in _categoryKeywords[QueryCategory.lifestyle]!) {
      if (lowerQuery.contains(keyword)) {
        return QueryCategory.lifestyle;
      }
    }

    // Check for emotional keywords
    for (final keyword in _categoryKeywords[QueryCategory.emotional]!) {
      if (lowerQuery.contains(keyword)) {
        return QueryCategory.emotional;
      }
    }

    // Check for complex queries (multiple categories or unclear)
    int categoryCount = 0;
    for (final category in _categoryKeywords.values) {
      for (final keyword in category) {
        if (lowerQuery.contains(keyword)) {
          categoryCount++;
          break;
        }
      }
    }

    if (categoryCount > 1) {
      return QueryCategory.complex;
    }

    return QueryCategory.unknown;
  }

  // Route query to appropriate agent(s)
  Future<List<AIResponse>> routeQuery(String query,
      {Map<String, dynamic>? context}) async {
    final category = analyzeQuery(query);
    final responses = <AIResponse>[];

    // Show typing indicator
    _typingController.add(true);

    try {
      switch (category) {
        case QueryCategory.lifestyle:
        case QueryCategory.emotional:
          responses.add(await _getLunaResponse(query, context));
          break;

        case QueryCategory.medical:
          responses.add(await _getDrSageResponse(query, context));
          break;

        case QueryCategory.complex:
          // Get collaborative response
          responses.addAll(await _getCollaborativeResponse(query, context));
          break;

        case QueryCategory.unknown:
        default:
          // Ask for clarification
          responses.add(await _getClarificationResponse(query));
          break;
      }
    } finally {
      _typingController.add(false);
    }

    // Emit responses
    for (final response in responses) {
      _responseController.add(response);
      // Add delay between responses for natural flow
      if (responses.length > 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return responses;
  }

  // Get Luna's response
  Future<AIResponse> _getLunaResponse(
      String query, Map<String, dynamic>? context) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final agent = getAgent(AgentType.luna);

    // Mock response based on query content
    String response = _generateLunaResponse(query);

    return AIResponse(
      agentType: AgentType.luna,
      agentName: agent.name,
      message: response,
      timestamp: DateTime.now(),
      suggestions: _generateSuggestions(query, AgentType.luna),
    );
  }

  // Get Dr. Sage's response
  Future<AIResponse> _getDrSageResponse(
      String query, Map<String, dynamic>? context) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final agent = getAgent(AgentType.drSage);

    // Mock response based on query content
    String response = _generateDrSageResponse(query);

    return AIResponse(
      agentType: AgentType.drSage,
      agentName: agent.name,
      message: response,
      timestamp: DateTime.now(),
      suggestions: _generateSuggestions(query, AgentType.drSage),
    );
  }

  // Get collaborative response from both agents
  Future<List<AIResponse>> _getCollaborativeResponse(
      String query, Map<String, dynamic>? context) async {
    final responses = <AIResponse>[];

    // Get both agents' perspectives
    final lunaResponse = await _getLunaResponse(query, context);
    final drSageResponse = await _getDrSageResponse(query, context);

    responses.add(lunaResponse);
    responses.add(drSageResponse);

    return responses;
  }

  // Get clarification response
  Future<AIResponse> _getClarificationResponse(String query) async {
    final agent = getAgent(AgentType.maestro);

    return AIResponse(
      agentType: AgentType.maestro,
      agentName: agent.name,
      message:
          "I'd love to help you with that! Could you tell me a bit more about what you're looking for? Are you interested in:\n\n• Lifestyle and wellness advice (I'll connect you with Luna)\n• Medical information and hormone education (I'll connect you with Dr. Sage)\n• Or something else?",
      timestamp: DateTime.now(),
      suggestions: [
        "Lifestyle and wellness advice",
        "Medical information",
        "Both - I have a complex question",
      ],
    );
  }

  // Generate mock responses (replace with actual AI API calls)
  String _generateLunaResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('sleep')) {
      return "Sleep can be challenging during menopause! Here are some tips that might help:\n\n🌙 Create a relaxing bedtime routine\n🌙 Keep your bedroom cool and dark\n🌙 Avoid caffeine after 2 PM\n🌙 Try gentle yoga or meditation before bed\n🌙 Consider natural sleep aids like chamomile tea\n\nWould you like me to suggest a specific bedtime routine for you?";
    } else if (lowerQuery.contains('stress')) {
      return "Stress management is so important during this transition! Here are some effective strategies:\n\n🧘‍♀️ Practice deep breathing exercises\n🧘‍♀️ Try mindfulness meditation\n🧘‍♀️ Engage in regular physical activity\n🧘‍♀️ Connect with supportive friends\n🧘‍♀️ Consider journaling your feelings\n\nWhat type of stress are you experiencing most? I can provide more targeted suggestions.";
    } else if (lowerQuery.contains('diet') ||
        lowerQuery.contains('nutrition')) {
      return "Nutrition plays a key role in managing menopause symptoms! Here are some dietary tips:\n\n🥗 Include plenty of fruits and vegetables\n🥗 Add calcium-rich foods for bone health\n🥗 Include healthy fats like omega-3s\n🥗 Stay hydrated throughout the day\n🥗 Consider phytoestrogen-rich foods\n\nWould you like specific meal ideas or recipes?";
    } else {
      return "I'm here to support your wellness journey! Remember, every woman's experience is unique, and it's okay to take things one day at a time. What aspect of your lifestyle would you like to focus on today?";
    }
  }

  String _generateDrSageResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('hot flash')) {
      return "Hot flashes are one of the most common menopause symptoms, affecting up to 75% of women. They occur due to declining estrogen levels affecting your body's temperature regulation.\n\nCommon triggers include:\n• Spicy foods and caffeine\n• Alcohol and smoking\n• Stress and anxiety\n• Warm environments\n• Tight clothing\n\nTreatment options range from lifestyle changes to hormone therapy. Would you like to discuss specific treatment approaches?";
    } else if (lowerQuery.contains('hormone')) {
      return "Hormone changes during menopause are complex and affect many body systems. The main changes include:\n\n📊 Estrogen: Declines significantly, affecting many tissues\n📊 Progesterone: Also decreases, affecting menstrual cycles\n📊 Testosterone: May decrease, affecting energy and libido\n📊 FSH and LH: Increase as the body tries to stimulate ovulation\n\nThese changes can cause various symptoms. Which hormone-related concerns would you like to explore further?";
    } else if (lowerQuery.contains('hrt') ||
        lowerQuery.contains('hormone therapy')) {
      return "Hormone Replacement Therapy (HRT) can be an effective treatment for menopause symptoms, but it's important to understand the benefits and risks.\n\nBenefits:\n✅ Relieves hot flashes and night sweats\n✅ Improves vaginal dryness\n✅ May protect against osteoporosis\n✅ Can improve sleep quality\n\nRisks:\n⚠️ Slight increased risk of blood clots\n⚠️ May increase breast cancer risk (varies by type)\n⚠️ Not suitable for everyone\n\nIt's essential to discuss HRT with your healthcare provider to determine if it's right for you.";
    } else {
      return "I'm here to provide accurate medical information about menopause and women's health. What specific medical questions do you have? Remember, while I can provide information, always consult with your healthcare provider for personalized medical advice.";
    }
  }

  // Generate contextual suggestions
  List<String> _generateSuggestions(String query, AgentType agentType) {
    switch (agentType) {
      case AgentType.luna:
        return [
          "Create a wellness routine",
          "Stress management tips",
          "Sleep improvement strategies",
          "Nutrition guidance",
        ];
      case AgentType.drSage:
        return [
          "Learn about hormone changes",
          "Treatment options",
          "When to see a doctor",
          "Symptom explanations",
        ];
      case AgentType.maestro:
        return [
          "Connect with Luna",
          "Connect with Dr. Sage",
          "Ask a complex question",
        ];
    }
  }

  // Voice input processing
  Future<String> processVoiceInput(String audioData) async {
    // Simulate voice-to-text processing
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock transcription (replace with actual voice recognition)
    return "I'm experiencing hot flashes and trouble sleeping. What can I do?";
  }

  // Dispose resources
  void dispose() {
    _responseController.close();
    _typingController.close();
  }
}
