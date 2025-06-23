import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final int age;
  final List<String> symptoms;
  final List<String> goals;

  const UserProfile({
    required this.name,
    required this.age,
    required this.symptoms,
    required this.goals,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    List<String>? symptoms,
    List<String>? goals,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      symptoms: symptoms ?? this.symptoms,
      goals: goals ?? this.goals,
    );
  }

  @override
  List<Object?> get props => [name, age, symptoms, goals];
}
