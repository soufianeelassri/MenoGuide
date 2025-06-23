import 'package:equatable/equatable.dart';
import 'symptom.dart';

enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
  unknown,
}

enum FlowIntensity {
  light,
  moderate,
  heavy,
  spotting,
}

enum CycleStatus {
  logged,
  predicted,
  estimated,
}

class CycleEntry extends Equatable {
  final String id;
  final DateTime date;
  final CyclePhase? phase;
  final FlowIntensity? flowIntensity;
  final bool isPeriod;
  final List<Symptom> symptoms;
  final String? notes;
  final Map<String, dynamic>? additionalData;

  const CycleEntry({
    required this.id,
    required this.date,
    this.phase,
    this.flowIntensity,
    required this.isPeriod,
    this.symptoms = const [],
    this.notes,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        phase,
        flowIntensity,
        isPeriod,
        symptoms,
        notes,
        additionalData,
      ];

  CycleEntry copyWith({
    String? id,
    DateTime? date,
    CyclePhase? phase,
    FlowIntensity? flowIntensity,
    bool? isPeriod,
    List<Symptom>? symptoms,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) {
    return CycleEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      phase: phase ?? this.phase,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      isPeriod: isPeriod ?? this.isPeriod,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'phase': phase?.name,
      'flowIntensity': flowIntensity?.name,
      'isPeriod': isPeriod,
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      'notes': notes,
      'additionalData': additionalData,
    };
  }

  factory CycleEntry.fromJson(Map<String, dynamic> json) {
    return CycleEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      phase: json['phase'] != null
          ? CyclePhase.values.firstWhere(
              (e) => e.name == json['phase'],
            )
          : null,
      flowIntensity: json['flowIntensity'] != null
          ? FlowIntensity.values.firstWhere(
              (e) => e.name == json['flowIntensity'],
            )
          : null,
      isPeriod: json['isPeriod'],
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((s) => Symptom.fromJson(s))
              .toList() ??
          [],
      notes: json['notes'],
      additionalData: json['additionalData'],
    );
  }
}

class CycleData extends Equatable {
  final String userId;
  final int averageCycleLength;
  final DateTime? lastPeriodStart;
  final DateTime? lastPeriodEnd;
  final MenopausePhase menopausePhase;
  final List<CycleEntry> entries;
  final Map<String, dynamic>? additionalData;

  const CycleData({
    required this.userId,
    required this.averageCycleLength,
    this.lastPeriodStart,
    this.lastPeriodEnd,
    required this.menopausePhase,
    this.entries = const [],
    this.additionalData,
  });

  @override
  List<Object?> get props => [
        userId,
        averageCycleLength,
        lastPeriodStart,
        lastPeriodEnd,
        menopausePhase,
        entries,
        additionalData,
      ];

  CycleData copyWith({
    String? userId,
    int? averageCycleLength,
    DateTime? lastPeriodStart,
    DateTime? lastPeriodEnd,
    MenopausePhase? menopausePhase,
    List<CycleEntry>? entries,
    Map<String, dynamic>? additionalData,
  }) {
    return CycleData(
      userId: userId ?? this.userId,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      lastPeriodEnd: lastPeriodEnd ?? this.lastPeriodEnd,
      menopausePhase: menopausePhase ?? this.menopausePhase,
      entries: entries ?? this.entries,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'averageCycleLength': averageCycleLength,
      'lastPeriodStart': lastPeriodStart?.toIso8601String(),
      'lastPeriodEnd': lastPeriodEnd?.toIso8601String(),
      'menopausePhase': menopausePhase.name,
      'entries': entries.map((e) => e.toJson()).toList(),
      'additionalData': additionalData,
    };
  }

  factory CycleData.fromJson(Map<String, dynamic> json) {
    return CycleData(
      userId: json['userId'],
      averageCycleLength: json['averageCycleLength'],
      lastPeriodStart: json['lastPeriodStart'] != null
          ? DateTime.parse(json['lastPeriodStart'])
          : null,
      lastPeriodEnd: json['lastPeriodEnd'] != null
          ? DateTime.parse(json['lastPeriodEnd'])
          : null,
      menopausePhase: MenopausePhase.values.firstWhere(
        (e) => e.name == json['menopausePhase'],
      ),
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => CycleEntry.fromJson(e))
              .toList() ??
          [],
      additionalData: json['additionalData'],
    );
  }

  DateTime? getNextPredictedPeriod() {
    if (lastPeriodStart == null || averageCycleLength <= 0) {
      return null;
    }
    return lastPeriodStart!.add(Duration(days: averageCycleLength));
  }

  bool get isInFertileWindow {
    if (lastPeriodStart == null || averageCycleLength <= 0) {
      return false;
    }
    final today = DateTime.now();
    final daysSincePeriod = today.difference(lastPeriodStart!).inDays;
    final ovulationDay = averageCycleLength - 14;
    return daysSincePeriod >= ovulationDay - 3 &&
        daysSincePeriod <= ovulationDay + 3;
  }
}

class CycleDay {
  final DateTime date;
  final CyclePhase? phase;
  final CycleStatus status;
  final bool isPeriodDay;
  final bool isOvulationDay;
  final bool isFertileDay;
  final int? cycleDayNumber;
  final String? mood;
  final List<Symptom> symptoms;
  final String? notes;

  const CycleDay({
    required this.date,
    this.phase,
    this.status = CycleStatus.logged,
    this.isPeriodDay = false,
    this.isOvulationDay = false,
    this.isFertileDay = false,
    this.cycleDayNumber,
    this.mood,
    this.symptoms = const [],
    this.notes,
  });

  CycleDay copyWith({
    DateTime? date,
    CyclePhase? phase,
    CycleStatus? status,
    bool? isPeriodDay,
    bool? isOvulationDay,
    bool? isFertileDay,
    int? cycleDayNumber,
    String? mood,
    List<Symptom>? symptoms,
    String? notes,
  }) {
    return CycleDay(
      date: date ?? this.date,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      isPeriodDay: isPeriodDay ?? this.isPeriodDay,
      isOvulationDay: isOvulationDay ?? this.isOvulationDay,
      isFertileDay: isFertileDay ?? this.isFertileDay,
      cycleDayNumber: cycleDayNumber ?? this.cycleDayNumber,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'phase': phase?.name,
      'status': status.name,
      'isPeriodDay': isPeriodDay,
      'isOvulationDay': isOvulationDay,
      'isFertileDay': isFertileDay,
      'cycleDayNumber': cycleDayNumber,
      'mood': mood,
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory CycleDay.fromJson(Map<String, dynamic> json) {
    return CycleDay(
      date: DateTime.parse(json['date']),
      phase: json['phase'] != null
          ? CyclePhase.values.firstWhere(
              (e) => e.name == json['phase'],
              orElse: () => CyclePhase.unknown,
            )
          : null,
      status: CycleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CycleStatus.logged,
      ),
      isPeriodDay: json['isPeriodDay'] ?? false,
      isOvulationDay: json['isOvulationDay'] ?? false,
      isFertileDay: json['isFertileDay'] ?? false,
      cycleDayNumber: json['cycleDayNumber'],
      mood: json['mood'],
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((s) => Symptom.fromJson(s))
              .toList() ??
          [],
      notes: json['notes'],
    );
  }

  @override
  List<Object?> get props => [
        date,
        phase,
        status,
        isPeriodDay,
        isOvulationDay,
        isFertileDay,
        cycleDayNumber,
        mood,
        symptoms,
        notes,
      ];
}

class Cycle {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? length;
  final int? periodLength;
  final CyclePhase? dominantPhase;
  final bool isComplete;
  final bool isPredicted;
  final List<CycleDay> days;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cycle({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.length,
    this.periodLength,
    this.dominantPhase,
    this.isComplete = false,
    this.isPredicted = false,
    this.days = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Cycle copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? length,
    int? periodLength,
    CyclePhase? dominantPhase,
    bool? isComplete,
    bool? isPredicted,
    List<CycleDay>? days,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cycle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      length: length ?? this.length,
      periodLength: periodLength ?? this.periodLength,
      dominantPhase: dominantPhase ?? this.dominantPhase,
      isComplete: isComplete ?? this.isComplete,
      isPredicted: isPredicted ?? this.isPredicted,
      days: days ?? this.days,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'length': length,
      'periodLength': periodLength,
      'dominantPhase': dominantPhase?.name,
      'isComplete': isComplete,
      'isPredicted': isPredicted,
      'days': days.map((d) => d.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Cycle.fromJson(Map<String, dynamic> json) {
    return Cycle(
      id: json['id'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      length: json['length'],
      periodLength: json['periodLength'],
      dominantPhase: json['dominantPhase'] != null
          ? CyclePhase.values.firstWhere(
              (e) => e.name == json['dominantPhase'],
              orElse: () => CyclePhase.unknown,
            )
          : null,
      isComplete: json['isComplete'] ?? false,
      isPredicted: json['isPredicted'] ?? false,
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => CycleDay.fromJson(d))
              .toList() ??
          [],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        startDate,
        endDate,
        length,
        periodLength,
        dominantPhase,
        isComplete,
        isPredicted,
        days,
        notes,
        createdAt,
        updatedAt,
      ];
}

class CyclePrediction {
  final DateTime date;
  final CyclePhase predictedPhase;
  final double confidence;
  final bool isPeriodPrediction;
  final bool isOvulationPrediction;
  final String? reasoning;

  const CyclePrediction({
    required this.date,
    required this.predictedPhase,
    required this.confidence,
    this.isPeriodPrediction = false,
    this.isOvulationPrediction = false,
    this.reasoning,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'predictedPhase': predictedPhase.name,
      'confidence': confidence,
      'isPeriodPrediction': isPeriodPrediction,
      'isOvulationPrediction': isOvulationPrediction,
      'reasoning': reasoning,
    };
  }

  factory CyclePrediction.fromJson(Map<String, dynamic> json) {
    return CyclePrediction(
      date: DateTime.parse(json['date']),
      predictedPhase: CyclePhase.values.firstWhere(
        (e) => e.name == json['predictedPhase'],
        orElse: () => CyclePhase.unknown,
      ),
      confidence: json['confidence'].toDouble(),
      isPeriodPrediction: json['isPeriodPrediction'] ?? false,
      isOvulationPrediction: json['isOvulationPrediction'] ?? false,
      reasoning: json['reasoning'],
    );
  }
}
