import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/event_bloc.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import '../constants/app_colors.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  const EventDetailPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return BlocProvider<EventBloc>(
      create: (_) => EventBloc(EventService())..add(LoadEventById(eventId)),
      child: Scaffold(
        body: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              );
            } else if (state is EventLoaded) {
              final event = state.event;
              final isPast = event.isPast;

              return Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ),
                child: CustomScrollView(
                  slivers: [
                    // App Bar avec image de fond
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.primary),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image de l'événement ou placeholder
                            event.imageUrl != null
                                ? Image.network(
                                    event.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildImagePlaceholder(
                                          event.type, isTablet);
                                    },
                                  )
                                : _buildImagePlaceholder(event.type, isTablet),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Badges en bas de l'image
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                children: [
                                  _buildStatusBadge(isPast),
                                  const SizedBox(width: 12),
                                  _buildTypeBadge(event.type),
                                  const Spacer(),
                                  if (event.isFull)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'COMPLET',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contenu principal
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            Text(
                              event.title,
                              style: GoogleFonts.inter(
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Container(
                              padding: const EdgeInsets.all(20),
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
                              child: Text(
                                event.description,
                                style: GoogleFonts.inter(
                                  fontSize: isTablet ? 18 : 16,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Informations principales
                            _buildInfoCard(
                              context,
                              isTablet,
                              'Informations',
                              [
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Date et heure',
                                  DateFormat(
                                          'EEEE dd MMMM yyyy à HH:mm', 'fr_FR')
                                      .format(event.date),
                                ),
                                _buildInfoRow(
                                  Icons.access_time,
                                  'Durée',
                                  '${event.duration} minutes',
                                ),
                                _buildInfoRow(
                                  Icons.people,
                                  'Participants',
                                  '${event.currentAttendees}/${event.maxAttendees} inscrits',
                                ),
                                if (!event.isFree)
                                  _buildInfoRow(
                                    Icons.euro,
                                    'Prix',
                                    '${event.price} ${event.currency ?? 'EUR'}',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Hôte
                            if (event.host.name.isNotEmpty)
                              _buildInfoCard(
                                context,
                                isTablet,
                                'Animateur',
                                [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: isTablet ? 24 : 20,
                                        backgroundColor:
                                            AppColors.primary.withOpacity(0.1),
                                        child: Text(
                                          event.host.name[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.host.name,
                                              style: GoogleFonts.inter(
                                                fontSize: isTablet ? 18 : 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            if (event.host.title.isNotEmpty)
                                              Text(
                                                event.host.title,
                                                style: GoogleFonts.inter(
                                                  fontSize: isTablet ? 14 : 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),

                            // Lien de participation
                            if (event.meetingLink != null &&
                                event.meetingLink!.isNotEmpty)
                              _buildInfoCard(
                                context,
                                isTablet,
                                'Participation',
                                [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.video_call,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Lien de participation',
                                              style: GoogleFonts.inter(
                                                fontSize: isTablet ? 16 : 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SelectableText(
                                              event.meetingLink!,
                                              style: GoogleFonts.inter(
                                                fontSize: isTablet ? 14 : 12,
                                                color: AppColors.primary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Ouvrir le lien
                                        },
                                        icon: const Icon(
                                          Icons.open_in_new,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),

                            // Tags
                            if (event.tags.isNotEmpty)
                              _buildInfoCard(
                                context,
                                isTablet,
                                'Tags',
                                [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: event.tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: GoogleFonts.inter(
                                            fontSize: isTablet ? 14 : 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is EventError) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(EventType type, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getEventTypeColor(type).withOpacity(0.8),
            _getEventTypeColor(type).withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getEventTypeIcon(type),
          size: isTablet ? 80 : 64,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isTablet, String title,
      List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isPast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey.shade600 : Colors.green.shade600,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPast ? Icons.schedule : Icons.event_available,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isPast ? 'Terminé' : 'À venir',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(EventType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getEventTypeColor(type),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEventTypeIcon(type),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _getEventTypeLabel(type),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.webinar:
        return Colors.blue;
      case EventType.workshop:
        return Colors.orange;
      case EventType.conference:
        return Colors.purple;
      case EventType.support_group:
        return Colors.green;
      case EventType.meditation:
        return Colors.indigo;
      case EventType.exercise:
        return Colors.red;
      case EventType.nutrition:
        return Colors.teal;
      case EventType.medical:
        return Colors.pink;
      case EventType.education:
        return Colors.amber;
      case EventType.bien_etre:
        return Colors.lightGreen;
    }
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.webinar:
        return Icons.video_camera_front;
      case EventType.workshop:
        return Icons.work;
      case EventType.conference:
        return Icons.people;
      case EventType.support_group:
        return Icons.favorite;
      case EventType.meditation:
        return Icons.self_improvement;
      case EventType.exercise:
        return Icons.fitness_center;
      case EventType.nutrition:
        return Icons.restaurant;
      case EventType.medical:
        return Icons.medical_services;
      case EventType.education:
        return Icons.school;
      case EventType.bien_etre:
        return Icons.spa;
    }
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.webinar:
        return 'WEBINAR';
      case EventType.workshop:
        return 'ATELIER';
      case EventType.conference:
        return 'CONFÉRENCE';
      case EventType.support_group:
        return 'GROUPE';
      case EventType.meditation:
        return 'MÉDITATION';
      case EventType.exercise:
        return 'EXERCICE';
      case EventType.nutrition:
        return 'NUTRITION';
      case EventType.medical:
        return 'MÉDICAL';
      case EventType.education:
        return 'ÉDUCATION';
      case EventType.bien_etre:
        return 'BIEN-ÊTRE';
    }
  }
}
