import 'package:equatable/equatable.dart';

enum SymptomType {
  hotFlash,
  nightSweat,
  moodSwing,
  fatigue,
  sleepIssue,
  weightGain,
  libidoChange,
  anxiety,
  depression,
  brainFog,
  jointPain,
  vaginalDryness,
  irregularPeriod,
  heavyBleeding,
  breastTenderness,
  bloating,
  headache,
  heartPalpitation,
  drySkin,
  hairLoss,
}

enum SymptomSeverity {
  none,
  mild,
  moderate,
  severe,
}

enum MenopausePhase {
  preMenopause,
  periMenopause,
  menopause,
  postMenopause,
}

class Symptom extends Equatable {
  final String id;
  final SymptomType type;
  final SymptomSeverity severity;
  final DateTime date;
  final String? notes;
  final Map<String, dynamic>? additionalData;

  const Symptom({
    required this.id,
    required this.type,
    required this.severity,
    required this.date,
    this.notes,
    this.additionalData,
  });

  @override
  List<Object?> get props => [id, type, severity, date, notes, additionalData];

  Symptom copyWith({
    String? id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? date,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) {
    return Symptom(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'date': date.toIso8601String(),
      'notes': notes,
      'additionalData': additionalData,
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      type: SymptomType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      severity: SymptomSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
      ),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      additionalData: json['additionalData'],
    );
  }

  static String getSymptomName(SymptomType type) {
    switch (type) {
      case SymptomType.hotFlash:
        return 'Hot Flashes';
      case SymptomType.nightSweat:
        return 'Night Sweats';
      case SymptomType.moodSwing:
        return 'Mood Swings';
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.sleepIssue:
        return 'Sleep Issues';
      case SymptomType.weightGain:
        return 'Weight Gain';
      case SymptomType.libidoChange:
        return 'Libido Changes';
      case SymptomType.anxiety:
        return 'Anxiety';
      case SymptomType.depression:
        return 'Depression';
      case SymptomType.brainFog:
        return 'Brain Fog';
      case SymptomType.jointPain:
        return 'Joint Pain';
      case SymptomType.vaginalDryness:
        return 'Vaginal Dryness';
      case SymptomType.irregularPeriod:
        return 'Irregular Periods';
      case SymptomType.heavyBleeding:
        return 'Heavy Bleeding';
      case SymptomType.breastTenderness:
        return 'Breast Tenderness';
      case SymptomType.bloating:
        return 'Bloating';
      case SymptomType.headache:
        return 'Headaches';
      case SymptomType.heartPalpitation:
        return 'Heart Palpitations';
      case SymptomType.drySkin:
        return 'Dry Skin';
      case SymptomType.hairLoss:
        return 'Hair Loss';
    }
  }

  static String getSymptomDescription(SymptomType type) {
    switch (type) {
      case SymptomType.hotFlash:
        return 'Sudden feeling of warmth, often with sweating';
      case SymptomType.nightSweat:
        return 'Excessive sweating during sleep';
      case SymptomType.moodSwing:
        return 'Rapid changes in emotional state';
      case SymptomType.fatigue:
        return 'Persistent tiredness and lack of energy';
      case SymptomType.sleepIssue:
        return 'Difficulty falling or staying asleep';
      case SymptomType.weightGain:
        return 'Unexpected weight gain, especially around waist';
      case SymptomType.libidoChange:
        return 'Changes in sexual desire or function';
      case SymptomType.anxiety:
        return 'Feelings of worry, nervousness, or unease';
      case SymptomType.depression:
        return 'Persistent feelings of sadness or hopelessness';
      case SymptomType.brainFog:
        return 'Difficulty concentrating or remembering things';
      case SymptomType.jointPain:
        return 'Aches and pains in joints';
      case SymptomType.vaginalDryness:
        return 'Dryness and discomfort in vaginal area';
      case SymptomType.irregularPeriod:
        return 'Changes in menstrual cycle timing';
      case SymptomType.heavyBleeding:
        return 'Unusually heavy menstrual flow';
      case SymptomType.breastTenderness:
        return 'Soreness or sensitivity in breasts';
      case SymptomType.bloating:
        return 'Feeling of fullness or swelling in abdomen';
      case SymptomType.headache:
        return 'Pain in head or neck area';
      case SymptomType.heartPalpitation:
        return 'Rapid or irregular heartbeat';
      case SymptomType.drySkin:
        return 'Skin that feels rough or itchy';
      case SymptomType.hairLoss:
        return 'Thinning or loss of hair';
    }
  }
}
