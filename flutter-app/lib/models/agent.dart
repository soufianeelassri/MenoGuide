import 'package:equatable/equatable.dart';

enum AgentRole { maestro, nutrition, coach, community }

class Agent extends Equatable {
  final String name;
  final AgentRole role;
  final String avatarAsset;
  final String description;

  const Agent({
    required this.name,
    required this.role,
    required this.avatarAsset,
    required this.description,
  });

  static const Agent maestro = Agent(
    name: 'Maestro',
    role: AgentRole.maestro,
    avatarAsset: 'assets/avatars/maestro.png',
    description: 'Your wellness orchestrator',
  );

  static const Agent nutrition = Agent(
    name: 'Dr. Sarah',
    role: AgentRole.nutrition,
    avatarAsset: 'assets/avatars/nutrition.png',
    description: 'Nutrition Expert',
  );

  static const Agent coach = Agent(
    name: 'Coach Maria',
    role: AgentRole.coach,
    avatarAsset: 'assets/avatars/coach.png',
    description: 'Life Coach',
  );

  static const Agent community = Agent(
    name: 'Lisa',
    role: AgentRole.community,
    avatarAsset: 'assets/avatars/community.png',
    description: 'Community Connector',
  );

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role.name,
      'avatarAsset': avatarAsset,
      'description': description,
    };
  }

  /// Create from JSON
  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      name: json['name'],
      role: AgentRole.values.firstWhere(
        (e) => e.name == json['role'],
      ),
      avatarAsset: json['avatarAsset'],
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [name, role, avatarAsset, description];
}
