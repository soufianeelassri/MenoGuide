import 'package:equatable/equatable.dart';
import 'agent.dart';

enum MessageType { text, image, audio, resource }

class Message extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final Agent? sender;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final String? audioUrl;

  const Message({
    required this.id,
    required this.content,
    required this.type,
    this.sender,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.audioUrl,
  });

  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    Agent? sender,
    bool? isUser,
    DateTime? timestamp,
    String? imageUrl,
    String? audioUrl,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'sender': sender?.toJson(),
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      sender: json['sender'] != null ? Agent.fromJson(json['sender']) : null,
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        sender,
        isUser,
        timestamp,
        imageUrl,
        audioUrl,
      ];
}
