import 'package:flutter/material.dart';
import '../models/agent.dart';
import '../models/ai_agent.dart';
import '../constants/app_colors.dart';

class AgentAvatar extends StatelessWidget {
  final Agent? agent;
  final AgentType? agentType;
  final String? avatar;
  final double size;
  final bool isOnline;

  const AgentAvatar({
    Key? key,
    this.agent,
    this.agentType,
    this.avatar,
    required this.size,
    this.isOnline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color avatarColor;
    IconData avatarIcon;

    // Determine avatar appearance based on available parameters
    if (agent != null) {
      // Use existing Agent model
      switch (agent!.role) {
        case AgentRole.maestro:
          avatarColor = const Color(0xFF8B5CF6);
          avatarIcon = Icons.psychology;
          break;
        case AgentRole.nutrition:
          avatarColor = const Color(0xFF10B981);
          avatarIcon = Icons.restaurant;
          break;
        case AgentRole.coach:
          avatarColor = const Color(0xFFF59E0B);
          avatarIcon = Icons.favorite;
          break;
        case AgentRole.community:
          avatarColor = const Color(0xFF3B82F6);
          avatarIcon = Icons.people;
          break;
      }
    } else if (agentType != null) {
      // Use AgentType from AI agent system
      switch (agentType!) {
        case AgentType.wellnessCoach:
          avatarColor = AppColors.primary;
          avatarIcon = Icons.psychology_rounded;
          break;
        case AgentType.hormoneAssistant:
          avatarColor = AppColors.secondary;
          avatarIcon = Icons.medical_services_rounded;
          break;
        case AgentType.nutritionist:
          avatarColor = AppColors.success;
          avatarIcon = Icons.restaurant_rounded;
          break;
        case AgentType.therapist:
          avatarColor = AppColors.accent;
          avatarIcon = Icons.psychology_alt_rounded;
          break;
        case AgentType.fitnessTrainer:
          avatarColor = AppColors.warning;
          avatarIcon = Icons.fitness_center_rounded;
          break;
      }
    } else {
      // Default fallback
      avatarColor = AppColors.primary;
      avatarIcon = Icons.person_rounded;
    }

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: avatarColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: avatar != null && avatar!.isNotEmpty
              ? ClipOval(
                  child: Image.asset(
                    avatar!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        avatarIcon,
                        color: Colors.white,
                        size: size * 0.5,
                      );
                    },
                  ),
                )
              : Icon(
                  avatarIcon,
                  color: Colors.white,
                  size: size * 0.5,
                ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
