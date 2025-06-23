import 'package:flutter/material.dart';

class GoalSelector extends StatelessWidget {
  final List<String> selectedGoals;
  final Function(List<String>) onGoalsChanged;

  const GoalSelector({
    Key? key,
    required this.selectedGoals,
    required this.onGoalsChanged,
  }) : super(key: key);

  static const List<String> _goals = [
    'Manage hot flashes',
    'Improve sleep quality',
    'Reduce stress and anxiety',
    'Maintain healthy weight',
    'Boost energy levels',
    'Improve mood',
    'Strengthen bones',
    'Find community support',
    'Learn about nutrition',
    'Develop self-care routine',
    'Manage brain fog',
    'Improve skin health',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final isSelected = selectedGoals.contains(goal);

              return GestureDetector(
                onTap: () {
                  final newSelection = List<String>.from(selectedGoals);
                  if (isSelected) {
                    newSelection.remove(goal);
                  } else {
                    newSelection.add(goal);
                  }
                  onGoalsChanged(newSelection);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        goal,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1F2937),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selected: ${selectedGoals.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
        ],
      ],
    );
  }
}
