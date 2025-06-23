import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType {
  webinar,
  workshop,
  conference,
  support_group,
  meditation,
  exercise,
  nutrition,
  medical,
  education,
  bien_etre,
}

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final String category;
  final DateTime date;
  final int duration;
  final int maxAttendees;
  final int currentAttendees;
  final EventHost host;
  final List<String> tags;
  final String? imageUrl;
  final EventStatus status;
  final bool isFree;
  final double? price;
  final String? currency;
  final String? meetingLink;
  final String? recordingUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.date,
    required this.duration,
    required this.maxAttendees,
    required this.currentAttendees,
    required this.host,
    required this.tags,
    this.imageUrl,
    required this.status,
    required this.isFree,
    this.price,
    this.currency,
    this.meetingLink,
    this.recordingUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPast => date.isBefore(DateTime.now());
  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isFull => currentAttendees >= maxAttendees;
  double get attendancePercentage => (currentAttendees / maxAttendees) * 100;

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Gérer les dates qui peuvent être des Timestamps ou des strings ISO
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else {
        return DateTime.now();
      }
    }

    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: EventType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => EventType.webinar,
      ),
      category: data['category'] ?? '',
      date: parseDate(data['date']),
      duration: data['duration'] ?? 60,
      maxAttendees: data['maxAttendees'] ?? 100,
      currentAttendees: data['currentAttendees'] ?? 0,
      host: EventHost.fromMap(data['host'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'],
      status: EventStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => EventStatus.upcoming,
      ),
      isFree: data['isFree'] ?? true,
      price: data['price']?.toDouble(),
      currency: data['currency'],
      meetingLink: data['meetingLink'],
      recordingUrl: data['recordingUrl'],
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'category': category,
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'host': host.toMap(),
      'tags': tags,
      'imageUrl': imageUrl,
      'status': status.name,
      'isFree': isFree,
      'price': price,
      'currency': currency,
      'meetingLink': meetingLink,
      'recordingUrl': recordingUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    String? category,
    DateTime? date,
    int? duration,
    int? maxAttendees,
    int? currentAttendees,
    EventHost? host,
    List<String>? tags,
    String? imageUrl,
    EventStatus? status,
    bool? isFree,
    double? price,
    String? currency,
    String? meetingLink,
    String? recordingUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      host: host ?? this.host,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isFree: isFree ?? this.isFree,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      meetingLink: meetingLink ?? this.meetingLink,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        date,
        duration,
        maxAttendees,
        currentAttendees,
        host,
        tags,
        imageUrl,
        status,
        isFree,
        price,
        currency,
        meetingLink,
        recordingUrl,
        createdAt,
        updatedAt,
      ];
}

class EventHost extends Equatable {
  final String name;
  final String title;
  final String? avatar;

  const EventHost({
    required this.name,
    required this.title,
    this.avatar,
  });

  factory EventHost.fromMap(Map<String, dynamic> map) {
    return EventHost(
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      avatar: map['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'avatar': avatar,
    };
  }

  @override
  List<Object?> get props => [name, title, avatar];
}
