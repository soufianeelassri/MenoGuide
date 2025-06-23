import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/message.dart';
import '../models/agent.dart';
import '../services/chat_service.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String content;
  final MessageType type;
  final String? imageUrl;
  final String? audioUrl;

  const SendMessage({
    required this.content,
    this.type = MessageType.text,
    this.imageUrl,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [content, type, imageUrl, audioUrl];
}

class SwitchAgent extends ChatEvent {
  final Agent agent;

  const SwitchAgent(this.agent);

  @override
  List<Object?> get props => [agent];
}

class LoadChatHistory extends ChatEvent {}

class ClearChat extends ChatEvent {}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final Agent currentAgent;
  final bool isLoading;

  const ChatLoaded({
    required this.messages,
    required this.currentAgent,
    this.isLoading = false,
  });

  ChatLoaded copyWith({
    List<Message>? messages,
    Agent? currentAgent,
    bool? isLoading,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      currentAgent: currentAgent ?? this.currentAgent,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, currentAgent, isLoading];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;

  ChatBloc({required ChatService chatService})
      : _chatService = chatService,
        super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<SwitchAgent>(_onSwitchAgent);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<ClearChat>(_onClearChat);
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // Add user message
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: event.content,
        type: event.type,
        isUser: true,
        timestamp: DateTime.now(),
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
      );

      final updatedMessages = [...currentState.messages, userMessage];
      emit(currentState.copyWith(
        messages: updatedMessages,
        isLoading: true,
      ));

      try {
        // Get agent response
        final agentResponse = await _chatService.getAgentResponse(
          event.content,
          currentState.currentAgent,
          event.type,
        );

        final agentMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: agentResponse.content,
          type: agentResponse.type,
          sender: currentState.currentAgent,
          isUser: false,
          timestamp: DateTime.now(),
          imageUrl: agentResponse.imageUrl,
          audioUrl: agentResponse.audioUrl,
        );

        final finalMessages = [...updatedMessages, agentMessage];
        emit(currentState.copyWith(
          messages: finalMessages,
          isLoading: false,
        ));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }

  void _onSwitchAgent(SwitchAgent event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // Add system message about agent switch
      final switchMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Switching to ${event.agent.name}...',
        type: MessageType.text,
        sender: Agent.maestro,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...currentState.messages, switchMessage];
      emit(currentState.copyWith(
        messages: updatedMessages,
        currentAgent: event.agent,
      ));
    }
  }

  void _onLoadChatHistory(LoadChatHistory event, Emitter<ChatState> emit) {
    emit(ChatLoaded(
      messages: [],
      currentAgent: Agent.maestro,
    ));
  }

  void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
    emit(ChatLoaded(
      messages: [],
      currentAgent: Agent.maestro,
    ));
  }
}
