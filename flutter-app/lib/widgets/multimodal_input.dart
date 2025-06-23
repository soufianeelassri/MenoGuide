import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';

class MultimodalInput extends StatefulWidget {
  final Function(
          String content, MessageType type, String? imageUrl, String? audioUrl)
      onSendMessage;

  const MultimodalInput({
    Key? key,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  State<MultimodalInput> createState() => _MultimodalInputState();
}

class _MultimodalInputState extends State<MultimodalInput> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isRecording = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildAttachmentButton(),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextInput(),
            ),
            const SizedBox(width: 8),
            _buildVoiceButton(),
            const SizedBox(width: 8),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return IconButton(
      onPressed: _pickImage,
      icon: const Icon(
        Icons.attach_file,
        color: Color(0xFF8B5CF6),
      ),
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: 'Type your message...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      onSubmitted: (text) {
        if (text.trim().isNotEmpty) {
          _sendTextMessage(text);
        }
      },
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: () => _stopRecording(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : const Color(0xFF8B5CF6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final hasText = _textController.text.trim().isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: hasText ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: hasText
            ? () => _sendTextMessage(_textController.text.trim())
            : null,
        icon: const Icon(
          Icons.send,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _sendTextMessage(String text) {
    if (text.trim().isNotEmpty) {
      widget.onSendMessage(text.trim(), MessageType.text, null, null);
      _textController.clear();
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        // In a real app, you would upload the image to a server
        // For now, we'll just send the file path as a mock
        widget.onSendMessage(
          'Image shared',
          MessageType.image,
          image.path,
          null,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    // In a real app, you would start recording audio here
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });

    // In a real app, you would stop recording and send the audio
    // For now, we'll just send a mock audio message
    widget.onSendMessage(
      'Voice message',
      MessageType.audio,
      null,
      'mock_audio_path',
    );
  }
}
