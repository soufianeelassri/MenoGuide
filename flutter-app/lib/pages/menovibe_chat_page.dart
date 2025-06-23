import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/menovibe_agent.dart';
import '../services/reasoning_engine_service.dart';

/// Simulated agent streaming function signature (to be implemented elsewhere)
/// Future<Stream<String>> sendMessageToAgent(String message)

class MenovibeChatPage extends StatefulWidget {
  const MenovibeChatPage({Key? key}) : super(key: key);

  @override
  State<MenovibeChatPage> createState() => _MenovibeChatPageState();
}

class ChatMessage {
  final String sender;
  final String content;
  final bool isError;
  final List<String>? suggestions;
  ChatMessage({
    required this.sender,
    required this.content,
    this.isError = false,
    this.suggestions,
  });
}

class _MenovibeChatPageState extends State<MenovibeChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _streamingContent = '';

  // Instantiate the new service
  final ReasoningEngineService _reasoningEngineService =
      ReasoningEngineService();

  @override
  void initState() {
    super.initState();
    // Add initial greeting message
    _messages.add(
      ChatMessage(
        sender: 'Menovibe Agent',
        content:
            "Bonjour ! Je suis votre agent Menovibe. Comment puis-je vous aider aujourd'hui ?",
        suggestions: [
          'Donne-moi des conseils sur la nutrition',
          'Comment mieux dormir ?',
          'Quels sont les symptômes de la périménopause ?',
        ],
      ),
    );
  }

  void _sendMessage([String? suggestion]) async {
    final text = suggestion ?? _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(sender: 'User', content: text));
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Use the updated service to get a single future response
      final responseContent = await _reasoningEngineService.sendMessage(text);

      setState(() {
        _messages.add(ChatMessage(
          sender: 'Menovibe Agent',
          content: responseContent,
          suggestions: [
            'Autre question sur la nutrition ?',
            'Parle-moi du stress.',
            'Merci, c\'est tout.',
          ],
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            sender: 'Menovibe Agent',
            content: 'Désolé, une erreur est survenue. Veuillez réessayer.\n$e',
            isError: true));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFE0E7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildChatArea(),
                  ),
                ),
              ),
              _buildInputArea(),
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
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE0E7FF),
            child: const Icon(Icons.psychology,
                color: Color(0xFF8B5CF6), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Menovibe Agent',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'En ligne',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isLoading && index == _messages.length) {
                return _buildTypingIndicator();
              }
              final message = _messages[index];
              final isUser = message.sender == 'User';
              return _buildChatMessage(message, isUser);
            },
          ),
        ),
        if (_messages.isNotEmpty && _messages.last.suggestions != null)
          _buildSuggestions(_messages.last.suggestions!),
      ],
    );
  }

  Widget _buildChatMessage(ChatMessage message, bool isUser) {
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) ...[
          _buildAvatar(isUser: false),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFF8B5CF6)
                  : (message.isError ? Colors.red[100] : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                bottomRight: isUser
                    ? const Radius.circular(0)
                    : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : (message.isError
                        ? Colors.red[900]
                        : const Color(0xFF2C3E50)),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          _buildAvatar(isUser: true),
        ],
      ],
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    if (isUser) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFF8B5CF6),
        child: Icon(Icons.person, color: Colors.white, size: 22),
      );
    } else {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFE0E7FF),
        child: Icon(Icons.psychology, color: Color(0xFF8B5CF6), size: 22),
      );
    }
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(suggestions[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  suggestions[index],
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E7FF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _sendMessage,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(null),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernChatBubble extends StatelessWidget {
  final String sender;
  final String content;
  final bool isUser;
  final bool isStreaming;
  final bool isError;
  const _ModernChatBubble({
    required this.sender,
    required this.content,
    this.isUser = false,
    this.isStreaming = false,
    this.isError = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser
        ? const Color(0xFF8B5CF6)
        : isError
            ? Theme.of(context).colorScheme.error.withOpacity(0.1)
            : const Color(0xFFF3E8FF);
    final textColor = isUser
        ? Colors.white
        : isError
            ? Theme.of(context).colorScheme.error
            : const Color(0xFF4B5563);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE0E7FF),
              child: const Icon(Icons.psychology,
                  color: Color(0xFF8B5CF6), size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isStreaming
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          content,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const _TypingIndicator(),
                      ],
                    )
                  : Text(
                      content,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontStyle:
                            isStreaming ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({Key? key}) : super(key: key);

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value + i * 0.2) % 1.0;
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.7 - t * 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
