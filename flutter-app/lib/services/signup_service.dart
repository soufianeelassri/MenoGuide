import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import '../models/signup_data.dart';
import 'database_service.dart';

/// Exceptions personnalisées pour une meilleure gestion d'erreurs
class SignupException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  SignupException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'SignupException: $message';
}

/// Service complet pour gérer l'inscription utilisateur
class SignupService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  /// Méthode principale d'inscription qui orchestre tout le processus
  Future<UserCredential> signupUser(SignupData signupData) async {
    UserCredential? userCredential;

    try {
      print('=== DEBUG: Début signupUser ===');

      // 1. Validation des données
      if (!signupData.isValid()) {
        final errors = signupData.getValidationErrors();
        throw SignupException(
            'Données d\'inscription invalides: ${errors.join(', ')}');
      }
      print('=== DEBUG: Validation des données OK ===');

      // 2. Création du compte Firebase Auth
      print('=== DEBUG: Création du compte Firebase Auth ===');
      userCredential = await _createFirebaseUser(
        signupData.email,
        signupData.password,
      );
      print(
          '=== DEBUG: Compte Firebase Auth créé avec uid: ${userCredential.user?.uid} ===');

      // 3. Upload de l'image de profil (si fournie)
      String? profileImageUrl;
      if (signupData.profileImage != null) {
        print('=== DEBUG: Upload de l\'image de profil ===');
        profileImageUrl = await _databaseService.uploadProfileImage(
          userCredential.user!.uid,
          signupData.profileImage!,
        );
        print('=== DEBUG: Image de profil uploadée: $profileImageUrl ===');
      } else {
        print('=== DEBUG: Aucune image de profil à uploader ===');
      }

      // 4. Sauvegarde des données dans Firestore
      print('=== DEBUG: Sauvegarde des données dans Firestore ===');
      await _databaseService.createUserDocument(
        userCredential.user!.uid,
        signupData,
        profileImageUrl: profileImageUrl,
      );
      print('=== DEBUG: Données sauvegardées dans Firestore ===');

      print('=== DEBUG: Signup terminé avec succès ===');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('=== DEBUG: Erreur FirebaseAuth: ${e.code} - ${e.message} ===');
      throw _handleFirebaseAuthError(e);
    } on DatabaseException catch (e) {
      print('=== DEBUG: Erreur Database: ${e.message} ===');
      // Nettoyer en cas d'échec
      if (userCredential?.user?.uid != null) {
        await _databaseService.cleanupOnFailure(userCredential!.user!.uid);
      }
      throw SignupException(
        'Erreur lors de la sauvegarde des données: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } on FirebaseException catch (e) {
      print('=== DEBUG: Erreur Firebase: ${e.code} - ${e.message} ===');
      throw SignupException(
        'Erreur Firebase: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      print('=== DEBUG: Erreur inattendue: $e ===');
      throw SignupException(
        'Erreur inattendue lors de l\'inscription: $e',
        originalError: e,
      );
    }
  }

  /// Création du compte utilisateur Firebase Auth
  Future<UserCredential> _createFirebaseUser(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  /// Gestion des erreurs Firebase Auth
  SignupException _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return SignupException(
          'Cette adresse email est déjà utilisée. Veuillez vous connecter ou utiliser une autre adresse.',
          code: e.code,
        );
      case 'invalid-email':
        return SignupException(
          'Adresse email invalide. Veuillez vérifier le format.',
          code: e.code,
        );
      case 'weak-password':
        return SignupException(
          'Le mot de passe est trop faible. Il doit contenir au moins 6 caractères.',
          code: e.code,
        );
      case 'operation-not-allowed':
        return SignupException(
          'L\'inscription par email/mot de passe n\'est pas activée.',
          code: e.code,
        );
      case 'too-many-requests':
        return SignupException(
          'Trop de tentatives. Veuillez réessayer dans quelques minutes.',
          code: e.code,
        );
      default:
        return SignupException(
          'Erreur d\'authentification: ${e.message}',
          code: e.code,
          originalError: e,
        );
    }
  }
}
