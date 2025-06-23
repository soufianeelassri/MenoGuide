import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import '../models/user.dart';
import '../models/signup_data.dart';

/// Exceptions personnalisées pour une meilleure gestion d'erreurs
class DatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  DatabaseException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'DatabaseException: $message';
}

class ImageUploadException implements Exception {
  final String message;
  final dynamic originalError;

  ImageUploadException(this.message, {this.originalError});

  @override
  String toString() => 'ImageUploadException: $message';
}

/// Service complet pour gérer les opérations de base de données
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Créer un nouveau document utilisateur avec toutes les données
  Future<void> createUserDocument(String uid, SignupData signupData,
      {String? profileImageUrl}) async {
    try {
      print('=== DEBUG: Création du document utilisateur pour uid: $uid ===');

      // Créer la structure de données complète
      final Map<String, dynamic> userData = {
        'personalInfo': {
          'name': signupData.name,
          'email': signupData.email,
          'dateOfBirth': signupData.dateOfBirth?.toIso8601String(),
          'profileImageUrl': profileImageUrl,
        },
        'menopauseInfo': {
          'phase': signupData.menopausePhase.toString().split('.').last,
        },
        'cycleInfo': {
          'lastPeriodStartDate':
              signupData.lastPeriodStartDate.toIso8601String(),
          'averageCycleLength': signupData.averageCycleLength,
          'averagePeriodLength': signupData.averagePeriodLength,
          'estimatedByAI': false,
          'completedCycles': 0,
        },
        'symptoms': signupData.selectedSymptoms,
        'concerns': signupData.selectedConcerns,
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
        'metadata': {
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      };

      print('=== DEBUG: Données utilisateur préparées ===');

      // Sauvegarder dans Firestore
      await _firestore.collection('users').doc(uid).set(userData);

      print('=== DEBUG: Document utilisateur créé avec succès ===');
    } on FirebaseException catch (e) {
      print('=== DEBUG: Erreur Firebase: ${e.code} - ${e.message} ===');
      throw DatabaseException(
        'Erreur lors de la création du document utilisateur: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      print('=== DEBUG: Erreur inattendue: $e ===');
      throw DatabaseException(
        'Erreur inattendue lors de la création du document utilisateur: $e',
        originalError: e,
      );
    }
  }

  /// Mettre à jour un document utilisateur existant
  Future<void> updateUserDocument(
      String uid, Map<String, dynamic> updates) async {
    try {
      print(
          '=== DEBUG: Mise à jour du document utilisateur pour uid: $uid ===');

      // Ajouter le timestamp de mise à jour
      updates['metadata.updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection('users').doc(uid).update(updates);

      print('=== DEBUG: Document utilisateur mis à jour avec succès ===');
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la mise à jour du document utilisateur: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Récupérer les données complètes d'un utilisateur
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      print(
          '=== DEBUG: Récupération des données utilisateur pour uid: $uid ===');

      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('=== DEBUG: Données utilisateur récupérées avec succès ===');
        return data;
      } else {
        print('=== DEBUG: Document utilisateur non trouvé ===');
        return null;
      }
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la récupération des données utilisateur: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Récupérer l'utilisateur complet avec toutes ses données
  Future<User?> getUser(String uid) async {
    try {
      print(
          '=== DEBUG: Récupération de l\'utilisateur complet pour uid: $uid ===');

      final userData = await getUserData(uid);
      if (userData != null) {
        final user = User.fromFirestore(userData, uid);
        print('=== DEBUG: Utilisateur récupéré avec succès: ${user.name} ===');
        return user;
      }
      return null;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la récupération de l\'utilisateur: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Upload et optimisation d'une image de profil
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      print('=== DEBUG: Début upload image de profil pour uid: $uid ===');

      // Optimisation de l'image
      final Uint8List optimizedImageBytes = await _optimizeImage(imageFile);
      print(
          '=== DEBUG: Image optimisée, taille: ${optimizedImageBytes.length} bytes ===');

      // Création de la référence de stockage
      final Reference storageRef =
          _storage.ref().child('profile_images/$uid.jpg');
      print('=== DEBUG: Référence storage créée: profile_images/$uid.jpg ===');

      // Upload avec métadonnées
      final UploadTask uploadTask = storageRef.putData(
        optimizedImageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalSize': imageFile.lengthSync().toString(),
            'optimizedSize': optimizedImageBytes.length.toString(),
            'userId': uid,
          },
        ),
      );

      print('=== DEBUG: Upload task démarré ===');

      // Attendre la completion et récupérer l'URL
      final TaskSnapshot snapshot = await uploadTask;
      print('=== DEBUG: Upload terminé avec succès ===');

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('=== DEBUG: URL de téléchargement obtenue: $downloadUrl ===');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print(
          '=== DEBUG: Erreur Firebase lors de l\'upload: ${e.code} - ${e.message} ===');
      throw ImageUploadException(
        'Erreur lors de l\'upload de l\'image: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      print('=== DEBUG: Erreur inattendue lors de l\'upload: $e ===');
      throw ImageUploadException(
        'Erreur inattendue lors de l\'upload de l\'image: $e',
        originalError: e,
      );
    }
  }

  /// Optimisation de l'image pour réduire la taille
  Future<Uint8List> _optimizeImage(File imageFile) async {
    try {
      // Lire l'image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw ImageUploadException('Impossible de décoder l\'image');
      }

      // Redimensionner si trop grande (max 800x800)
      img.Image resizedImage = image;
      if (image.width > 800 || image.height > 800) {
        resizedImage = img.copyResize(
          image,
          width: 800,
          height: 800,
          interpolation: img.Interpolation.linear,
        );
      }

      // Convertir en JPEG avec qualité 85%
      return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
    } catch (e) {
      throw ImageUploadException(
        'Erreur lors de l\'optimisation de l\'image: $e',
        originalError: e,
      );
    }
  }

  /// Supprimer une image de profil
  Future<void> deleteProfileImage(String uid) async {
    try {
      print('=== DEBUG: Suppression de l\'image de profil pour uid: $uid ===');

      final Reference storageRef =
          _storage.ref().child('profile_images/$uid.jpg');
      await storageRef.delete();

      print('=== DEBUG: Image de profil supprimée avec succès ===');
    } on FirebaseException catch (e) {
      // Ne pas faire échouer si l'image n'existe pas
      if (e.code != 'object-not-found') {
        throw DatabaseException(
          'Erreur lors de la suppression de l\'image: ${e.message}',
          code: e.code,
          originalError: e,
        );
      }
    }
  }

  /// Mettre à jour les symptômes d'un utilisateur
  Future<void> updateUserSymptoms(String uid, List<String> symptoms) async {
    try {
      await updateUserDocument(uid, {
        'symptoms': symptoms,
        'menopauseInfo.updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la mise à jour des symptômes: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Mettre à jour les préoccupations d'un utilisateur
  Future<void> updateUserConcerns(String uid, List<String> concerns) async {
    try {
      await updateUserDocument(uid, {
        'concerns': concerns,
        'menopauseInfo.updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la mise à jour des préoccupations: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Migration des données existantes (pour les utilisateurs existants)
  Future<void> migrateUserData(String uid) async {
    try {
      print('=== DEBUG: Migration des données pour uid: $uid ===');

      // Récupérer les données des anciennes collections
      final symptomsDoc =
          await _firestore.collection('user_symptoms').doc(uid).get();
      final concernsDoc =
          await _firestore.collection('user_concerns').doc(uid).get();

      final Map<String, dynamic> updates = {};

      // Migrer les symptômes
      if (symptomsDoc.exists) {
        final symptomsData = symptomsDoc.data() as Map<String, dynamic>;
        updates['symptoms'] = symptomsData['symptoms'] ?? [];
        print('=== DEBUG: Symptômes migrés: ${updates['symptoms']} ===');
      }

      // Migrer les préoccupations
      if (concernsDoc.exists) {
        final concernsData = concernsDoc.data() as Map<String, dynamic>;
        updates['concerns'] = concernsData['concerns'] ?? [];
        print('=== DEBUG: Préoccupations migrées: ${updates['concerns']} ===');
      }

      // Mettre à jour le document utilisateur principal
      if (updates.isNotEmpty) {
        await updateUserDocument(uid, updates);

        // Supprimer les anciennes collections après migration réussie
        if (symptomsDoc.exists) {
          await _firestore.collection('user_symptoms').doc(uid).delete();
        }
        if (concernsDoc.exists) {
          await _firestore.collection('user_concerns').doc(uid).delete();
        }

        print('=== DEBUG: Migration terminée avec succès ===');
      }
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la migration des données: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Mettre à jour les données de cycle d'un utilisateur
  Future<void> updateUserCycleData(
    String uid,
    String dateKey,
    CycleDay cycleDay,
  ) async {
    try {
      print(
          '=== DEBUG: Mise à jour des données de cycle pour $uid, date: $dateKey ===');

      // Mettre à jour le document utilisateur avec les nouvelles données de cycle
      await _firestore.collection('users').doc(uid).update({
        'cycleData.$dateKey': cycleDay.toMap(),
        'metadata.updatedAt': DateTime.now().toIso8601String(),
      });

      print('=== DEBUG: Données de cycle mises à jour avec succès ===');
    } on FirebaseException catch (e) {
      print('=== DEBUG: Erreur Firebase: ${e.code} - ${e.message} ===');
      throw DatabaseException(
        'Erreur lors de la mise à jour des données de cycle: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      print('=== DEBUG: Erreur inattendue: $e ===');
      throw DatabaseException(
        'Erreur inattendue lors de la mise à jour des données de cycle: $e',
        originalError: e,
      );
    }
  }

  /// Nettoyer les données en cas d'échec lors de l'inscription
  Future<void> cleanupOnFailure(String uid) async {
    try {
      print('=== DEBUG: Nettoyage des données pour uid: $uid ===');

      // Supprimer le document utilisateur
      await _firestore.collection('users').doc(uid).delete();

      // Supprimer l'image de profil si elle existe
      try {
        final storageRef = _storage.ref().child('profile_images/$uid.jpg');
        await storageRef.delete();
        print('=== DEBUG: Image de profil supprimée ===');
      } catch (e) {
        print('=== DEBUG: Erreur lors de la suppression de l\'image: $e ===');
        // Ne pas faire échouer le nettoyage si l'image n'existe pas
      }

      print('=== DEBUG: Nettoyage terminé avec succès ===');
    } catch (e) {
      print('=== DEBUG: Erreur lors du nettoyage: $e ===');
      // Ne pas relancer l'erreur car c'est déjà un échec
    }
  }

  /// Sauvegarder les données de cycle pour un jour spécifique
  Future<void> saveCycleDay(String uid, CycleDay cycleDay) async {
    try {
      print(
          '=== DEBUG: Sauvegarde des données de cycle pour ${cycleDay.date} ===');

      final dateKey =
          '${cycleDay.date.year}-${cycleDay.date.month.toString().padLeft(2, '0')}-${cycleDay.date.day.toString().padLeft(2, '0')}';

      await updateUserDocument(uid, {
        'cycleData.$dateKey': cycleDay.toMap(),
      });

      print('=== DEBUG: Données de cycle sauvegardées avec succès ===');
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la sauvegarde des données de cycle: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Récupérer les données de cycle pour une période donnée
  Future<Map<String, CycleDay>> getCycleData(
      String uid, DateTime startDate, DateTime endDate) async {
    try {
      print(
          '=== DEBUG: Récupération des données de cycle du ${startDate} au ${endDate} ===');

      final userData = await getUserData(uid);
      if (userData == null || userData['cycleData'] == null) {
        return {};
      }

      final cycleDataRaw = userData['cycleData'] as Map<String, dynamic>;
      final cycleData = <String, CycleDay>{};

      for (final entry in cycleDataRaw.entries) {
        final date = DateTime.parse(entry.value['date']);
        if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate.add(const Duration(days: 1)))) {
          cycleData[entry.key] = CycleDay.fromMap(entry.value);
        }
      }

      print('=== DEBUG: ${cycleData.length} jours de cycle récupérés ===');
      return cycleData;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        'Erreur lors de la récupération des données de cycle: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }
}
