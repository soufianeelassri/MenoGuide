import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initAuthListener();
  }

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;

  // Listen to Firebase Auth state changes
  void _initAuthListener() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        try {
          // Get user data from Firestore
          final userDoc =
              await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            _currentUser = User.fromFirestore(userData, firebaseUser.uid);
          } else {
            // Document doesn't exist yet (Cloud Function hasn't run or failed)
            // Create basic user object without Firestore data
            _currentUser = User(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              name: firebaseUser.displayName ?? '',
              averageCycleLength: 28,
              averagePeriodLength: 5,
              lastPeriodStartDate: DateTime.now(),
              menopausePhase: MenopausePhase.pre,
              symptoms: const [],
              concerns: const [],
            );
          }
        } catch (e) {
          // If there's any error (permission denied, etc.), create basic user
          print('Error loading user data from Firestore: $e');
          _currentUser = User(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? '',
            averageCycleLength: 28,
            averagePeriodLength: 5,
            lastPeriodStartDate: DateTime.now(),
            menopausePhase: MenopausePhase.pre,
            symptoms: const [],
            concerns: const [],
          );
        }
        _userController.add(_currentUser);
      } else {
        _currentUser = null;
        _userController.add(null);
      }
    });
  }

  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed');
      }

      // User data will be loaded by the auth state listener
      return _currentUser ??
          User(
            uid: userCredential.user!.uid,
            email: email,
            name: '',
            averageCycleLength: 28,
            averagePeriodLength: 5,
            lastPeriodStartDate: DateTime.now(),
            menopausePhase: MenopausePhase.pre,
            symptoms: const [],
            concerns: const [],
          );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> signup(
    String name,
    String email,
    String password, {
    required int averageCycleLength,
    required int averagePeriodLength,
    required DateTime lastPeriodStartDate,
    required MenopausePhase menopausePhase,
    required List<String> selectedSymptoms,
    required List<String> selectedConcerns,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Signup failed');
      }

      final user = User(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        averageCycleLength: averageCycleLength,
        averagePeriodLength: averagePeriodLength,
        lastPeriodStartDate: lastPeriodStartDate,
        menopausePhase: menopausePhase,
        symptoms: selectedSymptoms,
        concerns: selectedConcerns,
      );

      // Save user data to Firestore using the new structure
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());

      _currentUser = user;
      _userController.add(user);
      return user;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _userController.add(null);
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
      _currentUser = user;
      _userController.add(user);
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }

  Future<String?> getGCloudAccessToken() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/menovibe-gcloud-service-account.json');
      final credentials =
          auth.ServiceAccountCredentials.fromJson(json.decode(jsonString));

      final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

      final client = await auth.clientViaServiceAccount(credentials, scopes);
      final accessToken = client.credentials.accessToken;

      return accessToken.data;
    } catch (e) {
      print('Error getting GCloud access token: $e');
      return null;
    }
  }

  void dispose() {
    _userController.close();
  }
}
