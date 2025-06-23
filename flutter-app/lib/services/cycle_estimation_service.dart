import 'package:intl/intl.dart';

class CycleEstimationService {
  /// Estimates cycle phases based on Average Cycle Length (ACL) and Average Period Length (APL)
  static CyclePhaseEstimation estimateCyclePhases({
    required int averageCycleLength,
    required int averagePeriodLength,
    required DateTime lastPeriodStartDate,
  }) {
    // Calculate ovulation day (ACL - 14 days from period start)
    final ovulationDay =
        lastPeriodStartDate.add(Duration(days: averageCycleLength - 14));

    // Calculate ovulatory phase window (2 days before to 1 day after ovulation)
    final ovulatoryStart = ovulationDay.subtract(const Duration(days: 2));
    final ovulatoryEnd = ovulationDay.add(const Duration(days: 1));

    // Calculate next period start
    final nextPeriodStart =
        lastPeriodStartDate.add(Duration(days: averageCycleLength));

    // Calculate menstrual phase (period days)
    final menstrualStart = lastPeriodStartDate;
    final menstrualEnd =
        lastPeriodStartDate.add(Duration(days: averagePeriodLength - 1));

    // Calculate fertile window (5 days before ovulation to 1 day after)
    final fertileStart = ovulationDay.subtract(const Duration(days: 5));
    final fertileEnd = ovulationDay.add(const Duration(days: 1));

    return CyclePhaseEstimation(
      lastPeriodStartDate: lastPeriodStartDate,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      ovulationDay: ovulationDay,
      nextPeriodStart: nextPeriodStart,
      menstrualPhase: DateRange(start: menstrualStart, end: menstrualEnd),
      ovulatoryPhase: DateRange(start: ovulatoryStart, end: ovulatoryEnd),
      fertileWindow: DateRange(start: fertileStart, end: fertileEnd),
      estimatedByAI: false,
    );
  }

  /// Calculates cycle day for a given date
  static int getCycleDay(
      DateTime date, DateTime lastPeriodStart, int averageCycleLength) {
    final daysSinceLastPeriod = date.difference(lastPeriodStart).inDays;

    if (daysSinceLastPeriod < 0) {
      // Date is before last period start
      return averageCycleLength + daysSinceLastPeriod;
    } else if (daysSinceLastPeriod >= averageCycleLength) {
      // Date is in next cycle
      return (daysSinceLastPeriod % averageCycleLength) + 1;
    } else {
      // Date is in current cycle
      return daysSinceLastPeriod + 1;
    }
  }

  /// Checks if a date falls within a specific phase
  static bool isInPhase(DateTime date, DateRange phase) {
    return date.isAfter(phase.start.subtract(const Duration(days: 1))) &&
        date.isBefore(phase.end.add(const Duration(days: 1)));
  }

  /// Gets the current cycle phase for a given date
  static CyclePhase getCurrentPhase(
      DateTime date, CyclePhaseEstimation estimation) {
    if (isInPhase(date, estimation.menstrualPhase)) {
      return CyclePhase.menstrual;
    } else if (isInPhase(date, estimation.ovulatoryPhase)) {
      return CyclePhase.ovulatory;
    } else if (isInPhase(date, estimation.fertileWindow)) {
      return CyclePhase.fertile;
    } else {
      return CyclePhase.follicular;
    }
  }

  /// Formats date for display
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  /// Gets phase description
  static String getPhaseDescription(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulatory:
        return 'Ovulatory Phase';
      case CyclePhase.fertile:
        return 'Fertile Window';
    }
  }

  /// Gets phase icon
  static String getPhaseIcon(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return '🌸';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulatory:
        return '🌼';
      case CyclePhase.fertile:
        return '🌺';
    }
  }
}

class CyclePhaseEstimation {
  final DateTime lastPeriodStartDate;
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime ovulationDay;
  final DateTime nextPeriodStart;
  final DateRange menstrualPhase;
  final DateRange ovulatoryPhase;
  final DateRange fertileWindow;
  final bool estimatedByAI;

  const CyclePhaseEstimation({
    required this.lastPeriodStartDate,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.ovulationDay,
    required this.nextPeriodStart,
    required this.menstrualPhase,
    required this.ovulatoryPhase,
    required this.fertileWindow,
    required this.estimatedByAI,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }
}

enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  fertile,
}
