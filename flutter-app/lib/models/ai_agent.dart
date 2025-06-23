import 'package:equatable/equatable.dart';

enum AgentType {
  wellnessCoach,
  hormoneAssistant,
  nutritionist,
  therapist,
  fitnessTrainer,
}

enum MessageType {
  user,
  agent,
  system,
}

class AgentMessage extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final AgentType? agentType;
  final Map<String, dynamic>? metadata;
  final List<String>? suggestions;
  final String? context;

  const AgentMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.agentType,
    this.metadata,
    this.suggestions,
    this.context,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        timestamp,
        agentType,
        metadata,
        suggestions,
        context,
      ];

  AgentMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    AgentType? agentType,
    Map<String, dynamic>? metadata,
    List<String>? suggestions,
    String? context,
  }) {
    return AgentMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      agentType: agentType ?? this.agentType,
      metadata: metadata ?? this.metadata,
      suggestions: suggestions ?? this.suggestions,
      context: context ?? this.context,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'agentType': agentType?.name,
      'metadata': metadata,
      'suggestions': suggestions,
      'context': context,
    };
  }

  factory AgentMessage.fromJson(Map<String, dynamic> json) {
    return AgentMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      agentType: json['agentType'] != null
          ? AgentType.values.firstWhere(
              (e) => e.name == json['agentType'],
            )
          : null,
      metadata: json['metadata'],
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList(),
      context: json['context'],
    );
  }
}

class AgentSession extends Equatable {
  final String id;
  final String userId;
  final AgentType agentType;
  final List<AgentMessage> messages;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic>? sessionData;

  const AgentSession({
    required this.id,
    required this.userId,
    required this.agentType,
    this.messages = const [],
    required this.startTime,
    this.endTime,
    this.sessionData,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        agentType,
        messages,
        startTime,
        endTime,
        sessionData,
      ];

  AgentSession copyWith({
    String? id,
    String? userId,
    AgentType? agentType,
    List<AgentMessage>? messages,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? sessionData,
  }) {
    return AgentSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      agentType: agentType ?? this.agentType,
      messages: messages ?? this.messages,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sessionData: sessionData ?? this.sessionData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'agentType': agentType.name,
      'messages': messages.map((m) => m.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'sessionData': sessionData,
    };
  }

  factory AgentSession.fromJson(Map<String, dynamic> json) {
    return AgentSession(
      id: json['id'],
      userId: json['userId'],
      agentType: AgentType.values.firstWhere(
        (e) => e.name == json['agentType'],
      ),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => AgentMessage.fromJson(m))
              .toList() ??
          [],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      sessionData: json['sessionData'],
    );
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  List<AgentMessage> get userMessages {
    return messages.where((m) => m.type == MessageType.user).toList();
  }

  List<AgentMessage> get agentMessages {
    return messages.where((m) => m.type == MessageType.agent).toList();
  }
}

class AgentPersonality extends Equatable {
  final AgentType type;
  final String name;
  final String description;
  final String avatar;
  final List<String> specialties;
  final Map<String, String> responses;

  const AgentPersonality({
    required this.type,
    required this.name,
    required this.description,
    required this.avatar,
    required this.specialties,
    required this.responses,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        description,
        avatar,
        specialties,
        responses,
      ];

  static AgentPersonality getWellnessCoach() {
    return const AgentPersonality(
      type: AgentType.wellnessCoach,
      name: 'Luna',
      description:
          'Your compassionate wellness coach, here to support your menopause journey with personalized guidance and emotional support.',
      avatar: 'assets/avatars/luna.png',
      specialties: [
        'Emotional Support',
        'Lifestyle Guidance',
        'Stress Management',
        'Mindfulness Practices',
        'Wellness Planning',
      ],
      responses: {
        'greeting':
            'Hello! I\'m Luna, your wellness coach. How are you feeling today? I\'m here to support you on your menopause journey.',
        'hot_flash':
            'Hot flashes can be challenging, but there are many strategies to help manage them. Let\'s explore what might work best for you.',
        'mood_swing':
            'Mood swings are very common during menopause due to hormonal changes. Remember, your feelings are valid and temporary.',
        'sleep_issue':
            'Sleep disturbances are common during menopause. Let\'s work on creating a relaxing bedtime routine together.',
      },
    );
  }

  static AgentPersonality getHormoneAssistant() {
    return const AgentPersonality(
      type: AgentType.hormoneAssistant,
      name: 'Dr. Sage',
      description:
          'Your knowledgeable hormone health assistant, providing evidence-based information about menopause and hormonal changes.',
      avatar: 'assets/avatars/sage.png',
      specialties: [
        'Hormone Education',
        'Symptom Analysis',
        'Medical Information',
        'Treatment Options',
        'Research Updates',
      ],
      responses: {
        'greeting':
            'Hi! I\'m Dr. Sage, your hormone health assistant. I\'m here to help you understand what\'s happening in your body and provide evidence-based guidance.',
        'hot_flash':
            'Hot flashes occur due to declining estrogen levels affecting your hypothalamus. They typically last 1-5 minutes and can be triggered by stress, caffeine, or spicy foods.',
        'mood_swing':
            'Mood swings during menopause are caused by fluctuating hormone levels, particularly estrogen and progesterone. These changes affect serotonin and other neurotransmitters.',
        'sleep_issue':
            'Sleep problems in menopause are often related to night sweats, hormonal changes, and increased stress. Estrogen helps regulate sleep cycles.',
      },
    );
  }
}
