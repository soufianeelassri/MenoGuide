import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../utils/responsive.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({Key? key}) : super(key: key);

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Articles',
      'icon': Icons.article_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Livres',
      'icon': Icons.book_rounded,
      'color': AppColors.secondary,
    },
    {
      'title': 'Lieux',
      'icon': Icons.location_on_rounded,
      'color': AppColors.accent,
    },
    {
      'title': 'Exercices',
      'icon': Icons.fitness_center_rounded,
      'color': AppColors.tertiary,
    },
  ];

  final List<Map<String, dynamic>> _articles = [
    {
      'title': 'Gérer les bouffées de chaleur naturellement',
      'description':
          'Découvrez des techniques efficaces pour réduire les bouffées de chaleur pendant la ménopause.',
      'readTime': '5 min',
      'category': 'Santé',
      'image': 'assets/images/article1.jpg',
    },
    {
      'title': 'L\'importance de l\'exercice pendant la ménopause',
      'description':
          'Comment l\'activité physique peut améliorer votre bien-être et réduire les symptômes.',
      'readTime': '7 min',
      'category': 'Fitness',
      'image': 'assets/images/article2.jpg',
    },
    {
      'title': 'Nutrition et équilibre hormonal',
      'description':
          'Les aliments qui soutiennent votre équilibre hormonal pendant cette période de transition.',
      'readTime': '6 min',
      'category': 'Nutrition',
      'image': 'assets/images/article3.jpg',
    },
    {
      'title': 'Gestion du stress et méditation',
      'description':
          'Techniques de relaxation et méditation pour réduire le stress et améliorer votre humeur.',
      'readTime': '4 min',
      'category': 'Bien-être',
      'image': 'assets/images/article4.jpg',
    },
  ];

  final List<Map<String, dynamic>> _books = [
    {
      'title': 'La Ménopause Naturelle',
      'author': 'Dr. Marie Dubois',
      'description':
          'Guide complet pour traverser la ménopause avec sérénité et naturel.',
      'rating': 4.8,
      'pages': 320,
      'image': 'assets/images/book1.jpg',
    },
    {
      'title': 'Femme et Sagesse',
      'author': 'Sophie Martin',
      'description':
          'Redécouvrez votre force intérieure pendant cette période de transformation.',
      'rating': 4.6,
      'pages': 280,
      'image': 'assets/images/book2.jpg',
    },
    {
      'title': 'Yoga pour la Ménopause',
      'author': 'Claire Bernard',
      'description':
          'Pratiques de yoga adaptées pour soulager les symptômes de la ménopause.',
      'rating': 4.7,
      'pages': 240,
      'image': 'assets/images/book3.jpg',
    },
    {
      'title': 'Nutrition Hormonale',
      'author': 'Dr. Anne Leroy',
      'description':
          'Comment nourrir votre corps pour soutenir votre équilibre hormonal.',
      'rating': 4.9,
      'pages': 350,
      'image': 'assets/images/book4.jpg',
    },
  ];

  final List<Map<String, dynamic>> _places = [
    {
      'title': 'Centre de Bien-être Zen',
      'description':
          'Spa et centre de relaxation spécialisé dans le bien-être féminin.',
      'distance': '2.5 km',
      'rating': 4.8,
      'category': 'Spa & Relaxation',
      'image': 'assets/images/place1.jpg',
    },
    {
      'title': 'Studio de Yoga Harmonie',
      'description':
          'Cours de yoga adaptés pour les femmes en période de ménopause.',
      'distance': '1.8 km',
      'rating': 4.7,
      'category': 'Yoga',
      'image': 'assets/images/place2.jpg',
    },
    {
      'title': 'Salle de Sport Équilibre',
      'description':
          'Programmes d\'entraînement spécialement conçus pour les femmes de 40+.',
      'distance': '3.2 km',
      'rating': 4.6,
      'category': 'Fitness',
      'image': 'assets/images/place3.jpg',
    },
    {
      'title': 'Café Santé & Détente',
      'description': 'Café avec menu santé et espace de rencontre pour femmes.',
      'distance': '1.2 km',
      'rating': 4.5,
      'category': 'Café & Rencontre',
      'image': 'assets/images/place4.jpg',
    },
  ];

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Yoga Doux',
      'description':
          'Séquence de 20 minutes pour équilibrer les hormones et réduire le stress.',
      'duration': '20 min',
      'difficulty': 'Débutant',
      'benefits': ['Équilibre hormonal', 'Réduction stress', 'Flexibilité'],
      'image': 'assets/images/exercise1.jpg',
    },
    {
      'title': 'Marche Active',
      'description':
          'Programme de marche quotidienne pour maintenir la santé cardiovasculaire.',
      'duration': '30 min',
      'difficulty': 'Tous niveaux',
      'benefits': ['Santé cardiaque', 'Perte de poids', 'Énergie'],
      'image': 'assets/images/exercise2.jpg',
    },
    {
      'title': 'Pilates',
      'description':
          'Exercices de renforcement du centre du corps et amélioration de la posture.',
      'duration': '25 min',
      'difficulty': 'Intermédiaire',
      'benefits': ['Renforcement', 'Posture', 'Équilibre'],
      'image': 'assets/images/exercise3.jpg',
    },
    {
      'title': 'Méditation Guidée',
      'description':
          'Séance de méditation pour calmer l\'esprit et réduire l\'anxiété.',
      'duration': '15 min',
      'difficulty': 'Débutant',
      'benefits': ['Réduction anxiété', 'Clarté mentale', 'Sommeil'],
      'image': 'assets/images/exercise4.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommandations'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCategoryTabs(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final isSelected = _selectedCategory == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? category['color'] : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: category['color'].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : category['color'],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['title'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildContent() {
    switch (_selectedCategory) {
      case 0:
        return _buildArticlesList();
      case 1:
        return _buildBooksList();
      case 2:
        return _buildPlacesList();
      case 3:
        return _buildExercisesList();
      default:
        return _buildArticlesList();
    }
  }

  Widget _buildArticlesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return _buildArticleCard(article, index);
      },
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.article_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article['category'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article['readTime'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  article['title'],
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article['description'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to article detail
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Lire l\'article'),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 600.ms)
        .slideX(begin: 0.2);
  }

  Widget _buildBooksList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return _buildBookCard(book, index);
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.book_rounded,
                  size: 32,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Par ${book['author']}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        book['rating'].toString(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${book['pages']} pages',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book['description'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to book detail
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Découvrir'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 600.ms)
        .slideX(begin: 0.2);
  }

  Widget _buildPlacesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];
        return _buildPlaceCard(place, index);
      },
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.location_on_rounded,
                size: 48,
                color: AppColors.accent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place['category'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place['rating'].toString(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  place['title'],
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place['distance'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  place['description'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to place detail or open maps
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Voir sur la carte'),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 600.ms)
        .slideX(begin: 0.2);
  }

  Widget _buildExercisesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return _buildExerciseCard(exercise, index);
      },
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 28,
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['title'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise['duration'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tertiary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise['difficulty'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              exercise['description'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bénéfices:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: exercise['benefits'].map<Widget>((benefit) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    benefit,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Start exercise or navigate to exercise detail
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Commencer'),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 600.ms)
        .slideX(begin: 0.2);
  }
}
