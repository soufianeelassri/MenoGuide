import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_profile.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class UpdateName extends OnboardingEvent {
  final String name;

  const UpdateName(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateAge extends OnboardingEvent {
  final int age;

  const UpdateAge(this.age);

  @override
  List<Object?> get props => [age];
}

class UpdateSymptoms extends OnboardingEvent {
  final List<String> symptoms;

  const UpdateSymptoms(this.symptoms);

  @override
  List<Object?> get props => [symptoms];
}

class UpdateGoals extends OnboardingEvent {
  final List<String> goals;

  const UpdateGoals(this.goals);

  @override
  List<Object?> get props => [goals];
}

class CompleteOnboarding extends OnboardingEvent {}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingInProgress extends OnboardingState {
  final UserProfile profile;

  const OnboardingInProgress(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OnboardingCompleted extends OnboardingState {
  final UserProfile profile;

  const OnboardingCompleted(this.profile);

  @override
  List<Object?> get props => [profile];
}

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<UpdateName>(_onUpdateName);
    on<UpdateAge>(_onUpdateAge);
    on<UpdateSymptoms>(_onUpdateSymptoms);
    on<UpdateGoals>(_onUpdateGoals);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  void _onUpdateName(UpdateName event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentProfile = (state as OnboardingInProgress).profile;
      emit(OnboardingInProgress(currentProfile.copyWith(name: event.name)));
    } else {
      emit(OnboardingInProgress(UserProfile(
        name: event.name,
        age: 0,
        symptoms: [],
        goals: [],
      )));
    }
  }

  void _onUpdateAge(UpdateAge event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentProfile = (state as OnboardingInProgress).profile;
      emit(OnboardingInProgress(currentProfile.copyWith(age: event.age)));
    } else {
      emit(OnboardingInProgress(UserProfile(
        name: '',
        age: event.age,
        symptoms: [],
        goals: [],
      )));
    }
  }

  void _onUpdateSymptoms(UpdateSymptoms event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentProfile = (state as OnboardingInProgress).profile;
      emit(OnboardingInProgress(
          currentProfile.copyWith(symptoms: event.symptoms)));
    } else {
      emit(OnboardingInProgress(UserProfile(
        name: '',
        age: 0,
        symptoms: event.symptoms,
        goals: [],
      )));
    }
  }

  void _onUpdateGoals(UpdateGoals event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentProfile = (state as OnboardingInProgress).profile;
      emit(OnboardingInProgress(currentProfile.copyWith(goals: event.goals)));
    } else {
      emit(OnboardingInProgress(UserProfile(
        name: '',
        age: 0,
        symptoms: [],
        goals: event.goals,
      )));
    }
  }

  void _onCompleteOnboarding(
      CompleteOnboarding event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final profile = (state as OnboardingInProgress).profile;
      emit(OnboardingCompleted(profile));
    }
  }
}
