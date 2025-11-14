// features/add_friend/cubit/add_friend_state.dart
class UserSuggestion {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;

  UserSuggestion({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
  });

  // Để so sánh khi rebuild
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSuggestion &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          name == other.name &&
          email == other.email &&
          photoURL == other.photoURL;

  @override
  int get hashCode => Object.hash(uid, name, email, photoURL);
}

class AddFriendState {
  final String query;
  final List<UserSuggestion> suggestions;
  final bool isLoading;
  final String? message;

  const AddFriendState({
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.message,
  });

  // CopyWith thủ công
  AddFriendState copyWith({
    String? query,
    List<UserSuggestion>? suggestions,
    bool? isLoading,
    String? message,
  }) {
    return AddFriendState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }

  // So sánh để tránh rebuild thừa
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddFriendState &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          _listEquals(suggestions, other.suggestions) &&
          isLoading == other.isLoading &&
          message == other.message;

  @override
  int get hashCode =>
      Object.hash(query, Object.hashAll(suggestions), isLoading, message);

  // Helper để so sánh list
  bool _listEquals(List<UserSuggestion> a, List<UserSuggestion> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
