import 'package:equatable/equatable.dart';

enum MenovibeAgentType {
  maestro,
  nutritionExpert,
  lifeCoach,
  communityConnector,
}

enum MessageType {
  user,
  agent,
  system,
}

class MenovibeMessage extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MenovibeAgentType? agentType;
  final String? agentName;
  final Map<String, dynamic>? metadata;
  final List<String>? suggestions;

  const MenovibeMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.agentType,
    this.agentName,
    this.metadata,
    this.suggestions,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        timestamp,
        agentType,
        agentName,
        metadata,
        suggestions,
      ];

  MenovibeMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MenovibeAgentType? agentType,
    String? agentName,
    Map<String, dynamic>? metadata,
    List<String>? suggestions,
  }) {
    return MenovibeMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      agentType: agentType ?? this.agentType,
      agentName: agentName ?? this.agentName,
      metadata: metadata ?? this.metadata,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'agentType': agentType?.name,
      'agentName': agentName,
      'metadata': metadata,
      'suggestions': suggestions,
    };
  }

  factory MenovibeMessage.fromJson(Map<String, dynamic> json) {
    return MenovibeMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      agentType: json['agentType'] != null
          ? MenovibeAgentType.values.firstWhere(
              (e) => e.name == json['agentType'],
            )
          : null,
      agentName: json['agentName'],
      metadata: json['metadata'],
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList(),
    );
  }
}

class MenovibeAgent extends Equatable {
  final MenovibeAgentType type;
  final String name;
  final String description;
  final String avatarUrl;
  final String personality;
  final List<String> specialties;
  final String systemPrompt;

  const MenovibeAgent({
    required this.type,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.personality,
    required this.specialties,
    required this.systemPrompt,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        description,
        avatarUrl,
        personality,
        specialties,
        systemPrompt,
      ];
}

class MenovibeConversation extends Equatable {
  final String id;
  final String title;
  final List<MenovibeMessage> messages;
  final DateTime createdAt;
  final DateTime? lastModified;
  final bool isArchived;

  const MenovibeConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    this.lastModified,
    this.isArchived = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        messages,
        createdAt,
        lastModified,
        isArchived,
      ];

  MenovibeConversation copyWith({
    String? id,
    String? title,
    List<MenovibeMessage>? messages,
    DateTime? createdAt,
    DateTime? lastModified,
    bool? isArchived,
  }) {
    return MenovibeConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory MenovibeConversation.fromJson(Map<String, dynamic> json) {
    return MenovibeConversation(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => MenovibeMessage.fromJson(m))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
      isArchived: json['isArchived'] ?? false,
    );
  }

  String get preview {
    final userMessages =
        messages.where((m) => m.type == MessageType.user).toList();
    if (userMessages.isNotEmpty) {
      final lastMessage = userMessages.last.content;
      return lastMessage.length > 50
          ? '${lastMessage.substring(0, 50)}...'
          : lastMessage;
    }
    return 'New conversation';
  }

  DateTime get lastActivity {
    return lastModified ?? createdAt;
  }
}
