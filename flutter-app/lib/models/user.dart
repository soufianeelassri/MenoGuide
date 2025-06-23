import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MenopausePhase { pre, peri, post }

enum SymptomIntensity { light, moderate, severe }

enum FlowIntensity { light, moderate, heavy }

enum FlowColor { bright, dark, brown, pink }

enum OnboardingStep {
  welcome,
  goals,
  cycleInput,
  symptoms,
  accountSetup,
  completed,
}

enum UserGoal {
  symptomTracking,
  cycleUnderstanding,
  lifestyleImprovement,
  medicalSupport,
  communitySupport,
  stressManagement,
}

enum MoodType { happy, calm, sad, anxious, irritable, confident }

class MenstrualCycle {
  final bool isRegular;
  final FlowIntensity flowIntensity;
  final FlowColor flowColor;
  final String consistency;
  final bool hasBackPain;
  final DateTime? lastPeriod;
  final int? cycleLength;

  const MenstrualCycle({
    this.isRegular = true,
    this.flowIntensity = FlowIntensity.moderate,
    this.flowColor = FlowColor.bright,
    this.consistency = 'Normal',
    this.hasBackPain = false,
    this.lastPeriod,
    this.cycleLength,
  });

  MenstrualCycle copyWith({
    bool? isRegular,
    FlowIntensity? flowIntensity,
    FlowColor? flowColor,
    String? consistency,
    bool? hasBackPain,
    DateTime? lastPeriod,
    int? cycleLength,
  }) {
    return MenstrualCycle(
      isRegular: isRegular ?? this.isRegular,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      flowColor: flowColor ?? this.flowColor,
      consistency: consistency ?? this.consistency,
      hasBackPain: hasBackPain ?? this.hasBackPain,
      lastPeriod: lastPeriod ?? this.lastPeriod,
      cycleLength: cycleLength ?? this.cycleLength,
    );
  }
}

class DailySymptoms {
  final SymptomIntensity hotFlashes;
  final SymptomIntensity nightSweats;
  final SymptomIntensity anxiety;
  final DateTime date;

  const DailySymptoms({
    this.hotFlashes = SymptomIntensity.light,
    this.nightSweats = SymptomIntensity.light,
    this.anxiety = SymptomIntensity.light,
    required this.date,
  });

  DailySymptoms copyWith({
    SymptomIntensity? hotFlashes,
    SymptomIntensity? nightSweats,
    SymptomIntensity? anxiety,
    DateTime? date,
  }) {
    return DailySymptoms(
      hotFlashes: hotFlashes ?? this.hotFlashes,
      nightSweats: nightSweats ?? this.nightSweats,
      anxiety: anxiety ?? this.anxiety,
      date: date ?? this.date,
    );
  }
}

class CycleDay {
  final DateTime date;
  final int? cycleDay;
  final FlowIntensity? flow;
  final MoodType? mood;
  final List<String> symptoms;
  final String? notes;

  const CycleDay({
    required this.date,
    this.cycleDay,
    this.flow,
    this.mood,
    this.symptoms = const [],
    this.notes,
  });

  factory CycleDay.fromMap(Map<String, dynamic> map) {
    // Handle both Timestamp and String date formats
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else {
        throw FormatException('Invalid date format: $dateValue');
      }
    }

    return CycleDay(
      date: parseDate(map['date']),
      cycleDay: map['cycleDay'],
      flow: map['flow'] != null
          ? FlowIntensity.values.firstWhere(
              (e) => e.toString().split('.').last == map['flow'],
              orElse: () => FlowIntensity.light,
            )
          : null,
      mood: map['mood'] != null
          ? MoodType.values.firstWhere(
              (e) => e.toString().split('.').last == map['mood'],
              orElse: () => MoodType.calm,
            )
          : null,
      symptoms: List<String>.from(map['symptoms'] ?? []),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'cycleDay': cycleDay,
      'flow': flow?.toString().split('.').last,
      'mood': mood?.toString().split('.').last,
      'symptoms': symptoms,
      'notes': notes,
    };
  }

  CycleDay copyWith({
    DateTime? date,
    int? cycleDay,
    FlowIntensity? flow,
    MoodType? mood,
    List<String>? symptoms,
    String? notes,
  }) {
    return CycleDay(
      date: date ?? this.date,
      cycleDay: cycleDay ?? this.cycleDay,
      flow: flow ?? this.flow,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [date, cycleDay, flow, mood, symptoms, notes];
}

class User extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final MenopausePhase menopausePhase;
  final List<String> symptoms;
  final List<String> concerns;
  final DateTime lastPeriodStartDate;
  final int averageCycleLength;
  final int averagePeriodLength;
  final bool estimatedByAI;
  final int completedCycles;
  final Map<String, CycleDay> cycleData;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> onboarding;
  final Map<String, dynamic> metadata;

  const User({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.dateOfBirth,
    required this.menopausePhase,
    required this.symptoms,
    required this.concerns,
    required this.lastPeriodStartDate,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    this.estimatedByAI = false,
    this.completedCycles = 0,
    this.cycleData = const {},
    this.preferences = const {},
    this.onboarding = const {},
    this.metadata = const {},
  });

  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    // Helper function to parse dates from Firestore
    DateTime? parseFirestoreDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          print('Warning: Invalid date string format: $dateValue');
          return null;
        }
      } else {
        print('Warning: Invalid date format: $dateValue');
        return null;
      }
    }

    // Helper function to safely get nested map values
    Map<String, dynamic> safeGetMap(Map<String, dynamic>? data, String key) {
      if (data == null) return {};
      final value = data[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      return {};
    }

    // Helper function to safely get list values
    List<String> safeGetList(dynamic data, String key) {
      if (data == null) return [];
      final value = data[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Helper function to safely get string values
    String safeGetString(Map<String, dynamic>? data, String key,
        {String defaultValue = ''}) {
      if (data == null) return defaultValue;
      final value = data[key];
      return value?.toString() ?? defaultValue;
    }

    // Helper function to safely get int values
    int safeGetInt(Map<String, dynamic>? data, String key,
        {int defaultValue = 0}) {
      if (data == null) return defaultValue;
      final value = data[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return defaultValue;
        }
      }
      return defaultValue;
    }

    // Helper function to safely get bool values
    bool safeGetBool(Map<String, dynamic>? data, String key,
        {bool defaultValue = false}) {
      if (data == null) return defaultValue;
      final value = data[key];
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      return defaultValue;
    }

    // Convertir les données de cycle avec gestion d'erreurs robuste
    final cycleDataMap = <String, CycleDay>{};
    try {
      if (data['cycleData'] != null) {
        final cycleDataRaw = data['cycleData'] as Map<String, dynamic>;
        for (final entry in cycleDataRaw.entries) {
          try {
            cycleDataMap[entry.key] = CycleDay.fromMap(entry.value);
          } catch (e) {
            print('Error parsing cycle data for ${entry.key}: $e');
            // Skip this entry and continue
          }
        }
      }
    } catch (e) {
      print('Error parsing cycleData: $e');
    }

    // Parse lastPeriodStartDate with robust fallback
    DateTime lastPeriodDate;
    try {
      final cycleInfo = safeGetMap(data, 'cycleInfo');
      final dateValue = cycleInfo['lastPeriodStartDate'];
      lastPeriodDate = parseFirestoreDate(dateValue) ??
          DateTime.now().subtract(Duration(days: 28));
    } catch (e) {
      print('Error parsing lastPeriodStartDate: $e');
      lastPeriodDate = DateTime.now().subtract(Duration(days: 28));
    }

    // Parse personal info with safe defaults
    final personalInfo = safeGetMap(data, 'personalInfo');
    final menopauseInfo = safeGetMap(data, 'menopauseInfo');
    final cycleInfo = safeGetMap(data, 'cycleInfo');

    return User(
      uid: uid,
      name: safeGetString(personalInfo, 'name', defaultValue: 'Utilisateur'),
      email: safeGetString(personalInfo, 'email', defaultValue: ''),
      profileImageUrl: personalInfo['profileImageUrl']?.toString(),
      dateOfBirth: parseFirestoreDate(personalInfo['dateOfBirth']),
      menopausePhase: _parseMenopausePhase(
          safeGetString(menopauseInfo, 'phase', defaultValue: 'peri')),
      symptoms: safeGetList(data, 'symptoms'),
      concerns: safeGetList(data, 'concerns'),
      lastPeriodStartDate: lastPeriodDate,
      averageCycleLength:
          safeGetInt(cycleInfo, 'averageCycleLength', defaultValue: 28),
      averagePeriodLength:
          safeGetInt(cycleInfo, 'averagePeriodLength', defaultValue: 5),
      estimatedByAI: safeGetBool(cycleInfo, 'estimatedByAI'),
      completedCycles: safeGetInt(cycleInfo, 'completedCycles'),
      cycleData: cycleDataMap,
      preferences: safeGetMap(data, 'preferences'),
      onboarding: safeGetMap(data, 'onboarding'),
      metadata: safeGetMap(data, 'metadata'),
    );
  }

  // Helper method to parse menopause phase with fallback
  static MenopausePhase _parseMenopausePhase(String phase) {
    try {
      return MenopausePhase.values.firstWhere(
        (e) => e.toString().split('.').last == phase,
        orElse: () => MenopausePhase.peri,
      );
    } catch (e) {
      print('Error parsing menopause phase: $phase, using default: peri');
      return MenopausePhase.peri;
    }
  }

  Map<String, dynamic> toFirestore() {
    // Convertir les données de cycle
    final cycleDataMap = <String, dynamic>{};
    for (final entry in cycleData.entries) {
      cycleDataMap[entry.key] = entry.value.toMap();
    }

    return {
      'personalInfo': {
        'name': name,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      },
      'menopauseInfo': {
        'phase': menopausePhase.toString().split('.').last,
      },
      'cycleInfo': {
        'lastPeriodStartDate': lastPeriodStartDate.toIso8601String(),
        'averageCycleLength': averageCycleLength,
        'averagePeriodLength': averagePeriodLength,
        'estimatedByAI': estimatedByAI,
        'completedCycles': completedCycles,
      },
      'symptoms': symptoms,
      'concerns': concerns,
      'cycleData': cycleDataMap,
      'preferences': preferences,
      'onboarding': onboarding,
      'metadata': metadata,
    };
  }

  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    MenopausePhase? menopausePhase,
    List<String>? symptoms,
    List<String>? concerns,
    DateTime? lastPeriodStartDate,
    int? averageCycleLength,
    int? averagePeriodLength,
    bool? estimatedByAI,
    int? completedCycles,
    Map<String, CycleDay>? cycleData,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? onboarding,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      menopausePhase: menopausePhase ?? this.menopausePhase,
      symptoms: symptoms ?? this.symptoms,
      concerns: concerns ?? this.concerns,
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      estimatedByAI: estimatedByAI ?? this.estimatedByAI,
      completedCycles: completedCycles ?? this.completedCycles,
      cycleData: cycleData ?? this.cycleData,
      preferences: preferences ?? this.preferences,
      onboarding: onboarding ?? this.onboarding,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        profileImageUrl,
        dateOfBirth,
        menopausePhase,
        symptoms,
        concerns,
        lastPeriodStartDate,
        averageCycleLength,
        averagePeriodLength,
        estimatedByAI,
        completedCycles,
        cycleData,
        preferences,
        onboarding,
        metadata,
      ];
}
