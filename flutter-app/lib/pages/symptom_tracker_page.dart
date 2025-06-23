import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/symptom_tracker_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../models/user.dart';
import '../constants/app_colors.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/cycle_calendar.dart';
import '../widgets/modern_save_button.dart';
import '../utils/responsive.dart';

class WelcomeMessage {
  final String emoji;
  final String message;

  const WelcomeMessage({
    required this.emoji,
    required this.message,
  });
}

class SymptomTrackerPage extends StatefulWidget {
  const SymptomTrackerPage({super.key});

  @override
  State<SymptomTrackerPage> createState() => _SymptomTrackerPageState();
}

class _SymptomTrackerPageState extends State<SymptomTrackerPage> {
  DateTime _selectedDate = DateTime.now();
  CycleDay? _selectedCycleDay;

  FlowIntensity? _selectedFlow;
  MoodType? _selectedMood;
  final List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();

  // New state variables for UX improvements
  bool _showConfirmation = false;
  bool _hasUnsavedChanges = false;
  bool _showSymptomConfig = false;
  String? _validationError;

  // Predefined symptoms list for quick configuration
  final List<String> _predefinedSymptoms = [
    'maux de tête',
    'nausée',
    'ballonnements',
    'douleur au bas-ventre',
    'fatigue',
    'bouffées de chaleur',
    'crampes',
    'douleurs lombaires',
    'irritabilité',
    'anxiété',
    'dépression',
    'insomnie',
    'sueurs nocturnes',
    'sécheresse vaginale',
    'gain de poids',
    'perte de libido',
    'migraine',
    'vertiges',
    'palpitations',
    'douleurs articulaires',
    'sécheresse cutanée',
    'changements d\'humeur',
    'difficultés de concentration',
    'troubles du sommeil',
    'bouffées de chaleur nocturnes',
    'sécheresse oculaire',
    'douleurs mammaires',
    'saignements irréguliers',
    'pertes vaginales',
  ];

  // Helper methods for safe data access
  String _safeGetUserName(User? user) {
    if (user == null || user.name.isEmpty) return 'Utilisateur';
    return user.name;
  }

  int _safeGetCycleLength(User? user) {
    if (user == null) return 28;
    return user.averageCycleLength;
  }

  int _safeGetPeriodLength(User? user) {
    if (user == null) return 5;
    return user.averagePeriodLength;
  }

  DateTime _safeGetLastPeriodDate(User? user) {
    if (user == null || user.lastPeriodStartDate == null) {
      return DateTime.now().subtract(const Duration(days: 28));
    }
    return user.lastPeriodStartDate;
  }

  Map<String, CycleDay> _safeGetCycleData(User? user) {
    if (user == null) return {};
    return user.cycleData;
  }

  List<String> _safeGetSymptoms(User? user) {
    if (user == null || user.symptoms.isEmpty) {
      return _predefinedSymptoms.take(10).toList(); // Default symptoms
    }
    return user.symptoms;
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentMonthData();
  }

  void _loadCurrentMonthData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

      context.read<SymptomTrackerBloc>().add(LoadCycleData(
            uid: authState.firebaseUser.uid,
            startDate: startDate,
            endDate: endDate,
          ));
    }
  }

  // New validation method
  String? _validateData() {
    // Check if date is in the future
    if (_selectedDate.isAfter(DateTime.now())) {
      return 'Vous ne pouvez pas enregistrer des données pour une date future';
    }

    // Check if flow is selected but no symptoms
    if (_selectedFlow != null && _selectedSymptoms.isEmpty) {
      return 'Veuillez sélectionner au moins un symptôme si vous avez un flux menstruel';
    }

    // Check for conflicting mood and symptoms
    if (_selectedMood == MoodType.happy &&
        _selectedSymptoms.contains('dépression')) {
      return 'Humeur "Heureuse" incompatible avec le symptôme "Dépression"';
    }

    return null;
  }

  // New method to show confirmation dialog
  void _showSaveConfirmation() {
    // Validate data before showing confirmation
    final validationError = _validateData();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  validationError,
                  maxLines: 3,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.save, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Confirmer l\'enregistrement'),
            ],
          ),
          content: Text(
              'Voulez-vous enregistrer vos données pour le ${DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate)} ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _hasUnsavedChanges = false;
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveDailyLog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Updated save method
  void _saveDailyLog() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      // Validate data before saving
      final validationError = _validateData();
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    validationError,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Enregistrement en cours...',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      context.read<SymptomTrackerBloc>().add(SaveCycleDay(
            uid: authState.firebaseUser.uid,
            date: _selectedDate,
            flow: _selectedFlow,
            mood: _selectedMood,
            symptoms: _selectedSymptoms,
            notes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          ));

      // Reset unsaved changes flag
      _hasUnsavedChanges = false;
    }
  }

  // Method to refresh calendar data after changes
  void _refreshCalendarData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

      context.read<SymptomTrackerBloc>().add(LoadCycleData(
            uid: authState.firebaseUser.uid,
            startDate: startDate,
            endDate: endDate,
          ));
    }
  }

  // Method to force calendar update
  void _forceCalendarUpdate() {
    setState(() {
      // Force rebuild of the calendar widget
    });
  }

  // New method to show success message
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Données enregistrées avec succès !',
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // New method to handle unsaved changes
  Future<bool> _handleUnsavedChanges() async {
    if (_hasUnsavedChanges) {
      return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Modifications non sauvegardées'),
                content: Text(
                    'Vous avez des modifications non sauvegardées. Voulez-vous vraiment quitter ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Quitter'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleUnsavedChanges,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Suivi des Symptômes',
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.scale(context, 20, tablet: 22, desktop: 24),
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () async {
              if (await _handleUnsavedChanges()) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: Icon(Icons.save, color: AppColors.primary),
                onPressed: _showSaveConfirmation,
                tooltip: 'Sauvegarder les modifications',
              ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocListener<SymptomTrackerBloc, SymptomTrackerState>(
                listener: (context, state) {
                  if (state is SymptomTrackerLoaded && !state.isSaving) {
                    // Check if we just finished saving
                    if (_hasUnsavedChanges == false &&
                        _selectedCycleDay != null) {
                      _showSuccessMessage();
                      _validationError = null;

                      // Refresh calendar data to show updated symptoms
                      _refreshCalendarData();
                    }
                  } else if (state is SymptomTrackerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Erreur: ${state.message}'),
                          ],
                        ),
                        backgroundColor: AppColors.error,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                },
                child: BlocBuilder<SymptomTrackerBloc, SymptomTrackerState>(
                  builder: (context, state) {
                    if (state is SymptomTrackerLoading) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (state is SymptomTrackerLoaded) {
                      return _buildContent(state, authState.userProfile);
                    } else if (state is SymptomTrackerError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCurrentMonthData,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            }
            return const Center(
              child: Text('Veuillez vous connecter'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(SymptomTrackerLoaded state, User user) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(state, user),
      tablet: _buildTabletLayout(state, user),
      desktop: _buildDesktopLayout(state, user),
    );
  }

  Widget _buildMobileLayout(SymptomTrackerLoaded state, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWelcomeSection(user),
          const SizedBox(height: 20),
          _buildCalendarInfoSection(),
          CycleCalendar(
            cycleData: _safeGetCycleData(user),
            lastPeriodStartDate: _safeGetLastPeriodDate(user),
            averageCycleLength: _safeGetCycleLength(user),
            averagePeriodLength: _safeGetPeriodLength(user),
            onDaySelected: _onDaySelected,
            selectedDate: _selectedDate,
          ),
          const SizedBox(height: 20),
          _buildDailyLogForm(state, user),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(SymptomTrackerLoaded state, User user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildWelcomeSection(user),
                const SizedBox(height: 20),
                _buildCalendarInfoSection(),
                CycleCalendar(
                  cycleData: _safeGetCycleData(user),
                  lastPeriodStartDate: _safeGetLastPeriodDate(user),
                  averageCycleLength: _safeGetCycleLength(user),
                  averagePeriodLength: _safeGetPeriodLength(user),
                  onDaySelected: _onDaySelected,
                  selectedDate: _selectedDate,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: _buildDailyLogForm(state, user),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(SymptomTrackerLoaded state, User user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildWelcomeSection(user),
                const SizedBox(height: 24),
                _buildCalendarInfoSection(),
                CycleCalendar(
                  cycleData: _safeGetCycleData(user),
                  lastPeriodStartDate: _safeGetLastPeriodDate(user),
                  averageCycleLength: _safeGetCycleLength(user),
                  averagePeriodLength: _safeGetPeriodLength(user),
                  onDaySelected: _onDaySelected,
                  selectedDate: _selectedDate,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: _buildDailyLogForm(state, user),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(User user) {
    final hour = DateTime.now().hour;
    final welcomeMessage = _getWelcomeMessage(hour);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                welcomeMessage.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_safeGetUserName(user)}',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            welcomeMessage.message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.3,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  WelcomeMessage _getWelcomeMessage(int hour) {
    if (hour >= 5 && hour < 11) {
      return WelcomeMessage(
        emoji: '☀️',
        message: 'Commencez votre journée en douceur.',
      );
    } else if (hour >= 11 && hour < 14) {
      return WelcomeMessage(
        emoji: '🍽️',
        message: 'Bon appétit ! N\'oubliez pas de vous hydrater.',
      );
    } else if (hour >= 14 && hour < 18) {
      return WelcomeMessage(
        emoji: '🌞',
        message: 'Bon après-midi ! Comment vous sentez-vous ?',
      );
    } else if (hour >= 18 && hour < 22) {
      return WelcomeMessage(
        emoji: '🌇',
        message: 'Bonsoir ! Prenez soin de vous ce soir.',
      );
    } else {
      return WelcomeMessage(
        emoji: '🌙',
        message: 'Il est tard... N\'oubliez pas de vous reposer.',
      );
    }
  }

  Widget _buildCalendarInfoSection() {
    // Get user data safely
    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.userProfile : null;
    final cycleLength = _safeGetCycleLength(user);
    final periodLength = _safeGetPeriodLength(user);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Guide du calendrier menstruel',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  '🌸 Icônes de flux menstruel',
                  'L\'icône 🌸 indique les jours où un flux menstruel a été enregistré. '
                      'Lorsque cette icône apparaît en teinte claire avec transparence, '
                      'cela signifie qu\'il s\'agit d\'une prévision automatique des prochaines règles, '
                      'basée sur vos cycles précédents.',
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  '🌼 Fenêtre fertile',
                  'L\'icône 🌼 signale la fenêtre fertile estimée (phase ovulatoire), '
                      'calculée à partir de votre durée moyenne de cycle. '
                      'Elle n\'est affichée que pour les cycles passés ou en cours '
                      'afin d\'éviter toute confusion avec des données non confirmées.',
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  'Points d\'humeur',
                  'Les points d\'humeur offrent une représentation colorée de votre état émotionnel :\n'
                      '• Rose ou rose foncé : humeurs difficiles (tristesse, anxiété, irritabilité)\n'
                      '• Jaune : émotions positives (joie, confiance) - affiché uniquement si aucune humeur difficile n\'a été notée\n'
                      '• Bleu : état de calme - affiché si aucune humeur difficile ou positive n\'a été enregistrée\n'
                      '• Absence de point : aucune humeur pertinente saisie pour cette date',
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  'Données utilisées',
                  'Ces représentations sont générées à partir de vos données de cycle :\n'
                      '• Durée moyenne du cycle ($cycleLength jours)\n'
                      '• Durée moyenne des règles ($periodLength jours)\n'
                      '• Date de début des dernières règles\n'
                      '• Nombre de cycles complétés',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '💡 L\'estimation du cycle repose principalement sur votre durée moyenne de cycle (ACL), '
                    'permettant une expérience personnalisée et l\'anticipation des phases clés de votre cycle.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyLogForm(SymptomTrackerLoaded state, User user) {
    // Use safe data access methods
    final safeSymptoms = _safeGetSymptoms(user);
    final selectedDate = _selectedDate;
    final selectedCycleDay = _selectedCycleDay;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getStatusColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                      if (_getStatusSubtitle() != null)
                        Text(
                          _getStatusSubtitle()!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                          maxLines: 3,
                        ),
                    ],
                  ),
                ),
                if (_hasUnsavedChanges)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Modifications',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Enregistrement du ${DateFormat('dd MMMM yyyy', 'fr_FR').format(selectedDate)}',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 18, tablet: 20, desktop: 22),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Sélecteur de flux
          _buildFlowSelector(),
          const SizedBox(height: 16),

          // Sélecteur d'humeur
          _buildMoodSelector(),
          const SizedBox(height: 16),

          // Sélecteur de symptômes
          _buildSymptomSelector(safeSymptoms),
          const SizedBox(height: 16),

          // Notes
          _buildNotesField(),
          const SizedBox(height: 24),

          // Bouton de sauvegarde moderne
          ModernSaveButton(
            onPressed: () => _saveDailyLog(),
            isLoading: state.isSaving,
            text: selectedCycleDay != null
                ? 'Mettre à jour'
                : 'Enregistrer aujourd\'hui',
          ),
        ],
      ),
    );
  }

  // Helper methods for status indicator
  Color _getStatusColor() {
    if (_validationError != null) return AppColors.error;
    if (_hasUnsavedChanges) return AppColors.warning;
    if (_selectedCycleDay != null) return AppColors.success;
    return AppColors.primary;
  }

  IconData _getStatusIcon() {
    if (_validationError != null) return Icons.error_outline;
    if (_hasUnsavedChanges) return Icons.edit;
    if (_selectedCycleDay != null) return Icons.check_circle;
    return Icons.add_circle;
  }

  String _getStatusTitle() {
    if (_validationError != null) return 'Erreur de validation';
    if (_hasUnsavedChanges) return 'Modifications en cours';
    if (_selectedCycleDay != null) return 'Données existantes';
    return 'Nouvel enregistrement';
  }

  String? _getStatusSubtitle() {
    if (_validationError != null) return _validationError;
    if (_hasUnsavedChanges) return 'N\'oubliez pas de sauvegarder';
    if (_selectedCycleDay != null) return 'Vous pouvez modifier ces données';
    return 'Remplissez les informations ci-dessous';
  }

  Widget _buildFlowSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flux menstruel',
          style: GoogleFonts.inter(
            fontSize: Responsive.scale(context, 14, tablet: 16, desktop: 18),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FlowIntensity.values.map((flow) {
                final isSelected = _selectedFlow == flow;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.6,
                  ),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getFlowIcon(flow)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getFlowLabel(flow),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFlow = selected ? flow : null;
                        _hasUnsavedChanges = true;
                        _validationError = _validateData();
                      });
                    },
                    backgroundColor: AppColors.background,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: GoogleFonts.inter(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Humeur',
          style: GoogleFonts.inter(
            fontSize: Responsive.scale(context, 14, tablet: 16, desktop: 18),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MoodType.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.6,
                  ),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getMoodIcon(mood)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getMoodLabel(mood),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMood = selected ? mood : null;
                        _hasUnsavedChanges = true;
                        _validationError = _validateData();
                      });
                    },
                    backgroundColor: AppColors.background,
                    selectedColor: _getMoodColor(mood).withOpacity(0.2),
                    labelStyle: GoogleFonts.inter(
                      color: isSelected
                          ? _getMoodColor(mood)
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSymptomSelector(List<String> symptoms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Symptômes',
                style: GoogleFonts.inter(
                  fontSize:
                      Responsive.scale(context, 14, tablet: 16, desktop: 18),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showSymptomConfig = !_showSymptomConfig;
                });
              },
              icon: Icon(
                _showSymptomConfig ? Icons.expand_less : Icons.expand_more,
                size: 16,
              ),
              label: Text(
                _showSymptomConfig ? 'Masquer' : 'Configurer',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Symptom configuration section
        if (_showSymptomConfig)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Symptômes disponibles',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cochez les symptômes que vous souhaitez suivre :',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _predefinedSymptoms.map((symptom) {
                        final isSelected = symptoms.contains(symptom);
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.8,
                          ),
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_getSymptomIcon(symptom)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    symptom,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  if (!symptoms.contains(symptom)) {
                                    symptoms.add(symptom);
                                    _hasUnsavedChanges = true;
                                  }
                                } else {
                                  symptoms.remove(symptom);
                                  _selectedSymptoms.remove(symptom);
                                  _hasUnsavedChanges = true;
                                }
                              });
                              // Call the new method for better feedback
                              _onSymptomChanged(symptom, selected);
                            },
                            backgroundColor: AppColors.background,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: GoogleFonts.inter(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showSymptomConfig = false;
                      });
                    },
                    icon: Icon(Icons.check, size: 16),
                    label: Text('Confirmer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Symptom selection section
        if (symptoms.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.textSecondary, size: 24),
                const SizedBox(height: 8),
                Text(
                  'Aucun symptôme configuré',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cliquez sur "Configurer" pour ajouter des symptômes à suivre.',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.8,
                    ),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getSymptomIcon(symptom)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              symptom,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSymptoms.add(symptom);
                            _hasUnsavedChanges = true;
                          } else {
                            _selectedSymptoms.remove(symptom);
                            _hasUnsavedChanges = true;
                          }
                        });
                        // Call the new method for better feedback
                        _onSymptomChanged(symptom, selected);
                      },
                      backgroundColor: AppColors.background,
                      selectedColor: AppColors.secondary.withOpacity(0.2),
                      labelStyle: GoogleFonts.inter(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

        // Validation error display
        if (_validationError != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Notes',
                style: GoogleFonts.inter(
                  fontSize:
                      Responsive.scale(context, 14, tablet: 16, desktop: 18),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${_notesController.text.length}/500',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _notesController.text.length > 450
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(
            maxHeight: 120,
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 500,
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
            decoration: InputDecoration(
              hintText: 'Ajoutez vos notes pour aujourd\'hui...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              counterText: '', // Hide default counter
              suffixIcon: _notesController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        setState(() {
                          _notesController.clear();
                          _hasUnsavedChanges = true;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _onDaySelected(DateTime date, CycleDay? cycleDay) {
    // Validate if the selected date is in the future
    if (date.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Vous ne pouvez pas sélectionner une date future',
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _selectedDate = date;
      _selectedCycleDay = cycleDay;

      // Pre-fill form with existing data if available
      if (cycleDay != null) {
        _selectedFlow = cycleDay.flow;
        _selectedMood = cycleDay.mood;
        _selectedSymptoms.clear();
        _selectedSymptoms.addAll(cycleDay.symptoms);
        _notesController.text = cycleDay.notes ?? '';
        _hasUnsavedChanges =
            false; // No unsaved changes when loading existing data
      } else {
        _selectedFlow = null;
        _selectedMood = null;
        _selectedSymptoms.clear();
        _notesController.clear();
        _hasUnsavedChanges = false; // Reset when selecting a new empty date
      }

      _validationError = _validateData();
    });

    // Show feedback for date selection
    if (cycleDay != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.edit, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Modification des données du ${DateFormat('dd/MM/yyyy', 'fr_FR').format(date)}',
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.add, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Nouvel enregistrement pour le ${DateFormat('dd/MM/yyyy', 'fr_FR').format(date)}',
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to handle symptom changes and update calendar
  void _onSymptomChanged(String symptom, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedSymptoms.add(symptom);
      } else {
        _selectedSymptoms.remove(symptom);
      }
      _hasUnsavedChanges = true;
      _validationError = _validateData();
    });

    // Show feedback for symptom change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSelected ? Icons.add : Icons.remove, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${isSelected ? 'Ajout' : 'Suppression'} du symptôme: $symptom',
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _getFlowLabel(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.light:
        return 'Léger';
      case FlowIntensity.moderate:
        return 'Modéré';
      case FlowIntensity.heavy:
        return 'Abondant';
    }
  }

  String _getMoodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 'Heureuse';
      case MoodType.calm:
        return 'Calme';
      case MoodType.sad:
        return 'Triste';
      case MoodType.anxious:
        return 'Anxieuse';
      case MoodType.irritable:
        return 'Irritable';
      case MoodType.confident:
        return 'Confiance';
    }
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
      case MoodType.confident:
        return Colors.yellow[600]!;
      case MoodType.calm:
        return Colors.blue[400]!;
      case MoodType.sad:
      case MoodType.anxious:
      case MoodType.irritable:
        return Colors.red[400]!;
    }
  }

  String _getFlowIcon(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.light:
        return '💧';
      case FlowIntensity.moderate:
        return '💧💧';
      case FlowIntensity.heavy:
        return '💧💧💧';
    }
  }

  String _getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return '😄';
      case MoodType.calm:
        return '😌';
      case MoodType.sad:
        return '😢';
      case MoodType.anxious:
        return '😟';
      case MoodType.irritable:
        return '😠';
      case MoodType.confident:
        return '😊';
    }
  }

  String _getSymptomIcon(String symptom) {
    // Map symptoms to emojis (consistent with calendar)
    final Map<String, String> symptomEmojis = {
      'maux de tête': '🤕',
      'nausée': '🤢',
      'ballonnements': '💨',
      'douleur au bas-ventre': '💔',
      'fatigue': '😴',
      'bouffées de chaleur': '🌡️',
      'crampes': '💔',
      'douleurs lombaires': '🦴',
      'irritabilité': '😤',
      'anxiété': '😰',
      'dépression': '😔',
      'insomnie': '😴',
      'sueurs nocturnes': '💦',
      'sécheresse vaginale': '🌵',
      'gain de poids': '⚖️',
      'perte de libido': '💔',
      'migraine': '🤕',
      'vertiges': '💫',
      'palpitations': '💓',
      'douleurs articulaires': '🦴',
      'sécheresse cutanée': '🌵',
      'changements d\'humeur': '😤',
      'difficultés de concentration': '🤔',
      'troubles du sommeil': '😴',
      'bouffées de chaleur nocturnes': '🌡️',
      'sécheresse oculaire': '👁️',
      'douleurs mammaires': '💔',
      'saignements irréguliers': '🩸',
      'pertes vaginales': '💧',
    };

    return symptomEmojis[symptom.toLowerCase()] ?? '⚠️';
  }
}
