import 'package:flutter_test/flutter_test.dart';
import 'package:ask/models/signup_data.dart';
import 'package:ask/models/user.dart';

void main() {
  group('SignupData Tests', () {
    test('should create valid SignupData', () {
      final signupData = SignupData(
        name: 'Marie Dupont',
        email: 'marie@example.com',
        password: 'motdepasse123',
        menopausePhase: MenopausePhase.peri,
        selectedSymptoms: ['Hot Flashes', 'Night Sweats'],
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 15)),
        averageCycleLength: 28,
        averagePeriodLength: 5,
        selectedConcerns: ['Sleep Quality', 'Energy Levels'],
      );

      print('Validation errors: \\${signupData.getValidationErrors()}');
      expect(signupData.name, equals('Marie Dupont'));
      expect(signupData.email, equals('marie@example.com'));
      expect(signupData.menopausePhase, equals(MenopausePhase.peri));
      expect(signupData.selectedSymptoms.length, equals(2));
      expect(signupData.isValid(), isTrue);
    });

    test('should validate required fields', () {
      final signupData = SignupData(
        name: '',
        email: 'invalid@example.com',
        password: '123',
        menopausePhase: MenopausePhase.pre,
        selectedSymptoms: ['Symptom 1'],
        lastPeriodStartDate: DateTime.now(),
        averageCycleLength: 0,
        averagePeriodLength: 0,
        selectedConcerns: ['Concern 1'],
      );

      expect(signupData.isValid(), isFalse);

      final errors = signupData.getValidationErrors();
      expect(errors.length, greaterThan(0));
      expect(errors.any((error) => error.contains('nom')), isTrue);
      expect(errors.any((error) => error.contains('email')), isFalse);
      expect(errors.any((error) => error.contains('mot de passe')), isTrue);
    });

    test('should convert to Firestore map correctly', () {
      final signupData = SignupData(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        menopausePhase: MenopausePhase.post,
        selectedSymptoms: ['Symptom 1', 'Symptom 2'],
        lastPeriodStartDate: DateTime(2024, 1, 15),
        averageCycleLength: 30,
        averagePeriodLength: 6,
        selectedConcerns: ['Concern 1'],
      );

      final firestoreMap = signupData.toFirestoreMap();

      expect(firestoreMap['personalInfo']['name'], equals('Test User'));
      expect(firestoreMap['personalInfo']['email'], equals('test@example.com'));
      expect(firestoreMap['menopauseInfo']['phase'], equals('post'));
      expect(firestoreMap['menopauseInfo']['symptoms'],
          equals(['Symptom 1', 'Symptom 2']));
      expect(firestoreMap['cycleInfo']['averageCycleLength'], equals(30));
      expect(firestoreMap['cycleInfo']['averagePeriodLength'], equals(6));
      expect(firestoreMap['wellnessConcerns'], equals(['Concern 1']));
      expect(firestoreMap['onboarding']['completed'], isTrue);
    });

    test('should handle optional profile image', () {
      final signupData = SignupData(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        menopausePhase: MenopausePhase.pre,
        selectedSymptoms: ['Symptom 1'],
        lastPeriodStartDate: DateTime.now(),
        averageCycleLength: 28,
        averagePeriodLength: 5,
        selectedConcerns: ['Concern 1'],
        profileImage: null,
      );

      print('Validation errors: \\${signupData.getValidationErrors()}');
      expect(signupData.profileImage, isNull);
      expect(signupData.isValid(), isTrue);
    });

    test('should handle date of birth', () {
      final dateOfBirth = DateTime(1980, 5, 15);
      final signupData = SignupData(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        menopausePhase: MenopausePhase.peri,
        selectedSymptoms: ['Symptom 1'],
        lastPeriodStartDate: DateTime.now(),
        averageCycleLength: 28,
        averagePeriodLength: 5,
        selectedConcerns: ['Concern 1'],
        dateOfBirth: dateOfBirth,
      );

      expect(signupData.dateOfBirth, equals(dateOfBirth));

      final firestoreMap = signupData.toFirestoreMap();
      expect(firestoreMap['personalInfo']['dateOfBirth'],
          equals(dateOfBirth.toIso8601String()));
    });
  });

  group('SignupData Edge Cases', () {
    test('should handle empty symptoms and concerns', () {
      final signupData = SignupData(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        menopausePhase: MenopausePhase.pre,
        selectedSymptoms: [],
        lastPeriodStartDate: DateTime.now(),
        averageCycleLength: 28,
        averagePeriodLength: 5,
        selectedConcerns: [],
      );

      expect(signupData.selectedSymptoms.isEmpty, isTrue);
      expect(signupData.selectedConcerns.isEmpty, isTrue);
      expect(signupData.isValid(),
          isFalse); // Doit avoir au moins un symptôme et une préoccupation
    });

    test('should validate cycle lengths', () {
      final signupData = SignupData(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        menopausePhase: MenopausePhase.pre,
        selectedSymptoms: ['Symptom 1'],
        lastPeriodStartDate: DateTime.now(),
        averageCycleLength: -5, // Invalide
        averagePeriodLength: 0, // Invalide
        selectedConcerns: ['Concern 1'],
      );

      expect(signupData.isValid(), isFalse);

      final errors = signupData.getValidationErrors();
      expect(errors.any((error) => error.contains('cycle')), isTrue);
      expect(errors.any((error) => error.contains('règles')), isTrue);
    });

    test('should validate password strength', () {
      final signupData = SignupData(
        name: 'Test User',
        email: 'test@example.com',
        password: '123', // Trop court
        menopausePhase: MenopausePhase.pre,
        selectedSymptoms: ['Symptom 1'],
        lastPeriodStartDate: DateTime.now(),
        averageCycleLength: 28,
        averagePeriodLength: 5,
        selectedConcerns: ['Concern 1'],
      );

      expect(signupData.isValid(), isFalse);

      final errors = signupData.getValidationErrors();
      expect(errors.any((error) => error.contains('mot de passe')), isTrue);
    });
  });
}
