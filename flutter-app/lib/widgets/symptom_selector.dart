import 'package:flutter/material.dart';

class SymptomSelector extends StatelessWidget {
  final List<String> selectedSymptoms;
  final Function(List<String>) onSymptomsChanged;

  const SymptomSelector({
    Key? key,
    required this.selectedSymptoms,
    required this.onSymptomsChanged,
  }) : super(key: key);

  static const List<String> _symptoms = [
    'Hot flashes',
    'Night sweats',
    'Mood swings',
    'Sleep problems',
    'Weight gain',
    'Fatigue',
    'Brain fog',
    'Vaginal dryness',
    'Irregular periods',
    'Anxiety',
    'Depression',
    'Joint pain',
    'Headaches',
    'Heart palpitations',
    'Hair loss',
    'Dry skin',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.0,
      ),
      itemCount: _symptoms.length,
      itemBuilder: (context, index) {
        final symptom = _symptoms[index];
        final isSelected = selectedSymptoms.contains(symptom);

        return GestureDetector(
          onTap: () {
            final newSelection = List<String>.from(selectedSymptoms);
            if (isSelected) {
              newSelection.remove(symptom);
            } else {
              newSelection.add(symptom);
            }
            onSymptomsChanged(newSelection);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFFE5E7EB),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Center(
                child: Text(
                  symptom,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
