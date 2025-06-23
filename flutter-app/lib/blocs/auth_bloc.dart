import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../models/signup_data.dart';
import '../services/auth_service.dart';
import '../services/signup_service.dart';
import '../services/database_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final SignupData signupData;

  const SignupRequested({required this.signupData});

  @override
  List<Object?> get props => [signupData];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final firebase_auth.User firebaseUser;
  final User userProfile;

  const Authenticated({
    required this.firebaseUser,
    required this.userProfile,
  });

  @override
  List<Object?> get props => [firebaseUser, userProfile];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final SignupService _signupService;
  final DatabaseService _databaseService;

  AuthBloc({
    required AuthService authService,
    required SignupService signupService,
    required DatabaseService databaseService,
  })  : _authService = authService,
        _signupService = signupService,
        _databaseService = databaseService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Récupérer les données utilisateur complètes depuis Firestore
        final userProfile = await _databaseService.getUser(currentUser.uid);
        if (userProfile != null) {
          // Créer un objet firebase_auth.User factice pour la compatibilité
          final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            emit(Authenticated(
              firebaseUser: firebaseUser,
              userProfile: userProfile,
            ));
          } else {
            emit(Unauthenticated());
          }
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(
          message:
              'Erreur lors de la vérification de l\'authentification: $e'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('=== DEBUG: Début de la connexion pour ${event.email} ===');

      final user = await _authService.login(event.email, event.password);
      print(
          '=== DEBUG: Connexion Firebase Auth réussie pour uid: ${user.uid} ===');

      // Récupérer les données utilisateur complètes depuis Firestore
      print(
          '=== DEBUG: Récupération des données utilisateur depuis Firestore ===');
      final userProfile = await _databaseService.getUser(user.uid);

      if (userProfile != null) {
        print('=== DEBUG: Données utilisateur récupérées avec succès ===');
        print('=== DEBUG: Nom: ${userProfile.name} ===');
        print('=== DEBUG: Phase ménopause: ${userProfile.menopausePhase} ===');
        print('=== DEBUG: Symptômes: ${userProfile.symptoms.length} ===');
        print('=== DEBUG: Préoccupations: ${userProfile.concerns.length} ===');
        print(
            '=== DEBUG: Données de cycle: ${userProfile.cycleData.length} jours ===');

        final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          emit(Authenticated(
            firebaseUser: firebaseUser,
            userProfile: userProfile,
          ));
          print('=== DEBUG: État Authenticated émis avec succès ===');
        } else {
          print('=== DEBUG: Erreur - Firebase User null après connexion ===');
          emit(AuthError(
              message: 'Erreur lors de la récupération des données Firebase'));
        }
      } else {
        print('=== DEBUG: Données utilisateur non trouvées dans Firestore ===');
        emit(AuthError(message: 'Données utilisateur non trouvées'));
      }
    } catch (e) {
      print('=== DEBUG: Erreur de connexion: $e ===');
      emit(AuthError(message: 'Erreur de connexion: $e'));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await _signupService.signupUser(event.signupData);
      final firebaseUser = userCredential.user!;

      // Récupérer les données utilisateur complètes depuis Firestore
      final userProfile = await _databaseService.getUser(firebaseUser.uid);
      if (userProfile != null) {
        emit(Authenticated(
          firebaseUser: firebaseUser,
          userProfile: userProfile,
        ));
      } else {
        emit(AuthError(
            message: 'Erreur lors de la récupération des données utilisateur'));
      }
    } catch (e) {
      emit(AuthError(message: 'Erreur d\'inscription: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Erreur de déconnexion: $e'));
    }
  }
}
