import 'dart:io';
import 'package:equatable/equatable.dart';
import 'user.dart';

/// Modèle encapsulant toutes les données d'inscription
class SignupData extends Equatable {
  final String name;
  final String email;
  final String password;
  final MenopausePhase menopausePhase;
  final List<String> selectedSymptoms;
  final DateTime lastPeriodStartDate;
  final int averageCycleLength;
  final int averagePeriodLength;
  final List<String> selectedConcerns;
  final File? profileImage;
  final DateTime? dateOfBirth;

  const SignupData({
    required this.name,
    required this.email,
    required this.password,
    required this.menopausePhase,
    required this.selectedSymptoms,
    required this.lastPeriodStartDate,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.selectedConcerns,
    this.profileImage,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        menopausePhase,
        selectedSymptoms,
        lastPeriodStartDate,
        averageCycleLength,
        averagePeriodLength,
        selectedConcerns,
        profileImage,
        dateOfBirth,
      ];

  /// Convertit les données en Map pour Firestore (structure simplifiée)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'personalInfo': {
        'name': name,
        'email': email,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      },
      'menopauseInfo': {
        'phase': menopausePhase.toString().split('.').last,
      },
      'cycleInfo': {
        'lastPeriodStartDate': lastPeriodStartDate.toIso8601String(),
        'averageCycleLength': averageCycleLength,
        'averagePeriodLength': averagePeriodLength,
        'estimatedByAI': false,
        'completedCycles': 0,
      },
      'onboarding': {
        'currentStep': 'completed',
        'completed': true,
        'selectedGoals': [],
      },
      'preferences': {
        'notificationsEnabled': true,
        'anonymousModeEnabled': false,
        'language': 'fr',
      },
      // Les timestamps seront ajoutés par le service
    };
  }

  /// Valide les données d'inscription
  bool isValid() {
    final emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return name.isNotEmpty &&
        email.isNotEmpty &&
        emailRegex.hasMatch(email) &&
        password.length >= 6 &&
        selectedSymptoms.isNotEmpty &&
        selectedConcerns.isNotEmpty &&
        averageCycleLength > 0 &&
        averagePeriodLength > 0;
  }

  /// Retourne les erreurs de validation
  List<String> getValidationErrors() {
    final errors = <String>[];
    final emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[\w\-]{2,4}$');

    if (name.isEmpty) errors.add('Le nom est requis');
    if (email.isEmpty) {
      errors.add('L\'email est requis');
    } else if (!emailRegex.hasMatch(email)) {
      errors.add('Le format de l\'email est invalide');
    }
    if (password.length < 6)
      errors.add('Le mot de passe doit contenir au moins 6 caractères');
    if (selectedSymptoms.isEmpty)
      errors.add('Veuillez sélectionner au moins un symptôme');
    if (selectedConcerns.isEmpty)
      errors.add('Veuillez sélectionner au moins une préoccupation');
    if (averageCycleLength <= 0)
      errors.add('La durée moyenne du cycle doit être positive');
    if (averagePeriodLength <= 0)
      errors.add('La durée moyenne des règles doit être positive');

    return errors;
  }
}
