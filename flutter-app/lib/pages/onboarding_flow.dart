import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../blocs/onboarding_bloc.dart';
import '../constants/app_colors.dart';
import '../models/user.dart';
import '../utils/responsive.dart';
import '../widgets/animated_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/symptom_selector.dart';
import 'home_page.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final OnboardingBloc _onboardingBloc = OnboardingBloc();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();
  final TextEditingController _periodLengthController = TextEditingController();

  // Form data
  DateTime? _lastPeriodDate;
  List<UserGoal> _selectedGoals = [];
  List<String> _selectedSymptoms = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Create user with onboarding data
    final user = User(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      email: 'user@example.com', // This would come from auth
      menopausePhase: MenopausePhase.peri, // Default value
      symptoms: _selectedSymptoms,
      concerns: _selectedGoals
          .map((goal) => goal.toString().split('.').last)
          .toList(), // Convert enum to strings
      lastPeriodStartDate: _lastPeriodDate ?? DateTime.now(),
      averageCycleLength: int.tryParse(_cycleLengthController.text) ?? 28,
      averagePeriodLength: int.tryParse(_periodLengthController.text) ?? 5,
      estimatedByAI: false,
      completedCycles: 0,
      onboarding: {
        'currentStep': 'completed',
        'completed': true,
      },
    );

    // Navigate to home page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomeStep(),
                    _buildGoalsStep(),
                    _buildCycleInputStep(),
                    _buildSymptomsStep(),
                    _buildAccountSetupStep(),
                  ],
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 16, tablet: 24, desktop: 32)),
      child: Column(
        children: [
          // Progress bar
          Container(
            height: Responsive.scale(context, 4, tablet: 6, desktop: 8),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(
                  Responsive.scale(context, 2, tablet: 3, desktop: 4)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / _totalSteps,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.softPinkGradient,
                  borderRadius: BorderRadius.circular(
                      Responsive.scale(context, 2, tablet: 3, desktop: 4)),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),

          const SizedBox(height: 16),

          // Step indicator
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 14, tablet: 16, desktop: 18),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 24, tablet: 32, desktop: 40)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome icon
          Container(
            width: Responsive.scale(context, 120, tablet: 160, desktop: 200),
            height: Responsive.scale(context, 120, tablet: 160, desktop: 200),
            decoration: BoxDecoration(
              gradient: AppColors.lavenderGradient,
              borderRadius: BorderRadius.circular(
                  Responsive.scale(context, 60, tablet: 80, desktop: 100)),
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: Responsive.scale(context, 60, tablet: 80, desktop: 100),
              color: Colors.white,
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

          SizedBox(
              height: Responsive.scale(context, 32, tablet: 40, desktop: 48)),

          // Welcome text
          Text(
            'Welcome to Your\nMenopause Journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 28, tablet: 36, desktop: 44),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

          SizedBox(
              height: Responsive.scale(context, 16, tablet: 20, desktop: 24)),

          Text(
            'Let\'s personalize your experience to help you navigate this important phase of life with confidence and support.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 16, tablet: 18, desktop: 20),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

          SizedBox(
              height: Responsive.scale(context, 48, tablet: 56, desktop: 64)),

          // Features preview
          _buildFeaturesPreview(),
        ],
      ),
    );
  }

  Widget _buildFeaturesPreview() {
    final features = [
      {
        'icon': Icons.track_changes_rounded,
        'title': 'Symptom Tracking',
        'desc': 'Monitor your daily symptoms'
      },
      {
        'icon': Icons.psychology_rounded,
        'title': 'AI Wellness Coach',
        'desc': 'Get personalized guidance'
      },
      {
        'icon': Icons.calendar_today_rounded,
        'title': 'Cycle Insights',
        'desc': 'Understand your patterns'
      },
      {
        'icon': Icons.people_rounded,
        'title': 'Community Support',
        'desc': 'Connect with others'
      },
    ];

    return Column(
      children: features.map((feature) {
        return AnimatedCard(
          child: Container(
            padding: EdgeInsets.all(
                Responsive.scale(context, 16, tablet: 20, desktop: 24)),
            child: Row(
              children: [
                Container(
                  width: Responsive.scale(context, 48, tablet: 56, desktop: 64),
                  height:
                      Responsive.scale(context, 48, tablet: 56, desktop: 64),
                  decoration: BoxDecoration(
                    gradient: AppColors.softPinkGradient,
                    borderRadius: BorderRadius.circular(
                        Responsive.scale(context, 12, tablet: 16, desktop: 20)),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: Colors.white,
                    size:
                        Responsive.scale(context, 24, tablet: 28, desktop: 32),
                  ),
                ),
                SizedBox(
                    width:
                        Responsive.scale(context, 16, tablet: 20, desktop: 24)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: Responsive.scale(context, 16,
                              tablet: 18, desktop: 20),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        feature['desc'] as String,
                        style: GoogleFonts.inter(
                          fontSize: Responsive.scale(context, 14,
                              tablet: 16, desktop: 18),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (800 + features.indexOf(feature) * 200).ms)
            .slideX(begin: 0.3);
      }).toList(),
    );
  }

  Widget _buildGoalsStep() {
    final goals = UserGoal.values;

    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 24, tablet: 32, desktop: 40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your main goals?',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 24, tablet: 28, desktop: 32),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 8, tablet: 12, desktop: 16)),
          Text(
            'Select all that apply to help us personalize your experience',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 16, tablet: 18, desktop: 20),
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 32, tablet: 40, desktop: 48)),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.isTablet(context) ? 2 : 1,
                childAspectRatio: 3,
                crossAxisSpacing:
                    Responsive.scale(context, 16, tablet: 20, desktop: 24),
                mainAxisSpacing:
                    Responsive.scale(context, 16, tablet: 20, desktop: 24),
              ),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final isSelected = _selectedGoals.contains(goal);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(goal);
                      } else {
                        _selectedGoals.add(goal);
                      }
                    });
                  },
                  child: AnimatedCard(
                    child: Container(
                      padding: EdgeInsets.all(Responsive.scale(context, 16,
                          tablet: 20, desktop: 24)),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected ? AppColors.lavenderGradient : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(Responsive.scale(
                            context, 16,
                            tablet: 20, desktop: 24)),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getGoalIcon(goal),
                            color:
                                isSelected ? Colors.white : AppColors.primary,
                            size: Responsive.scale(context, 24,
                                tablet: 28, desktop: 32),
                          ),
                          SizedBox(
                              width: Responsive.scale(context, 16,
                                  tablet: 20, desktop: 24)),
                          Expanded(
                            child: Text(
                              _getGoalTitle(goal),
                              style: GoogleFonts.inter(
                                fontSize: Responsive.scale(context, 16,
                                    tablet: 18, desktop: 20),
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: Responsive.scale(context, 20,
                                  tablet: 24, desktop: 28),
                            ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideX(begin: 0.3),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInputStep() {
    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 24, tablet: 32, desktop: 40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your cycle',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 24, tablet: 28, desktop: 32),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 8, tablet: 12, desktop: 16)),
          Text(
            'This helps us provide more accurate predictions and insights',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 16, tablet: 18, desktop: 20),
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 32, tablet: 40, desktop: 48)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Cycle length input
                  AnimatedCard(
                    child: Container(
                      padding: EdgeInsets.all(Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: Responsive.scale(context, 48,
                                    tablet: 56, desktop: 64),
                                height: Responsive.scale(context, 48,
                                    tablet: 56, desktop: 64),
                                decoration: BoxDecoration(
                                  gradient: AppColors.blueGradient,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.scale(context, 12,
                                          tablet: 16, desktop: 20)),
                                ),
                                child: Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.white,
                                  size: Responsive.scale(context, 24,
                                      tablet: 28, desktop: 32),
                                ),
                              ),
                              SizedBox(
                                  width: Responsive.scale(context, 16,
                                      tablet: 20, desktop: 24)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Average Cycle Length',
                                      style: GoogleFonts.inter(
                                        fontSize: Responsive.scale(context, 18,
                                            tablet: 20, desktop: 22),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'How many days between periods?',
                                      style: GoogleFonts.inter(
                                        fontSize: Responsive.scale(context, 14,
                                            tablet: 16, desktop: 18),
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: Responsive.scale(context, 24,
                                  tablet: 32, desktop: 40)),
                          CustomTextField(
                            controller: _cycleLengthController,
                            hintText: 'e.g., 28',
                            keyboardType: TextInputType.number,
                            labelText: 'Cycle Length',
                            prefixIcon: Icons.calendar_today_rounded,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3),

                  SizedBox(
                      height: Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),

                  // Period length input
                  AnimatedCard(
                    child: Container(
                      padding: EdgeInsets.all(Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: Responsive.scale(context, 48,
                                    tablet: 56, desktop: 64),
                                height: Responsive.scale(context, 48,
                                    tablet: 56, desktop: 64),
                                decoration: BoxDecoration(
                                  gradient: AppColors.hotFlashGradient,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.scale(context, 12,
                                          tablet: 16, desktop: 20)),
                                ),
                                child: Icon(
                                  Icons.water_drop_rounded,
                                  color: Colors.white,
                                  size: Responsive.scale(context, 24,
                                      tablet: 28, desktop: 32),
                                ),
                              ),
                              SizedBox(
                                  width: Responsive.scale(context, 16,
                                      tablet: 20, desktop: 24)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Average Period Length',
                                      style: GoogleFonts.inter(
                                        fontSize: Responsive.scale(context, 18,
                                            tablet: 20, desktop: 22),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'How many days does your period last?',
                                      style: GoogleFonts.inter(
                                        fontSize: Responsive.scale(context, 14,
                                            tablet: 16, desktop: 18),
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: Responsive.scale(context, 24,
                                  tablet: 32, desktop: 40)),
                          CustomTextField(
                            controller: _periodLengthController,
                            hintText: 'e.g., 5',
                            keyboardType: TextInputType.number,
                            labelText: 'Period Length',
                            prefixIcon: Icons.water_drop_rounded,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3),

                  SizedBox(
                      height: Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),

                  // Last period date
                  AnimatedCard(
                    child: Container(
                      padding: EdgeInsets.all(Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: Responsive.scale(context, 48,
                                    tablet: 56, desktop: 64),
                                height: Responsive.scale(context, 48,
                                    tablet: 56, desktop: 64),
                                decoration: BoxDecoration(
                                  gradient: AppColors.moodGradient,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.scale(context, 12,
                                          tablet: 16, desktop: 20)),
                                ),
                                child: Icon(
                                  Icons.event_rounded,
                                  color: Colors.white,
                                  size: Responsive.scale(context, 24,
                                      tablet: 28, desktop: 32),
                                ),
                              ),
                              SizedBox(
                                  width: Responsive.scale(context, 16,
                                      tablet: 20, desktop: 24)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last Period Start Date',
                                      style: GoogleFonts.inter(
                                        fontSize: Responsive.scale(context, 18,
                                            tablet: 20, desktop: 22),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'When did your last period begin?',
                                      style: GoogleFonts.inter(
                                        fontSize: Responsive.scale(context, 14,
                                            tablet: 16, desktop: 18),
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: Responsive.scale(context, 24,
                                  tablet: 32, desktop: 40)),
                          GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _lastPeriodDate ?? DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setState(() {
                                  _lastPeriodDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(Responsive.scale(
                                  context, 16,
                                  tablet: 20, desktop: 24)),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(
                                    Responsive.scale(context, 12,
                                        tablet: 16, desktop: 20)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppColors.primary,
                                    size: Responsive.scale(context, 20,
                                        tablet: 24, desktop: 28),
                                  ),
                                  SizedBox(
                                      width: Responsive.scale(context, 12,
                                          tablet: 16, desktop: 20)),
                                  Text(
                                    _lastPeriodDate != null
                                        ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'
                                        : 'Select date',
                                    style: GoogleFonts.inter(
                                      fontSize: Responsive.scale(context, 16,
                                          tablet: 18, desktop: 20),
                                      color: _lastPeriodDate != null
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsStep() {
    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 24, tablet: 32, desktop: 40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which symptoms do you experience?',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 24, tablet: 28, desktop: 32),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 8, tablet: 12, desktop: 16)),
          Text(
            'Select the symptoms you commonly experience to help us provide relevant insights',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 16, tablet: 18, desktop: 20),
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 32, tablet: 40, desktop: 48)),
          Expanded(
            child: SymptomSelector(
              selectedSymptoms: _selectedSymptoms,
              onSymptomsChanged: (symptoms) {
                setState(() {
                  _selectedSymptoms = symptoms;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSetupStep() {
    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 24, tablet: 32, desktop: 40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Almost done!',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 24, tablet: 28, desktop: 32),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 8, tablet: 12, desktop: 16)),
          Text(
            'Let\'s set up your account to personalize your experience',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 16, tablet: 18, desktop: 20),
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
          SizedBox(
              height: Responsive.scale(context, 32, tablet: 40, desktop: 48)),
          Expanded(
            child: Column(
              children: [
                AnimatedCard(
                  child: Container(
                    padding: EdgeInsets.all(
                        Responsive.scale(context, 24, tablet: 32, desktop: 40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: Responsive.scale(context, 48,
                                  tablet: 56, desktop: 64),
                              height: Responsive.scale(context, 48,
                                  tablet: 56, desktop: 64),
                              decoration: BoxDecoration(
                                gradient: AppColors.pinkLavenderGradient,
                                borderRadius: BorderRadius.circular(
                                    Responsive.scale(context, 12,
                                        tablet: 16, desktop: 20)),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: Responsive.scale(context, 24,
                                    tablet: 28, desktop: 32),
                              ),
                            ),
                            SizedBox(
                                width: Responsive.scale(context, 16,
                                    tablet: 20, desktop: 24)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Name',
                                    style: GoogleFonts.inter(
                                      fontSize: Responsive.scale(context, 18,
                                          tablet: 20, desktop: 22),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'How should we address you?',
                                    style: GoogleFonts.inter(
                                      fontSize: Responsive.scale(context, 14,
                                          tablet: 16, desktop: 18),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: Responsive.scale(context, 24,
                                tablet: 32, desktop: 40)),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Enter your name',
                          labelText: 'Your Name',
                          prefixIcon: Icons.person_rounded,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3),

                SizedBox(
                    height:
                        Responsive.scale(context, 32, tablet: 40, desktop: 48)),

                // Summary card
                AnimatedCard(
                  child: Container(
                    padding: EdgeInsets.all(
                        Responsive.scale(context, 24, tablet: 32, desktop: 40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Profile Summary',
                          style: GoogleFonts.inter(
                            fontSize: Responsive.scale(context, 18,
                                tablet: 20, desktop: 22),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(
                            height: Responsive.scale(context, 16,
                                tablet: 20, desktop: 24)),
                        _buildSummaryItem(
                            'Goals', _selectedGoals.length.toString()),
                        _buildSummaryItem(
                            'Symptoms', _selectedSymptoms.length.toString()),
                        if (_cycleLengthController.text.isNotEmpty)
                          _buildSummaryItem('Cycle Length',
                              '${_cycleLengthController.text} days'),
                        if (_periodLengthController.text.isNotEmpty)
                          _buildSummaryItem('Period Length',
                              '${_periodLengthController.text} days'),
                        if (_lastPeriodDate != null)
                          _buildSummaryItem('Last Period',
                              '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: Responsive.scale(context, 8, tablet: 12, desktop: 16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 14, tablet: 16, desktop: 18),
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 14, tablet: 16, desktop: 18),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 24, tablet: 32, desktop: 40)),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    vertical:
                        Responsive.scale(context, 16, tablet: 20, desktop: 24),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        Responsive.scale(context, 12, tablet: 16, desktop: 20)),
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.inter(
                    fontSize:
                        Responsive.scale(context, 16, tablet: 18, desktop: 20),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0)
            SizedBox(
                width: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  vertical:
                      Responsive.scale(context, 16, tablet: 20, desktop: 24),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      Responsive.scale(context, 12, tablet: 16, desktop: 20)),
                ),
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? 'Get Started' : 'Continue',
                style: GoogleFonts.inter(
                  fontSize:
                      Responsive.scale(context, 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Welcome
        return true;
      case 1: // Goals
        return _selectedGoals.isNotEmpty;
      case 2: // Cycle Input
        return _cycleLengthController.text.isNotEmpty &&
            _periodLengthController.text.isNotEmpty &&
            _lastPeriodDate != null;
      case 3: // Symptoms
        return true; // Optional step
      case 4: // Account Setup
        return _nameController.text.isNotEmpty;
      default:
        return false;
    }
  }

  IconData _getGoalIcon(UserGoal goal) {
    switch (goal) {
      case UserGoal.symptomTracking:
        return Icons.track_changes_rounded;
      case UserGoal.cycleUnderstanding:
        return Icons.calendar_today_rounded;
      case UserGoal.lifestyleImprovement:
        return Icons.fitness_center_rounded;
      case UserGoal.medicalSupport:
        return Icons.medical_services_rounded;
      case UserGoal.communitySupport:
        return Icons.people_rounded;
      case UserGoal.stressManagement:
        return Icons.self_improvement_rounded;
    }
  }

  String _getGoalTitle(UserGoal goal) {
    switch (goal) {
      case UserGoal.symptomTracking:
        return 'Track Symptoms';
      case UserGoal.cycleUnderstanding:
        return 'Understand My Cycle';
      case UserGoal.lifestyleImprovement:
        return 'Improve Lifestyle';
      case UserGoal.medicalSupport:
        return 'Get Medical Support';
      case UserGoal.communitySupport:
        return 'Join Community';
      case UserGoal.stressManagement:
        return 'Manage Stress';
    }
  }
}
