// features/chat_detail/cubit/chat_detail_state.dart

class ChatMessage {
  final String id;
  final String text;
  final String from;
  final DateTime time;
  final bool isSystem;
  final String? senderName;
  final String? senderPhotoURL;

  ChatMessage({
    required this.id,
    required this.text,
    required this.from,
    required this.time,
    this.isSystem = false,
    this.senderName,
    this.senderPhotoURL,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ChatDetailState {
  final String chatId;
  final String chatName;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? sendingError;
  final bool isTyping;
  final String currentUserUid; // Lưu UID hiện tại

  const ChatDetailState({
    required this.chatId,
    required this.chatName,
    this.messages = const [],
    this.isLoading = false,
    this.sendingError,
    this.isTyping = false,
    required this.currentUserUid,
  });

  ChatDetailState copyWith({
    String? chatId,
    String? chatName,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? sendingError,
    bool? isTyping,
    String? currentUserUid,
  }) {
    return ChatDetailState(
      chatId: chatId ?? this.chatId,
      chatName: chatName ?? this.chatName,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sendingError: sendingError,
      isTyping: isTyping ?? this.isTyping,
      currentUserUid: currentUserUid ?? this.currentUserUid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatDetailState &&
          runtimeType == other.runtimeType &&
          chatId == other.chatId &&
          chatName == other.chatName &&
          _listEquals(messages, other.messages) &&
          isLoading == other.isLoading &&
          sendingError == other.sendingError &&
          isTyping == other.isTyping &&
          currentUserUid == other.currentUserUid;

  @override
  int get hashCode => Object.hash(
    chatId,
    chatName,
    Object.hashAll(messages),
    isLoading,
    sendingError,
    isTyping,
    currentUserUid,
  );

  bool _listEquals(List<ChatMessage> a, List<ChatMessage> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
