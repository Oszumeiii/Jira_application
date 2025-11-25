import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/message_model.dart';

class ChatDetailState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isTyping;
  final String errorMessage;

  const ChatDetailState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.errorMessage = '',
  });

  ChatDetailState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isTyping,
    String? errorMessage,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
