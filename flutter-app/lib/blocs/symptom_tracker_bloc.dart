import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/cycle_calculation_service.dart';

// Events
abstract class SymptomTrackerEvent extends Equatable {
  const SymptomTrackerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCycleData extends SymptomTrackerEvent {
  final String uid;
  final DateTime startDate;
  final DateTime endDate;

  const LoadCycleData({
    required this.uid,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [uid, startDate, endDate];
}

class SaveCycleDay extends SymptomTrackerEvent {
  final String uid;
  final DateTime date;
  final FlowIntensity? flow;
  final MoodType? mood;
  final List<String> symptoms;
  final String? notes;

  const SaveCycleDay({
    required this.uid,
    required this.date,
    this.flow,
    this.mood,
    this.symptoms = const [],
    this.notes,
  });

  @override
  List<Object?> get props => [uid, date, flow, mood, symptoms, notes];
}

class UpdateSelectedDate extends SymptomTrackerEvent {
  final DateTime date;

  const UpdateSelectedDate(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeMonth extends SymptomTrackerEvent {
  final DateTime newMonth;

  const ChangeMonth(this.newMonth);

  @override
  List<Object?> get props => [newMonth];
}

// States
abstract class SymptomTrackerState extends Equatable {
  const SymptomTrackerState();

  @override
  List<Object?> get props => [];
}

class SymptomTrackerInitial extends SymptomTrackerState {}

class SymptomTrackerLoading extends SymptomTrackerState {}

class SymptomTrackerLoaded extends SymptomTrackerState {
  final User user;
  final DateTime currentMonth;
  final Map<DateTime, CycleDayInfo> monthData;
  final DateTime? selectedDate;
  final CycleDayInfo? selectedDayInfo;
  final CycleMonthStats monthStats;
  final bool isSaving;

  const SymptomTrackerLoaded({
    required this.user,
    required this.currentMonth,
    required this.monthData,
    this.selectedDate,
    this.selectedDayInfo,
    required this.monthStats,
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [
        user,
        currentMonth,
        monthData,
        selectedDate,
        selectedDayInfo,
        monthStats,
        isSaving,
      ];

  SymptomTrackerLoaded copyWith({
    User? user,
    DateTime? currentMonth,
    Map<DateTime, CycleDayInfo>? monthData,
    DateTime? selectedDate,
    CycleDayInfo? selectedDayInfo,
    CycleMonthStats? monthStats,
    bool? isSaving,
  }) {
    return SymptomTrackerLoaded(
      user: user ?? this.user,
      currentMonth: currentMonth ?? this.currentMonth,
      monthData: monthData ?? this.monthData,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDayInfo: selectedDayInfo ?? this.selectedDayInfo,
      monthStats: monthStats ?? this.monthStats,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SymptomTrackerError extends SymptomTrackerState {
  final String message;

  const SymptomTrackerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Helper class for calendar display
class CalendarDay {
  final DateTime date;
  final int? cycleDay;
  final bool isPeriodDay;
  final bool isFertileWindow;
  final MoodType? mood;
  final bool isToday;
  final bool isSelected;

  const CalendarDay({
    required this.date,
    this.cycleDay,
    this.isPeriodDay = false,
    this.isFertileWindow = false,
    this.mood,
    this.isToday = false,
    this.isSelected = false,
  });
}

// Bloc
class SymptomTrackerBloc
    extends Bloc<SymptomTrackerEvent, SymptomTrackerState> {
  final DatabaseService _databaseService;

  SymptomTrackerBloc({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(SymptomTrackerInitial()) {
    on<LoadCycleData>(_onLoadCycleData);
    on<SaveCycleDay>(_onSaveCycleDay);
    on<UpdateSelectedDate>(_onUpdateSelectedDate);
    on<ChangeMonth>(_onChangeMonth);
  }

  Future<void> _onLoadCycleData(
    LoadCycleData event,
    Emitter<SymptomTrackerState> emit,
  ) async {
    emit(SymptomTrackerLoading());

    try {
      print('=== DEBUG: Chargement des données de cycle pour ${event.uid} ===');

      // Récupérer les données utilisateur complètes
      final user = await _databaseService.getUser(event.uid);
      if (user == null) {
        throw Exception('Utilisateur non trouvé');
      }

      print('=== DEBUG: Utilisateur récupéré: ${user.name} ===');
      print(
          '=== DEBUG: Données de cycle existantes: ${user.cycleData.length} jours ===');

      // Calculer les données du mois
      final monthData = CycleCalculationService.calculateMonthCycleData(
        event.startDate,
        user.lastPeriodStartDate,
        user.averageCycleLength,
        user.averagePeriodLength,
        user.cycleData,
      );

      print(
          '=== DEBUG: Données du mois calculées: ${monthData.length} jours ===');

      // Calculer les statistiques du mois
      final monthStats = CycleCalculationService.calculateMonthStats(monthData);

      print('=== DEBUG: Statistiques calculées ===');
      print(
          '=== DEBUG: Jours enregistrés: ${monthStats.recordedDays}/${monthStats.totalDays} ===');

      emit(SymptomTrackerLoaded(
        user: user,
        currentMonth: event.startDate,
        monthData: monthData,
        monthStats: monthStats,
      ));

      print('=== DEBUG: État SymptomTrackerLoaded émis avec succès ===');
    } catch (e) {
      print('=== DEBUG: Erreur lors du chargement: $e ===');
      emit(SymptomTrackerError('Erreur lors du chargement des données: $e'));
    }
  }

  Future<void> _onSaveCycleDay(
    SaveCycleDay event,
    Emitter<SymptomTrackerState> emit,
  ) async {
    if (state is! SymptomTrackerLoaded) return;

    final currentState = state as SymptomTrackerLoaded;
    emit(currentState.copyWith(isSaving: true));

    try {
      print('=== DEBUG: Sauvegarde des données pour ${event.date} ===');

      // Créer l'objet CycleDay
      final cycleDay = CycleDay(
        date: event.date,
        cycleDay: CycleCalculationService.calculateCycleDay(
          event.date,
          currentState.user.lastPeriodStartDate,
          currentState.user.averageCycleLength,
        ),
        flow: event.flow,
        mood: event.mood,
        symptoms: event.symptoms,
        notes: event.notes,
      );

      // Sauvegarder dans Firestore
      final dateKey = DateFormat('yyyy-MM-dd').format(event.date);
      await _databaseService.updateUserCycleData(
        event.uid,
        dateKey,
        cycleDay,
      );

      print('=== DEBUG: Données sauvegardées avec succès ===');

      // Recharger les données du mois
      final startDate = DateTime(
          currentState.currentMonth.year, currentState.currentMonth.month, 1);
      final endDate = DateTime(currentState.currentMonth.year,
          currentState.currentMonth.month + 1, 0);

      add(LoadCycleData(
        uid: event.uid,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      print('=== DEBUG: Erreur lors de la sauvegarde: $e ===');
      emit(SymptomTrackerError('Erreur lors de la sauvegarde: $e'));
    }
  }

  void _onUpdateSelectedDate(
    UpdateSelectedDate event,
    Emitter<SymptomTrackerState> emit,
  ) {
    if (state is! SymptomTrackerLoaded) return;

    final currentState = state as SymptomTrackerLoaded;
    final selectedDayInfo = currentState.monthData[event.date];

    emit(currentState.copyWith(
      selectedDate: event.date,
      selectedDayInfo: selectedDayInfo,
    ));
  }

  void _onChangeMonth(
    ChangeMonth event,
    Emitter<SymptomTrackerState> emit,
  ) {
    if (state is! SymptomTrackerLoaded) return;

    final currentState = state as SymptomTrackerLoaded;

    // Charger les données du nouveau mois
    final startDate = DateTime(event.newMonth.year, event.newMonth.month, 1);
    final endDate = DateTime(event.newMonth.year, event.newMonth.month + 1, 0);

    add(LoadCycleData(
      uid: currentState.user.uid,
      startDate: startDate,
      endDate: endDate,
    ));
  }
}
