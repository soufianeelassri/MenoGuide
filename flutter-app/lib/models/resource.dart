import 'package:equatable/equatable.dart';

class Resource extends Equatable {
  final String id;
  final String title;
  final String description;
  final String link;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;

  const Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    this.imageUrl,
    required this.category,
    required this.createdAt,
  });

  Resource copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    String? imageUrl,
    String? category,
    DateTime? createdAt,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        link,
        imageUrl,
        category,
        createdAt,
      ];
}
