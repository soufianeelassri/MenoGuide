import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_agent.dart';
import '../constants/app_colors.dart';
import '../widgets/agent_avatar.dart';

class AIAgentPage extends StatefulWidget {
  final AgentType agentType;

  const AIAgentPage({
    Key? key,
    this.agentType = AgentType.wellnessCoach,
  }) : super(key: key);

  @override
  State<AIAgentPage> createState() => _AIAgentPageState();
}

class _AIAgentPageState extends State<AIAgentPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AgentMessage> _messages = [];
  bool _isTyping = false;
  late AgentPersonality _agent;

  @override
  void initState() {
    super.initState();
    _initializeAgent();
    _addWelcomeMessage();
  }

  void _initializeAgent() {
    switch (widget.agentType) {
      case AgentType.wellnessCoach:
        _agent = AgentPersonality.getWellnessCoach();
        break;
      case AgentType.hormoneAssistant:
        _agent = AgentPersonality.getHormoneAssistant();
        break;
      default:
        _agent = AgentPersonality.getWellnessCoach();
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          _agent.responses['greeting'] ?? 'Hello! How can I help you today?',
      type: MessageType.agent,
      timestamp: DateTime.now(),
      agentType: _agent.type,
      suggestions: [
        'I\'m having hot flashes',
        'My mood has been unstable',
        'I\'m having trouble sleeping',
        'Tell me about menopause symptoms',
      ],
    );
    _messages.add(welcomeMessage);
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
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: -0.3, curve: Curves.easeOutCubic),
              Expanded(
                child: _buildChatArea()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 800.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
              ),
              _buildInputArea()
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          AgentAvatar(
            agentType: _agent.type,
            size: 48,
            isOnline: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _agent.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.25,
                  ),
                ),
                Text(
                  _agent.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.softPinkGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _buildSpecialtiesHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtiesHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.lavenderGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specialties',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _agent.specialties.map((specialty) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  specialty,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(AgentMessage message) {
    final isUser = message.type == MessageType.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            AgentAvatar(
              agentType: _agent.type,
              size: 32,
              isOnline: true,
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.wellnessCard,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUser
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                  ),
                ),
                if (message.suggestions != null &&
                    message.suggestions!.isNotEmpty)
                  _buildSuggestions(message.suggestions!),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.softPinkGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((suggestion) {
          return GestureDetector(
            onTap: () => _sendMessage(suggestion),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                suggestion,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          AgentAvatar(
            agentType: _agent.type,
            size: 32,
            isOnline: true,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.wellnessCard,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                _buildTypingDot(1),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return Container(
      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 600 + (index * 200)),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.2, 1.2),
            duration: 600.ms,
            delay: Duration(milliseconds: index * 200),
          )
          .then()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(0.8, 0.8),
            duration: 600.ms,
          ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask ${_agent.name} anything...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.1,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.softPinkGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage([String? message]) {
    final content = message ?? _messageController.text.trim();
    if (content.isEmpty) return;

    // Add user message
    final userMessage = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    // Clear input
    _messageController.clear();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      _generateResponse(content);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _generateResponse(String userMessage) {
    setState(() {
      _isTyping = false;
    });

    String response = '';
    List<String>? suggestions;

    // Simple response logic based on keywords
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hot flash')) {
      response = _agent.responses['hot_flash'] ??
          'Hot flashes can be challenging. Let me help you understand and manage them.';
      suggestions = [
        'What triggers hot flashes?',
        'How long do they last?',
        'Natural remedies for hot flashes',
      ];
    } else if (lowerMessage.contains('mood') ||
        lowerMessage.contains('anxiety') ||
        lowerMessage.contains('depression')) {
      response = _agent.responses['mood_swing'] ??
          'Mood changes are very common during menopause. Your feelings are valid and there are ways to manage them.';
      suggestions = [
        'Coping strategies for mood swings',
        'When to seek professional help',
        'Lifestyle changes for better mood',
      ];
    } else if (lowerMessage.contains('sleep') ||
        lowerMessage.contains('insomnia')) {
      response = _agent.responses['sleep_issue'] ??
          'Sleep disturbances are common during menopause. Let\'s work on improving your sleep quality.';
      suggestions = [
        'Sleep hygiene tips',
        'Relaxation techniques',
        'When to see a doctor',
      ];
    } else {
      response =
          'Thank you for sharing that with me. I\'m here to support you on your menopause journey. Is there anything specific you\'d like to know more about?';
      suggestions = [
        'Tell me about menopause symptoms',
        'How to track my symptoms',
        'Lifestyle recommendations',
      ];
    }

    final agentMessage = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      type: MessageType.agent,
      timestamp: DateTime.now(),
      agentType: _agent.type,
      suggestions: suggestions,
    );

    setState(() {
      _messages.add(agentMessage);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
