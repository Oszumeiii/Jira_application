// features/dash_board/presentation/tab/chat_tab/add_friend/add_friend_state.dart
import 'package:equatable/equatable.dart';

class AddFriendState extends Equatable {
  final String query;
  final List<UserSuggestion> suggestions;
  final bool isLoading;
  final String? message;
  final String? errorMessage;
  final String? successMessage;

  const AddFriendState({
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.message,
    this.errorMessage,
    this.successMessage,
  });

  AddFriendState copyWith({
    String? query,
    List<UserSuggestion>? suggestions,
    bool? isLoading,
    String? message,
    String? errorMessage,
    String? successMessage,
  }) {
    return AddFriendState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    query,
    suggestions,
    isLoading,
    message,
    errorMessage,
    successMessage,
  ];
}

class UserSuggestion extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;

  const UserSuggestion({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
  });

  @override
  List<Object?> get props => [uid, name, email, photoURL];
}
