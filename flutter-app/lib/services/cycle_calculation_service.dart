import 'package:intl/intl.dart';
import '../models/user.dart';

/// Service pour calculer les phases du cycle menstruel et la fenêtre fertile
class CycleCalculationService {
  /// Calcule le jour du cycle pour une date donnée
  static int calculateCycleDay(
      DateTime date, DateTime lastPeriodStart, int averageCycleLength) {
    final daysSinceLastPeriod = date.difference(lastPeriodStart).inDays;
    return (daysSinceLastPeriod % averageCycleLength) + 1;
  }

  /// Détermine si une date est dans la fenêtre fertile (jours 12-16 du cycle)
  static bool isFertileWindow(
      DateTime date, DateTime lastPeriodStart, int averageCycleLength) {
    final cycleDay =
        calculateCycleDay(date, lastPeriodStart, averageCycleLength);
    return cycleDay >= 12 && cycleDay <= 16;
  }

  /// Calcule la date de début du cycle actuel
  static DateTime getCurrentCycleStart(
      DateTime lastPeriodStart, int averageCycleLength) {
    final now = DateTime.now();
    final daysSinceLastPeriod = now.difference(lastPeriodStart).inDays;
    final cyclesSinceLastPeriod = daysSinceLastPeriod ~/ averageCycleLength;
    return lastPeriodStart
        .add(Duration(days: cyclesSinceLastPeriod * averageCycleLength));
  }

  /// Calcule la date de fin du cycle actuel
  static DateTime getCurrentCycleEnd(
      DateTime lastPeriodStart, int averageCycleLength) {
    final cycleStart =
        getCurrentCycleStart(lastPeriodStart, averageCycleLength);
    return cycleStart.add(Duration(days: averageCycleLength - 1));
  }

  /// Détermine si une date est dans le passé, présent ou futur
  static CycleDateType getDateType(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate.isBefore(today)) {
      return CycleDateType.past;
    } else if (checkDate.isAtSameMomentAs(today)) {
      return CycleDateType.today;
    } else {
      return CycleDateType.future;
    }
  }

  /// Calcule les dates de cycle pour un mois donné
  static Map<DateTime, CycleDayInfo> calculateMonthCycleData(
    DateTime month,
    DateTime lastPeriodStart,
    int averageCycleLength,
    int averagePeriodLength,
    Map<String, CycleDay> existingCycleData,
  ) {
    final Map<DateTime, CycleDayInfo> monthData = {};

    // Obtenir le premier et dernier jour du mois
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Calculer la date de début du cycle actuel
    final currentCycleStart =
        getCurrentCycleStart(lastPeriodStart, averageCycleLength);

    // Parcourir tous les jours du mois
    for (DateTime date = firstDayOfMonth;
        date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final cycleDay =
          calculateCycleDay(date, lastPeriodStart, averageCycleLength);
      final isFertile =
          isFertileWindow(date, lastPeriodStart, averageCycleLength);
      final dateType = getDateType(date);

      // Vérifier si c'est un jour de règles (premiers jours du cycle)
      final isPeriodDay = cycleDay <= averagePeriodLength;

      // Récupérer les données existantes si disponibles
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final existingData = existingCycleData[dateKey];

      monthData[date] = CycleDayInfo(
        date: date,
        cycleDay: cycleDay,
        isPeriodDay: isPeriodDay,
        isFertileWindow: isFertile,
        dateType: dateType,
        hasRecordedData: existingData != null,
        recordedFlow: existingData?.flow,
        recordedMood: existingData?.mood,
        recordedSymptoms: existingData?.symptoms ?? [],
        notes: existingData?.notes,
      );
    }

    return monthData;
  }

  /// Calcule les statistiques du cycle pour un mois donné
  static CycleMonthStats calculateMonthStats(
    Map<DateTime, CycleDayInfo> monthData,
  ) {
    int totalDays = 0;
    int periodDays = 0;
    int fertileDays = 0;
    int recordedDays = 0;
    int moodDays = 0;

    for (final dayInfo in monthData.values) {
      totalDays++;
      if (dayInfo.isPeriodDay) periodDays++;
      if (dayInfo.isFertileWindow) fertileDays++;
      if (dayInfo.hasRecordedData) recordedDays++;
      if (dayInfo.recordedMood != null) moodDays++;
    }

    return CycleMonthStats(
      totalDays: totalDays,
      periodDays: periodDays,
      fertileDays: fertileDays,
      recordedDays: recordedDays,
      moodDays: moodDays,
    );
  }
}

/// Types de dates dans le cycle
enum CycleDateType { past, today, future }

/// Informations détaillées pour un jour du cycle
class CycleDayInfo {
  final DateTime date;
  final int cycleDay;
  final bool isPeriodDay;
  final bool isFertileWindow;
  final CycleDateType dateType;
  final bool hasRecordedData;
  final FlowIntensity? recordedFlow;
  final MoodType? recordedMood;
  final List<String> recordedSymptoms;
  final String? notes;

  const CycleDayInfo({
    required this.date,
    required this.cycleDay,
    required this.isPeriodDay,
    required this.isFertileWindow,
    required this.dateType,
    required this.hasRecordedData,
    this.recordedFlow,
    this.recordedMood,
    this.recordedSymptoms = const [],
    this.notes,
  });
}

/// Statistiques pour un mois de cycle
class CycleMonthStats {
  final int totalDays;
  final int periodDays;
  final int fertileDays;
  final int recordedDays;
  final int moodDays;

  const CycleMonthStats({
    required this.totalDays,
    required this.periodDays,
    required this.fertileDays,
    required this.recordedDays,
    required this.moodDays,
  });

  double get recordingRate => totalDays > 0 ? recordedDays / totalDays : 0.0;
  double get moodTrackingRate => totalDays > 0 ? moodDays / totalDays : 0.0;
}
