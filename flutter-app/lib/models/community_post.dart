import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final bool isAnonymous;
  final String content;
  final String category;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final List<String> tags;
  final List<Comment> commentList;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.isAnonymous = false,
    required this.content,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    required this.timestamp,
    this.tags = const [],
    this.commentList = const [],
  });

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? userName,
    bool? isAnonymous,
    String? content,
    String? category,
    int? likes,
    int? comments,
    DateTime? timestamp,
    List<String>? tags,
    List<Comment>? commentList,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      content: content ?? this.content,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
      tags: tags ?? this.tags,
      commentList: commentList ?? this.commentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'isAnonymous': isAnonymous,
      'content': content,
      'category': category,
      'likes': likes,
      'comments': comments,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
      'commentList': commentList.map((c) => c.toJson()).toList(),
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      isAnonymous: json['isAnonymous'] ?? false,
      content: json['content'],
      category: json['category'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      tags: List<String>.from(json['tags'] ?? []),
      commentList: (json['commentList'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        isAnonymous,
        content,
        category,
        likes,
        comments,
        timestamp,
        tags,
        commentList,
      ];
}

class Comment extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final bool isAnonymous;
  final String content;
  final DateTime timestamp;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.isAnonymous = false,
    required this.content,
    required this.timestamp,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    bool? isAnonymous,
    String? content,
    DateTime? timestamp,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'isAnonymous': isAnonymous,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      isAnonymous: json['isAnonymous'] ?? false,
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        isAnonymous,
        content,
        timestamp,
      ];
}

class Reaction extends Equatable {
  final String id;
  final String userId;
  final ReactionType type;
  final DateTime createdAt;

  const Reaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  Reaction copyWith({
    String? id,
    String? userId,
    ReactionType? type,
    DateTime? createdAt,
  }) {
    return Reaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, type, createdAt];
}

enum ReactionType { like, support, heart }
