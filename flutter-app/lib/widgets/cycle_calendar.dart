import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../constants/app_colors.dart';

class CycleCalendar extends StatefulWidget {
  const CycleCalendar({
    super.key,
    required this.cycleData,
    required this.lastPeriodStartDate,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.onDaySelected,
    required this.selectedDate,
  });

  final Map<String, CycleDay> cycleData;
  final DateTime lastPeriodStartDate;
  final int averageCycleLength;
  final int averagePeriodLength;
  final Function(DateTime date, CycleDay? cycleDay) onDaySelected;
  final DateTime selectedDate;

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(CycleCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDate =
                  DateTime(_focusedDate.year, _focusedDate.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left, color: AppColors.primary),
        ),
        Text(
          DateFormat('MMMM yyyy', 'fr_FR').format(_focusedDate),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDate =
                  DateTime(_focusedDate.year, _focusedDate.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    // Calculate start date for calendar grid (including previous month's days)
    final startDate =
        firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));

    return Column(
      children: [
        // Day headers
        Row(
          children: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
              .map((day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        // Calendar grid
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final date =
                  startDate.add(Duration(days: weekIndex * 7 + dayIndex));
              final isCurrentMonth = date.month == _focusedDate.month;
              final isSelected = _isSameDay(date, _selectedDate);
              final cycleDay = _getCycleDay(date);

              return Expanded(
                child: _buildCalendarDay(
                    date, isCurrentMonth, isSelected, cycleDay),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarDay(
      DateTime date, bool isCurrentMonth, bool isSelected, CycleDay? cycleDay) {
    final isToday = _isSameDay(date, DateTime.now());
    final hasPeriod = cycleDay?.flow != null;
    final isPredictedPeriod = _isPredictedPeriodDay(date);
    final isFertileWindow = _isFertileWindowDay(date);
    final moodColor = _getMoodColor(cycleDay?.mood);
    final hasSymptoms = (cycleDay?.symptoms ?? []).isNotEmpty;

    // Determine background color based on symptoms and other factors
    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = AppColors.primary.withOpacity(0.2);
    } else if (hasSymptoms) {
      backgroundColor = AppColors.secondary.withOpacity(0.3);
    } else if (isToday) {
      backgroundColor = AppColors.primary.withOpacity(0.1);
    } else if (hasPeriod) {
      backgroundColor = Colors.pink[100]?.withOpacity(0.3);
    } else if (isPredictedPeriod) {
      backgroundColor = Colors.pink[50]?.withOpacity(0.3);
    } else if (isFertileWindow) {
      backgroundColor = Colors.orange[100]?.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        widget.onDaySelected(date, cycleDay);
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : hasSymptoms
                  ? Border.all(color: AppColors.secondary, width: 1)
                  : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Day number - positioned safely
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.4,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isCurrentMonth
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Period icon (🌸) - top right, with constraints
                if (hasPeriod || isPredictedPeriod)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.3,
                        maxHeight: constraints.maxHeight * 0.3,
                      ),
                      child: Text(
                        '🌸',
                        style: TextStyle(
                          fontSize: 10,
                          color: hasPeriod
                              ? Colors.pink[600]
                              : Colors.pink[300]?.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                // Flow intensity drops (💧) - below period icon, with constraints
                if (hasPeriod)
                  Positioned(
                    top: 16,
                    right: 2,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.4,
                        maxHeight: constraints.maxHeight * 0.3,
                      ),
                      child: _buildFlowDrops(cycleDay!.flow!),
                    ),
                  ),

                // Fertile window icon (🌼) - bottom right, with constraints
                if (isFertileWindow &&
                    date.isBefore(DateTime.now().add(const Duration(days: 1))))
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.3,
                        maxHeight: constraints.maxHeight * 0.3,
                      ),
                      child: Text(
                        '🌼',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.orange[400]?.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                // Mood indicator dot - bottom left
                if (moodColor != null)
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: moodColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                // Symptom indicator dot - center bottom (small indicator)
                if (hasSymptoms)
                  Positioned(
                    bottom: 2,
                    left: 10,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlowDrops(FlowIntensity flow) {
    String drops = '';
    switch (flow) {
      case FlowIntensity.light:
        drops = '💧';
        break;
      case FlowIntensity.moderate:
        drops = '💧💧';
        break;
      case FlowIntensity.heavy:
        drops = '💧💧💧';
        break;
    }

    return Text(
      drops,
      style: const TextStyle(fontSize: 8),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Légende',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Basic indicators
          Text(
            'Indicateurs de base',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('🌸', 'Règles enregistrées'),
              _buildLegendItem('🌸', 'Prédiction règles', isPredicted: true),
              _buildLegendItem('🌼', 'Fenêtre fertile'),
              _buildLegendItem('💧', 'Flux léger'),
              _buildLegendItem('💧💧', 'Flux moyen'),
              _buildLegendItem('💧💧💧', 'Flux abondant'),
            ],
          ),

          const SizedBox(height: 12),

          // Symptom indicators
          Text(
            'Symptômes',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildColorLegendItem(
                  AppColors.secondary, 'Jours avec symptômes'),
            ],
          ),

          const SizedBox(height: 12),

          // Mood indicators
          Text(
            'Humeurs',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('🟡', 'Humeur positive'),
              _buildLegendItem('🔵', 'Humeur calme'),
              _buildLegendItem('🟣', 'Humeur difficile'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String icon, String label,
      {bool isPredicted = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: TextStyle(
            fontSize: 12,
            color: isPredicted ? Colors.pink[300]?.withOpacity(0.6) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildColorLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  CycleDay? _getCycleDay(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return widget.cycleData[dateKey];
  }

  bool _isPredictedPeriodDay(DateTime date) {
    // Calculate predicted period based on average cycle length
    final lastPeriod = widget.lastPeriodStartDate;
    final cycleLength = widget.averageCycleLength;
    final periodLength = widget.averagePeriodLength;

    // Calculate next predicted period start
    final nextPeriodStart = lastPeriod.add(Duration(days: cycleLength));

    // Check if this date falls within the predicted period window
    final daysSinceLastPeriod = date.difference(lastPeriod).inDays;
    final cycleDay = daysSinceLastPeriod % cycleLength;

    // Return true if this is a predicted period day (within period length)
    return cycleDay >= 0 &&
        cycleDay < periodLength &&
        date.isAfter(DateTime.now());
  }

  bool _isFertileWindowDay(DateTime date) {
    // Fertile window is typically 5-6 days before ovulation
    // Ovulation usually occurs around day 14 of a 28-day cycle
    final lastPeriod = widget.lastPeriodStartDate;
    final cycleLength = widget.averageCycleLength;

    // Calculate ovulation day (typically 14 days before next period)
    final ovulationDay = cycleLength - 14;

    // Calculate fertile window (5 days before ovulation)
    final fertileStart = ovulationDay - 5;
    final fertileEnd = ovulationDay + 1;

    // Calculate current cycle day
    final daysSinceLastPeriod = date.difference(lastPeriod).inDays;
    final cycleDay = daysSinceLastPeriod % cycleLength;

    return cycleDay >= fertileStart && cycleDay <= fertileEnd;
  }

  Color? _getMoodColor(MoodType? mood) {
    if (mood == null) return null;

    switch (mood) {
      case MoodType.happy:
      case MoodType.confident:
        return Colors.yellow[600];
      case MoodType.calm:
        return Colors.blue[400];
      case MoodType.sad:
      case MoodType.anxious:
      case MoodType.irritable:
        return Colors.pink[400];
    }
  }
}
