import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import '../blocs/auth_bloc.dart';
import '../models/user.dart' as user_model;
import '../widgets/quick_action_card.dart';
import '../constants/app_colors.dart';
import '../widgets/animated_card.dart';
import '../models/ai_agent.dart';
import 'symptom_tracker_page.dart';
import 'ai_agent_page.dart';
import 'resources_page.dart';
import 'profile_page.dart';
import 'recommendations_page.dart';
import '../utils/responsive.dart';
import '../blocs/event_bloc.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import '../widgets/weather_widget.dart';
import 'event_detail_page.dart';
import 'menovibe_chat_page.dart';
import '../services/cycle_analysis_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Animation controllers
  late AnimationController _parallaxController;
  late Animation<double> _parallaxAnimation;

  // Statistics data with safe defaults
  final Map<String, dynamic> _weeklyStats = {
    'stress_level': 0,
    'sleep_quality': 0,
    'hot_flashes': 0,
    'mood_stability': 0,
  };

  // Dynamic recommendations
  final List<Map<String, dynamic>> _recommendations = [
    {
      'type': 'article',
      'title': 'Gérer les bouffées de chaleur naturellement',
      'description':
          'Découvrez des techniques efficaces pour réduire les bouffées de chaleur',
      'icon': Icons.thermostat_rounded,
      'color': AppColors.hotFlash,
      'readTime': '5 min',
    },
    {
      'type': 'exercise',
      'title': 'Yoga pour la ménopause',
      'description': 'Séquence de 15 minutes pour équilibrer vos hormones',
      'icon': Icons.fitness_center_rounded,
      'color': AppColors.primary,
      'duration': '15 min',
    },
    {
      'type': 'meditation',
      'title': 'Méditation guidée',
      'description': 'Séance de relaxation pour réduire le stress',
      'icon': Icons.self_improvement_rounded,
      'color': AppColors.secondary,
      'duration': '10 min',
    },
  ];

  // Customizable quick actions
  List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Suivi Symptômes',
      'subtitle': 'Enregistrer comment vous vous sentez',
      'icon': Icons.track_changes_rounded,
      'color': AppColors.primary,
      'route': '/symptom-tracker',
      'order': 0,
    },
    {
      'title': 'Menovibe',
      'subtitle': 'Support multi-agents pour la ménopause',
      'icon': Icons.psychology_rounded,
      'color': AppColors.secondary,
      'route': '/menovibe-chat',
      'order': 1,
    },
    {
      'title': 'Communauté',
      'subtitle': 'Se connecter avec d\'autres',
      'icon': Icons.people_rounded,
      'color': AppColors.tertiary,
      'route': '/community',
      'order': 2,
    },
  ];

  final List<Widget> _pages = [
    const HomeContent(),
    const SymptomTrackerPage(),
    const MenovibeChatPage(),
    const RecommendationsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar:
          Responsive.isMobile(context) ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Accueil'),
              _buildNavItem(1, Icons.track_changes_rounded, 'Suivi'),
              _buildNavItem(2, Icons.psychology_rounded, 'Menovibe'),
              _buildNavItem(3, Icons.recommend_rounded, 'Conseils'),
              _buildNavItem(4, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _parallaxController;
  late Animation<double> _parallaxAnimation;

  // Service d'analyse de cycle
  final CycleAnalysisService _cycleAnalysisService = CycleAnalysisService();

  // Statistiques hebdomadaires mises à jour
  Map<String, dynamic> _weeklyStats = {
    'stress': 0.0,
    'sleep': 0.0,
    'hotFlashes': 0.0,
    'moodStability': 0.0,
  };

  // État de chargement
  bool _isLoadingStats = false;

  // Helper methods for safe data access
  String _safeGetUserName(user_model.User? user) {
    if (user == null || user.name.isEmpty) return 'Utilisateur';
    return user.name;
  }

  String _safeGetUserEmail(user_model.User? user) {
    if (user == null || user.email.isEmpty) return 'Non défini';
    return user.email;
  }

  int _safeGetCycleLength(user_model.User? user) {
    if (user == null) return 0;
    return user.averageCycleLength;
  }

  int _safeGetPeriodLength(user_model.User? user) {
    if (user == null) return 0;
    return user.averagePeriodLength;
  }

  String _safeGetMenopausePhase(user_model.User? user) {
    if (user == null) return 'Non défini';
    switch (user.menopausePhase) {
      case user_model.MenopausePhase.pre:
        return 'Pré-ménopause';
      case user_model.MenopausePhase.peri:
        return 'Péri-ménopause';
      case user_model.MenopausePhase.post:
        return 'Post-ménopause';
      default:
        return 'Non défini';
    }
  }

  List<String> _safeGetSymptoms(user_model.User? user) {
    if (user == null || user.symptoms.isEmpty)
      return ['Aucun symptôme enregistré'];
    return user.symptoms;
  }

  List<String> _safeGetConcerns(user_model.User? user) {
    if (user == null || user.concerns.isEmpty)
      return ['Aucune préoccupation enregistrée'];
    return user.concerns;
  }

  int _safeGetCompletedCycles(user_model.User? user) {
    if (user == null) return 0;
    return user.completedCycles;
  }

  String _safeGetLastPeriodDate(user_model.User? user) {
    if (user == null || user.lastPeriodStartDate == null) return 'Non défini';
    return '${user.lastPeriodStartDate.day}/${user.lastPeriodStartDate.month}/${user.lastPeriodStartDate.year}';
  }

  final List<Map<String, dynamic>> _recommendations = [
    {
      'type': 'article',
      'title': 'Gérer les bouffées de chaleur naturellement',
      'description':
          'Découvrez des techniques efficaces pour réduire les bouffées de chaleur',
      'icon': Icons.thermostat_rounded,
      'color': AppColors.hotFlash,
      'readTime': '5 min',
    },
    {
      'type': 'exercise',
      'title': 'Yoga pour la ménopause',
      'description': 'Séquence de 15 minutes pour équilibrer vos hormones',
      'icon': Icons.fitness_center_rounded,
      'color': AppColors.primary,
      'duration': '15 min',
    },
    {
      'type': 'meditation',
      'title': 'Méditation guidée',
      'description': 'Séance de relaxation pour réduire le stress',
      'icon': Icons.self_improvement_rounded,
      'color': AppColors.secondary,
      'duration': '10 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);

    // Charger les statistiques hebdomadaires
    _loadWeeklyStats();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final progress = currentScroll / maxScroll;

    _parallaxController.value = progress;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: isDesktop ? 1200 : 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, isTablet),
                        SizedBox(height: isTablet ? 48 : 32),
                        _buildWeatherWidget(context, isTablet),
                        SizedBox(height: isTablet ? 48 : 32),
                        _buildWeeklyStats(context, isTablet),
                        SizedBox(height: isTablet ? 48 : 32),
                        _buildRecommendations(context, isTablet),
                        SizedBox(height: isTablet ? 48 : 32),
                        _buildUpcomingEvents(context, isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getPersonalizedGreeting(),
          style: GoogleFonts.inter(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          'Nous sommes là pour vous accompagner dans votre bien-être',
          style: GoogleFonts.inter(
            fontSize: isTablet ? 18 : 16,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideX(begin: -0.3),
      ],
    );
  }

  Widget _buildWeatherWidget(BuildContext context, bool isTablet) {
    return const WeatherWidget();
  }

  Widget _buildUpcomingEvents(BuildContext context, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return BlocProvider(
      create: (context) => EventBloc(EventService())..add(LoadEvents()),
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Événements',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: isDesktop ? 350 : (isTablet ? 320 : 300),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          }

          if (state is EventsLoaded) {
            final allEvents = state.events;

            if (allEvents.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Événements',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun événement disponible pour le moment',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: isDesktop ? 120 : (isTablet ? 100 : 80),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: AppColors.primary,
                          size: isDesktop ? 40 : (isTablet ? 32 : 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Restez informée',
                                style: GoogleFonts.inter(
                                  fontSize:
                                      isDesktop ? 20 : (isTablet ? 18 : 16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'De nouveaux événements seront bientôt disponibles',
                                style: GoogleFonts.inter(
                                  fontSize:
                                      isDesktop ? 16 : (isTablet ? 14 : 12),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Événements',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Découvrez tous nos événements communautaires',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: isDesktop ? 520 : (isTablet ? 480 : 440),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allEvents.length,
                    itemBuilder: (context, index) {
                      final event = allEvents[index];
                      return Container(
                        width: isDesktop ? 470 : (isTablet ? 420 : 370),
                        margin: EdgeInsets.only(
                          right: index == allEvents.length - 1 ? 0 : 20,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailPage(
                                  eventId: event.id,
                                ),
                              ),
                            );
                          },
                          child: EventCard(event: event),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is EventError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Événements',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: isDesktop ? 120 : (isTablet ? 100 : 80),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: isDesktop ? 40 : (isTablet ? 32 : 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Erreur de chargement',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Impossible de charger les événements',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWeeklyStats(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vos progrès cette semaine',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (_isLoadingStats)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isTablet ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 1.2 : 1.5,
          children: _weeklyStats.entries.map((entry) {
            final value = (entry.value as num).toDouble();
            final isPositive = value > 0;
            final icon = _getStatIcon(entry.key);
            final title = _getStatTitle(entry.key);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: _getStatColor(entry.key, value),
                    size: isTablet ? 32 : 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatColor(entry.key, value),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 12 : 10,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recommandations pour vous',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isTablet || isDesktop)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(
                  'Voir tout',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Contenu adapté à votre situation',
          style: GoogleFonts.inter(
            fontSize: isTablet ? 16 : 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: isDesktop
              ? 320
              : isTablet
                  ? 280
                  : 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = _recommendations[index];
              return Container(
                width: isDesktop
                    ? 350
                    : isTablet
                        ? 320
                        : 280,
                margin: EdgeInsets.only(
                  right: index == _recommendations.length - 1 ? 0 : 20,
                ),
                child: AnimatedCard(
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          recommendation['color'].withOpacity(0.15),
                          recommendation['color'].withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: recommendation['color'].withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: recommendation['color'].withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: recommendation['color'].withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                recommendation['icon'],
                                color: recommendation['color'],
                                size: isTablet ? 24 : 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: recommendation['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      recommendation['color'].withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                recommendation['type'] == 'article'
                                    ? 'Article'
                                    : recommendation['type'] == 'exercise'
                                        ? 'Exercice'
                                        : 'Méditation',
                                style: GoogleFonts.inter(
                                  fontSize: isTablet ? 12 : 11,
                                  fontWeight: FontWeight.w600,
                                  color: recommendation['color'],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          recommendation['title'],
                          style: GoogleFonts.inter(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recommendation['description'],
                          style: GoogleFonts.inter(
                            fontSize: isTablet ? 14 : 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              recommendation['type'] == 'article'
                                  ? '${recommendation['readTime']} de lecture'
                                  : '${recommendation['duration']} de séance',
                              style: GoogleFonts.inter(
                                fontSize: isTablet ? 12 : 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getPersonalizedGreeting() {
    final user = context.read<AuthBloc>().state;
    String name = '';

    if (user is Authenticated) {
      name = _safeGetUserName(user.userProfile);
    }

    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = 'Bonjour';
    } else if (hour < 17) {
      timeGreeting = 'Bon après-midi';
    } else {
      timeGreeting = 'Bonsoir';
    }

    if (name.isNotEmpty) {
      return '$timeGreeting $name, comment vous sentez-vous aujourd\'hui ?';
    } else {
      return '$timeGreeting, comment vous sentez-vous aujourd\'hui ?';
    }
  }

  IconData _getStatIcon(String statKey) {
    switch (statKey) {
      case 'stress':
        return Icons.psychology_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'hotFlashes':
        return Icons.thermostat_rounded;
      case 'moodStability':
        return Icons.mood_rounded;
      default:
        return Icons.trending_up_rounded;
    }
  }

  String _getStatTitle(String statKey) {
    switch (statKey) {
      case 'stress':
        return 'Stress';
      case 'sleep':
        return 'Sommeil';
      case 'hotFlashes':
        return 'Bouffées';
      case 'moodStability':
        return 'Humeur';
      default:
        return 'Progrès';
    }
  }

  Color _getStatColor(String statKey, double value) {
    bool isImprovement;

    switch (statKey) {
      case 'stress':
      case 'hotFlashes':
        isImprovement = value < 0; // Négatif = amélioration
        break;
      case 'sleep':
      case 'moodStability':
        isImprovement = value > 0; // Positif = amélioration
        break;
      default:
        return AppColors.textSecondary;
    }

    if (value.abs() < 1) {
      return AppColors.textSecondary; // Stable
    }

    return isImprovement ? AppColors.success : AppColors.warning;
  }

  /// Charger les statistiques hebdomadaires avec l'analyse Gemini
  Future<void> _loadWeeklyStats() async {
    if (_isLoadingStats) return;

    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Générer des données de test pour la démonstration
      // En production, cela viendrait de votre base de données
      final testData = _cycleAnalysisService.generateTestData();

      print('📊 Analyse des données de cycle avec Gemini...');
      final analysisResult =
          await _cycleAnalysisService.analyzeCycleData(testData);

      setState(() {
        _weeklyStats = {
          'stress': (analysisResult['stress'] as num).toDouble(),
          'sleep': (analysisResult['sleep'] as num).toDouble(),
          'hotFlashes': (analysisResult['hotFlashes'] as num).toDouble(),
          'moodStability': (analysisResult['moodStability'] as num).toDouble(),
        };
        _isLoadingStats = false;
      });

      print('✅ Statistiques hebdomadaires mises à jour: $_weeklyStats');
    } catch (e) {
      print('❌ Erreur lors du chargement des statistiques: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }
}
