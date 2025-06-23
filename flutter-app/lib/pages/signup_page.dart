import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../blocs/auth_bloc.dart';
import '../models/user.dart';
import '../models/signup_data.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/symptom_selector.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _periodLengthController = TextEditingController();

  // State variables
  int _currentStep = 0;
  final int _totalSteps = 6;
  bool _isLoading = false;
  File? _profileImage;
  DateTime? _lastPeriodDate;
  MenopausePhase _menopausePhase = MenopausePhase.pre;
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedConcerns = [];

  // Animation controllers
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Validation states
  bool _isPasswordStrong = false;
  bool _isEmailValid = false;
  String _passwordStrength = '';
  String _emailSuggestion = '';

  // Dynamic symptom suggestions based on phase
  final Map<MenopausePhase, List<String>> _symptomSuggestions = {
    MenopausePhase.pre: [
      'Irregular Periods',
      'Mood Swings',
      'Breast Tenderness',
      'Fatigue',
      'Weight Gain',
    ],
    MenopausePhase.peri: [
      'Hot Flashes',
      'Night Sweats',
      'Irregular Periods',
      'Mood Swings',
      'Sleep Issues',
      'Brain Fog',
      'Vaginal Dryness',
      'Decreased Libido',
    ],
    MenopausePhase.post: [
      'Hot Flashes',
      'Night Sweats',
      'Vaginal Dryness',
      'Bone Loss',
      'Heart Health',
      'Memory Issues',
      'Joint Pain',
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedProgress();
    _setupValidationListeners();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupValidationListeners() {
    _passwordController.addListener(_validatePassword);
    _emailController.addListener(_validateEmail);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    setState(() {
      _isPasswordStrong = strength >= 4;
      switch (strength) {
        case 0:
        case 1:
          _passwordStrength = 'Très faible';
          break;
        case 2:
          _passwordStrength = 'Faible';
          break;
        case 3:
          _passwordStrength = 'Moyen';
          break;
        case 4:
          _passwordStrength = 'Fort';
          break;
        case 5:
          _passwordStrength = 'Très fort';
          break;
      }
    });
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
      if (email.isNotEmpty && !_isEmailValid) {
        _emailSuggestion = 'Vérifiez le format de votre email';
      } else {
        _emailSuggestion = '';
      }
    });
  }

  Future<void> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStep = prefs.getInt('signup_step') ?? 0;
      final savedName = prefs.getString('signup_name') ?? '';
      final savedEmail = prefs.getString('signup_email') ?? '';
      final savedPhase = prefs.getString('signup_phase') ?? 'pre';

      setState(() {
        _currentStep = savedStep;
        _nameController.text = savedName;
        _emailController.text = savedEmail;
        _menopausePhase = MenopausePhase.values.firstWhere(
          (e) => e.toString().split('.').last == savedPhase,
          orElse: () => MenopausePhase.pre,
        );
      });

      if (savedStep > 0) {
        _pageController.jumpToPage(savedStep);
        _updateProgress();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('signup_step', _currentStep);
      await prefs.setString('signup_name', _nameController.text);
      await prefs.setString('signup_email', _emailController.text);
      await prefs.setString(
          'signup_phase', _menopausePhase.toString().split('.').last);
    } catch (e) {
      // Handle error silently
    }
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _totalSteps);
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
      _updateProgress();
      _saveProgress();
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
      _updateProgress();
      _saveProgress();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Impossible de sélectionner l\'image. Réessayez.');
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Prendre une photo', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title:
                  Text('Choisir depuis la galerie', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setState(() {
            _isLoading = false;
          });
          _showError(state.message);
        } else if (state is Authenticated) {
          setState(() {
            _isLoading = false;
          });
          // Navigation vers la page d'accueil après inscription réussie
          Navigator.of(context).pushReplacementNamed('/home');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isTablet),
                _buildProgressIndicator(isTablet),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPersonalInfoStep(isTablet),
                      _buildMenopausePhaseStep(isTablet),
                      _buildSymptomsStep(isTablet),
                      _buildCycleInfoStep(isTablet),
                      _buildConcernsStep(isTablet),
                      _buildFinalChecklistStep(isTablet),
                    ],
                  ),
                ),
                _buildNavigationButtons(isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créer votre compte',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Étape ${_currentStep + 1} sur $_totalSteps',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 24.0),
      child: Column(
        children: [
          // Progress bar
          Container(
            height: isTablet ? 8 : 6,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(isTablet ? 4 : 3),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.softPinkGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 4 : 3),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = index;
                  });
                  _pageController.jumpToPage(index);
                  _updateProgress();
                },
                child: Container(
                  width: isTablet ? 40 : 32,
                  height: isTablet ? 40 : 32,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.border,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations personnelles',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commençons par vos informations de base',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Profile image
          Center(
            child: GestureDetector(
              onTap: _showImagePickerDialog,
              child: Container(
                width: isTablet ? 120 : 100,
                height: isTablet ? 120 : 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: isTablet ? 32 : 28,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ajouter une photo',
                            style: GoogleFonts.inter(
                              fontSize: isTablet ? 12 : 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Form fields
          CustomTextField(
            controller: _nameController,
            labelText: 'Nom complet',
            hintText: 'Entrez votre nom complet',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          CustomTextField(
            controller: _emailController,
            labelText: 'Adresse email',
            hintText: 'Entrez votre adresse email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!_isEmailValid) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          if (_emailSuggestion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _emailSuggestion,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 24),

          CustomTextField(
            controller: _passwordController,
            labelText: 'Mot de passe',
            hintText: 'Créez un mot de passe sécurisé',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              if (!_isPasswordStrong) {
                return 'Le mot de passe doit être plus fort';
              }
              return null;
            },
          ),
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isPasswordStrong ? Icons.check_circle : Icons.info,
                  size: 16,
                  color:
                      _isPasswordStrong ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Force du mot de passe: $_passwordStrength',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _isPasswordStrong
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenopausePhaseStep(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phase de ménopause',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette information nous aide à personnaliser votre expérience',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Help tooltip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La ménopause se déroule en 3 phases. Choisissez celle qui correspond le mieux à votre situation actuelle.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Phase options
          ...MenopausePhase.values.map((phase) {
            final isSelected = _menopausePhase == phase;
            final phaseInfo = _getPhaseInfo(phase);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _menopausePhase = phase;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Radio<MenopausePhase>(
                      value: phase,
                      groupValue: _menopausePhase,
                      onChanged: (value) {
                        setState(() {
                          _menopausePhase = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phaseInfo['title'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phaseInfo['description'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSymptomsStep(bool isTablet) {
    final suggestedSymptoms = _symptomSuggestions[_menopausePhase] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptômes',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez les symptômes que vous ressentez actuellement',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Suggested symptoms
          if (suggestedSymptoms.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.lavenderGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Symptômes courants pour votre phase',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestedSymptoms.map((symptom) {
                      final isSelected = _selectedSymptoms.contains(symptom);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedSymptoms.remove(symptom);
                            } else {
                              _selectedSymptoms.add(symptom);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            symptom,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // All symptoms
          Text(
            'Tous les symptômes',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          SymptomSelector(
            selectedSymptoms: _selectedSymptoms,
            onSymptomsChanged: (symptoms) {
              setState(() {
                _selectedSymptoms.clear();
                _selectedSymptoms.addAll(symptoms);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfoStep(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations sur le cycle',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ces informations nous aident à mieux comprendre votre situation',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Help tooltip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Si vos cycles sont irréguliers, utilisez une moyenne approximative.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          CustomTextField(
            controller: _cycleLengthController,
            labelText: 'Longueur moyenne du cycle (jours)',
            hintText: 'Ex: 28',
            prefixIcon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la longueur de votre cycle';
              }
              final cycleLength = int.tryParse(value);
              if (cycleLength == null || cycleLength < 21 || cycleLength > 35) {
                return 'La longueur du cycle doit être entre 21 et 35 jours';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          CustomTextField(
            controller: _periodLengthController,
            labelText: 'Durée moyenne des règles (jours)',
            hintText: 'Ex: 5',
            prefixIcon: Icons.water_drop,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la durée de vos règles';
              }
              final periodLength = int.tryParse(value);
              if (periodLength == null ||
                  periodLength < 2 ||
                  periodLength > 10) {
                return 'La durée des règles doit être entre 2 et 10 jours';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Last period date
          Text(
            'Date de début de vos dernières règles',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _lastPeriodDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _lastPeriodDate != null
                        ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'
                        : 'Sélectionner une date',
                    style: GoogleFonts.inter(
                      fontSize: 16,
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
    );
  }

  Widget _buildConcernsStep(bool isTablet) {
    final concerns = [
      'Gestion du stress',
      'Qualité du sommeil',
      'Équilibre hormonal',
      'Santé cardiovasculaire',
      'Santé osseuse',
      'Bien-être émotionnel',
      'Relations et intimité',
      'Nutrition et poids',
      'Activité physique',
      'Soutien communautaire',
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Préoccupations principales',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez vos principales préoccupations pour personnaliser votre expérience',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: concerns.map((concern) {
              final isSelected = _selectedConcerns.contains(concern);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedConcerns.remove(concern);
                    } else {
                      _selectedConcerns.add(concern);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    concern,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalChecklistStep(bool isTablet) {
    final checklistItems = [
      {
        'title': 'Informations personnelles',
        'completed': _nameController.text.isNotEmpty &&
            _isEmailValid &&
            _isPasswordStrong,
        'icon': Icons.person,
      },
      {
        'title': 'Phase de ménopause',
        'completed': _menopausePhase != MenopausePhase.pre,
        'icon': Icons.psychology,
      },
      {
        'title': 'Symptômes sélectionnés',
        'completed': _selectedSymptoms.isNotEmpty,
        'icon': Icons.medical_services,
      },
      {
        'title': 'Informations sur le cycle',
        'completed': _cycleLengthController.text.isNotEmpty &&
            _periodLengthController.text.isNotEmpty &&
            _lastPeriodDate != null,
        'icon': Icons.calendar_today,
      },
      {
        'title': 'Préoccupations principales',
        'completed': _selectedConcerns.isNotEmpty,
        'icon': Icons.favorite,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez que toutes les informations sont correctes',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Checklist
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: checklistItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item['completed'] as bool
                              ? AppColors.success
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item['completed'] as bool
                              ? Icons.check
                              : item['icon'] as IconData,
                          color: item['completed'] as bool
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!(item['completed'] as bool))
                        Text(
                          'À compléter',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.softPinkGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Résumé de votre profil',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryItem('Nom', _nameController.text),
                _buildSummaryItem('Email', _emailController.text),
                _buildSummaryItem(
                    'Phase', _getPhaseInfo(_menopausePhase)['title'] ?? ''),
                _buildSummaryItem(
                    'Symptômes', '${_selectedSymptoms.length} sélectionnés'),
                _buildSummaryItem('Préoccupations',
                    '${_selectedConcerns.length} sélectionnées'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                ),
                child: Text(
                  'Précédent',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_currentStep < _totalSteps - 1) {
                        _nextStep();
                      } else {
                        _handleSignup();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep < _totalSteps - 1
                          ? 'Suivant'
                          : 'Créer le compte',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getPhaseInfo(MenopausePhase phase) {
    switch (phase) {
      case MenopausePhase.pre:
        return {
          'title': 'Pré-ménopause',
          'description':
              'Périodes régulières, généralement dans la quarantaine',
        };
      case MenopausePhase.peri:
        return {
          'title': 'Péri-ménopause',
          'description': 'Périodes irrégulières, symptômes apparaissent',
        };
      case MenopausePhase.post:
        return {
          'title': 'Post-ménopause',
          'description': 'Aucune période depuis 12+ mois',
        };
    }
  }

  void _handleSignup() {
    print('=== DEBUG: Début de _handleSignup ===');
    print('_lastPeriodDate: $_lastPeriodDate');
    print('_nameController.text: "${_nameController.text}"');
    print('_emailController.text: "${_emailController.text}"');
    print('_passwordController.text: "${_passwordController.text}"');
    print('_cycleLengthController.text: "${_cycleLengthController.text}"');
    print('_periodLengthController.text: "${_periodLengthController.text}"');
    print('_menopausePhase: $_menopausePhase');
    print('_selectedSymptoms: $_selectedSymptoms');
    print('_selectedConcerns: $_selectedConcerns');

    // Vérifications préliminaires
    if (_nameController.text.trim().isEmpty) {
      _showError('Le nom est requis');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('L\'email est requis');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Le mot de passe est requis');
      return;
    }

    if (_cycleLengthController.text.isEmpty) {
      _showError('La durée moyenne du cycle est requise');
      return;
    }

    if (_periodLengthController.text.isEmpty) {
      _showError('La durée moyenne des règles est requise');
      return;
    }

    if (_lastPeriodDate == null) {
      _showError('Veuillez sélectionner la date de vos dernières règles');
      return;
    }

    if (_selectedSymptoms.isEmpty) {
      _showError('Veuillez sélectionner au moins un symptôme');
      return;
    }

    if (_selectedConcerns.isEmpty) {
      _showError('Veuillez sélectionner au moins une préoccupation');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Convert all data to proper types before creating SignupData
      final cycleLength = int.tryParse(_cycleLengthController.text) ?? 0;
      final periodLength = int.tryParse(_periodLengthController.text) ?? 0;

      // Créer l'objet SignupData avec vérifications
      final signupData = SignupData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        averageCycleLength: cycleLength,
        averagePeriodLength: periodLength,
        lastPeriodStartDate: _lastPeriodDate!,
        menopausePhase: _menopausePhase,
        selectedSymptoms: List<String>.from(_selectedSymptoms),
        selectedConcerns: List<String>.from(_selectedConcerns),
        profileImage: _profileImage,
      );

      print('=== DEBUG: SignupData créé avec succès ===');

      // Valider les données avant l'envoi
      if (!signupData.isValid()) {
        final errors = signupData.getValidationErrors();
        _showError('Erreurs de validation: ${errors.join(', ')}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('=== DEBUG: Envoi de SignupRequested ===');
      context.read<AuthBloc>().add(
            SignupRequested(signupData: signupData),
          );
    } catch (e) {
      print('=== DEBUG: Erreur dans _handleSignup: $e ===');
      _showError('Erreur lors de la création du compte: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
