import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/community_post.dart';
import '../utils/responsive.dart';
import '../widgets/animated_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isAnonymousMode = false;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Static featured content
  final List<Map<String, dynamic>> _featuredContent = [
    {
      'type': 'quote',
      'content':
          'Every woman\'s journey through menopause is unique. Be kind to yourself and remember that you\'re not alone.',
      'author': 'Community Wisdom',
      'icon': Icons.favorite_rounded,
      'color': AppColors.hotFlash,
    },
    {
      'type': 'tip',
      'content':
          'Try keeping a small fan by your bedside for hot flash relief during the night.',
      'author': 'Wellness Tip',
      'icon': Icons.lightbulb_rounded,
      'color': AppColors.accent,
    },
    {
      'type': 'fact',
      'content':
          'Did you know? Menopause typically occurs between ages 45-55, but symptoms can begin years earlier.',
      'author': 'Health Fact',
      'icon': Icons.science_rounded,
      'color': AppColors.primary,
    },
  ];

  // Sample posts by category
  final Map<String, List<CommunityPost>> _postsByCategory = {
    'emotional': [
      CommunityPost(
        id: '1',
        userId: 'user1',
        userName: 'Sarah M.',
        isAnonymous: false,
        content:
            'Feeling really overwhelmed today. The mood swings are intense and I just want to cry. Anyone else experiencing this?',
        category: 'emotional',
        likes: 12,
        comments: 8,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['mood swings', 'emotional support'],
      ),
      CommunityPost(
        id: '2',
        userId: 'user2',
        userName: 'Anonymous',
        isAnonymous: true,
        content:
            'I\'ve been feeling so isolated lately. My friends don\'t understand what I\'m going through. It\'s nice to know there are others here who get it.',
        category: 'emotional',
        likes: 15,
        comments: 12,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        tags: ['isolation', 'support'],
      ),
    ],
    'medical': [
      CommunityPost(
        id: '3',
        userId: 'user3',
        userName: 'Dr. Lisa',
        isAnonymous: false,
        content:
            'I\'m a gynecologist and I want to share some information about HRT options. There are many different approaches and what works for one person may not work for another. Always consult with your healthcare provider.',
        category: 'medical',
        likes: 25,
        comments: 15,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        tags: ['HRT', 'medical advice'],
      ),
    ],
    'lifestyle': [
      CommunityPost(
        id: '4',
        userId: 'user4',
        userName: 'Maria K.',
        isAnonymous: false,
        content:
            'I started doing yoga 3 times a week and it has made such a difference with my hot flashes and stress levels. Highly recommend!',
        category: 'lifestyle',
        likes: 18,
        comments: 6,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        tags: ['yoga', 'exercise', 'hot flashes'],
      ),
    ],
    'diet': [
      CommunityPost(
        id: '5',
        userId: 'user5',
        userName: 'Anonymous',
        isAnonymous: true,
        content:
            'I\'ve been avoiding spicy foods and caffeine, and my hot flashes have decreased significantly. Has anyone else noticed this connection?',
        category: 'diet',
        likes: 22,
        comments: 14,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        tags: ['diet', 'hot flashes', 'caffeine'],
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _commentController.dispose();
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
        child: Column(
          children: [
            _buildHeader(context, isTablet),
            _buildCreatePostButton(context, isTablet),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: isDesktop ? 1200 : 800),
                    child: Column(
                      children: [
                        _buildCategories(context, isTablet),
                        SizedBox(height: isTablet ? 48 : 32),
                        _buildPosts(context, isTablet),
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
    return Container(
      padding: EdgeInsets.all(
          Responsive.scale(context, 16, tablet: 24, desktop: 32)),
      child: Row(
        children: [
          Container(
            width: Responsive.scale(context, 48, tablet: 56, desktop: 64),
            height: Responsive.scale(context, 48, tablet: 56, desktop: 64),
            decoration: BoxDecoration(
              gradient: AppColors.communityGradient,
              borderRadius: BorderRadius.circular(
                  Responsive.scale(context, 12, tablet: 16, desktop: 20)),
            ),
            child: Icon(
              Icons.people_rounded,
              color: Colors.white,
              size: Responsive.scale(context, 24, tablet: 28, desktop: 32),
            ),
          ),
          SizedBox(
              width: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: GoogleFonts.inter(
                    fontSize:
                        Responsive.scale(context, 24, tablet: 28, desktop: 32),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Connect, share, and support each other',
                  style: GoogleFonts.inter(
                    fontSize:
                        Responsive.scale(context, 14, tablet: 16, desktop: 18),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Anonymous mode toggle
          Switch(
            value: _isAnonymousMode,
            onChanged: (value) {
              setState(() {
                _isAnonymousMode = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostButton(BuildContext context, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(
          top: Responsive.scale(context, 24, tablet: 32, desktop: 40)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showCreatePostDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: Responsive.scale(context, 16, tablet: 20, desktop: 24),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  Responsive.scale(context, 12, tablet: 16, desktop: 20)),
            ),
          ),
          child: Text(
            'Create Post',
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 16, tablet: 18, desktop: 20),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(
          bottom: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
      child: Row(
        children: [
          _buildCategoryButton('Emotional', 'emotional', isTablet),
          SizedBox(
              width: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
          _buildCategoryButton('Medical', 'medical', isTablet),
          SizedBox(
              width: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
          _buildCategoryButton('Lifestyle', 'lifestyle', isTablet),
          SizedBox(
              width: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
          _buildCategoryButton('Diet', 'diet', isTablet),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, String category, bool isTablet) {
    return GestureDetector(
      onTap: () {
        // Handle category selection
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.scale(context, 16, tablet: 20, desktop: 24),
          vertical: Responsive.scale(context, 8, tablet: 12, desktop: 16),
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
              Responsive.scale(context, 8, tablet: 12, desktop: 16)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: Responsive.scale(context, 14, tablet: 16, desktop: 18),
            fontWeight: FontWeight.w500,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildPosts(BuildContext context, bool isTablet) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsList('emotional'),
          _buildPostsList('medical'),
          _buildPostsList('lifestyle'),
          _buildPostsList('diet'),
        ],
      ),
    );
  }

  Widget _buildPostsList(String category) {
    final posts = _postsByCategory[category] ?? [];

    return ListView.builder(
      padding: EdgeInsets.all(
          Responsive.scale(context, 16, tablet: 24, desktop: 32)),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post)
            .animate()
            .fadeIn(delay: (index * 100).ms)
            .slideX(begin: 0.3);
      },
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return AnimatedCard(
      child: Container(
        margin: EdgeInsets.only(
            bottom: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
        padding: EdgeInsets.all(
            Responsive.scale(context, 20, tablet: 24, desktop: 28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              children: [
                CircleAvatar(
                  radius:
                      Responsive.scale(context, 20, tablet: 24, desktop: 28),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    post.isAnonymous
                        ? Icons.person_rounded
                        : Icons.person_rounded,
                    color: AppColors.primary,
                    size:
                        Responsive.scale(context, 20, tablet: 24, desktop: 28),
                  ),
                ),
                SizedBox(
                    width:
                        Responsive.scale(context, 12, tablet: 16, desktop: 20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.isAnonymous ? 'Anonymous' : post.userName,
                        style: GoogleFonts.inter(
                          fontSize: Responsive.scale(context, 16,
                              tablet: 18, desktop: 20),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: Responsive.scale(context, 12,
                              tablet: 14, desktop: 16),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.isAnonymous)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          Responsive.scale(context, 8, tablet: 12, desktop: 16),
                      vertical:
                          Responsive.scale(context, 4, tablet: 6, desktop: 8),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Responsive.scale(
                          context, 8,
                          tablet: 12, desktop: 16)),
                    ),
                    child: Text(
                      'Anonymous',
                      style: GoogleFonts.inter(
                        fontSize: Responsive.scale(context, 10,
                            tablet: 12, desktop: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(
                height: Responsive.scale(context, 16, tablet: 20, desktop: 24)),

            // Post content
            Text(
              post.content,
              style: GoogleFonts.inter(
                fontSize:
                    Responsive.scale(context, 16, tablet: 18, desktop: 20),
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            // Tags
            if (post.tags.isNotEmpty) ...[
              SizedBox(
                  height:
                      Responsive.scale(context, 12, tablet: 16, desktop: 20)),
              Wrap(
                spacing: Responsive.scale(context, 8, tablet: 12, desktop: 16),
                runSpacing:
                    Responsive.scale(context, 8, tablet: 12, desktop: 16),
                children: post.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          Responsive.scale(context, 8, tablet: 12, desktop: 16),
                      vertical:
                          Responsive.scale(context, 4, tablet: 6, desktop: 8),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Responsive.scale(
                          context, 8,
                          tablet: 12, desktop: 16)),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.inter(
                        fontSize: Responsive.scale(context, 12,
                            tablet: 14, desktop: 16),
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            SizedBox(
                height: Responsive.scale(context, 16, tablet: 20, desktop: 24)),

            // Post actions
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border_rounded,
                  label: '${post.likes}',
                  onTap: () {
                    // Handle like
                  },
                ),
                SizedBox(
                    width:
                        Responsive.scale(context, 24, tablet: 32, desktop: 40)),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.comments}',
                  onTap: () {
                    _showCommentsDialog(context, post);
                  },
                ),
                SizedBox(
                    width:
                        Responsive.scale(context, 24, tablet: 32, desktop: 40)),
                _buildActionButton(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Save',
                  onTap: () {
                    // Handle bookmark
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Handle share
                  },
                  icon: Icon(
                    Icons.share_rounded,
                    color: AppColors.textSecondary,
                    size:
                        Responsive.scale(context, 20, tablet: 24, desktop: 28),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: Responsive.scale(context, 18, tablet: 20, desktop: 22),
          ),
          SizedBox(width: Responsive.scale(context, 4, tablet: 6, desktop: 8)),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: Responsive.scale(context, 14, tablet: 16, desktop: 18),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(
                  Responsive.scale(context, 24, tablet: 32, desktop: 40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a Post',
                    style: GoogleFonts.inter(
                      fontSize: Responsive.scale(context, 24,
                          tablet: 28, desktop: 32),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(
                      height: Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),

                  // Anonymous toggle
                  Row(
                    children: [
                      Switch(
                        value: _isAnonymousMode,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymousMode = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      SizedBox(
                          width: Responsive.scale(context, 12,
                              tablet: 16, desktop: 20)),
                      Text(
                        'Post anonymously',
                        style: GoogleFonts.inter(
                          fontSize: Responsive.scale(context, 16,
                              tablet: 18, desktop: 20),
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                      height: Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),

                  // Post content
                  TextField(
                    controller: _postController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          'Share your thoughts, questions, or experiences...',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.scale(
                            context, 12,
                            tablet: 16, desktop: 20)),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.scale(
                            context, 12,
                            tablet: 16, desktop: 20)),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  SizedBox(
                      height: Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),

                  // Category selection
                  Text(
                    'Category',
                    style: GoogleFonts.inter(
                      fontSize: Responsive.scale(context, 16,
                          tablet: 18, desktop: 20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(
                      height: Responsive.scale(context, 12,
                          tablet: 16, desktop: 20)),

                  Wrap(
                    spacing:
                        Responsive.scale(context, 8, tablet: 12, desktop: 16),
                    children: ['emotional', 'medical', 'lifestyle', 'diet']
                        .map((category) {
                      return ChoiceChip(
                        label: Text(category.capitalize()),
                        selected: false,
                        onSelected: (selected) {
                          // Handle category selection
                        },
                      );
                    }).toList(),
                  ),

                  const Spacer(),

                  // Post button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _postController.text.isNotEmpty
                          ? () {
                              // Handle post creation
                              Navigator.pop(context);
                              _postController.clear();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.scale(context, 16,
                              tablet: 20, desktop: 24),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.scale(
                              context, 12,
                              tablet: 16, desktop: 20)),
                        ),
                      ),
                      child: Text(
                        'Post',
                        style: GoogleFonts.inter(
                          fontSize: Responsive.scale(context, 16,
                              tablet: 18, desktop: 20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(
                  Responsive.scale(context, 24, tablet: 32, desktop: 40)),
              child: Column(
                children: [
                  Text(
                    'Comments',
                    style: GoogleFonts.inter(
                      fontSize: Responsive.scale(context, 20,
                          tablet: 24, desktop: 28),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(
                      height: Responsive.scale(context, 24,
                          tablet: 32, desktop: 40)),

                  // Comments list
                  Expanded(
                    child: ListView.builder(
                      itemCount: post.comments,
                      itemBuilder: (context, index) {
                        return _buildCommentItem();
                      },
                    ),
                  ),

                  // Comment input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Responsive.scale(context, 12,
                                      tablet: 16, desktop: 20)),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Responsive.scale(context, 12,
                                      tablet: 16, desktop: 20)),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: Responsive.scale(context, 12,
                              tablet: 16, desktop: 20)),
                      IconButton(
                        onPressed: () {
                          // Handle comment submission
                        },
                        icon: Icon(
                          Icons.send_rounded,
                          color: AppColors.primary,
                          size: Responsive.scale(context, 24,
                              tablet: 28, desktop: 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem() {
    return Container(
      margin: EdgeInsets.only(
          bottom: Responsive.scale(context, 16, tablet: 20, desktop: 24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: Responsive.scale(context, 16, tablet: 20, desktop: 24),
            backgroundColor: AppColors.accent.withOpacity(0.2),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.accent,
              size: Responsive.scale(context, 16, tablet: 20, desktop: 24),
            ),
          ),
          SizedBox(
              width: Responsive.scale(context, 12, tablet: 16, desktop: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Member',
                  style: GoogleFonts.inter(
                    fontSize:
                        Responsive.scale(context, 14, tablet: 16, desktop: 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'This is a sample comment. In a real app, this would show actual user comments.',
                  style: GoogleFonts.inter(
                    fontSize:
                        Responsive.scale(context, 14, tablet: 16, desktop: 18),
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(
                    height:
                        Responsive.scale(context, 4, tablet: 6, desktop: 8)),
                Text(
                  '2 hours ago',
                  style: GoogleFonts.inter(
                    fontSize:
                        Responsive.scale(context, 12, tablet: 14, desktop: 16),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
