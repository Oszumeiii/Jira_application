import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/chat_item_model.dart';

class ChatTabState {
  final List<ChatItemModel> allFriends;
  final List<ChatItemModel> filteredFriends;
  final List<ChatItemModel> searchResults;
  final String searchQuery;
  final bool isLoadingFriends;
  final String errorMessage;
  final bool isGlobalSearchMode;
  final bool isSearchingUsers;

  const ChatTabState({
    this.allFriends = const [],
    this.filteredFriends = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.isLoadingFriends = false,
    this.errorMessage = '',
    this.isGlobalSearchMode = false,
    this.isSearchingUsers = false,
  });

  ChatTabState copyWith({
    List<ChatItemModel>? allFriends,
    List<ChatItemModel>? filteredFriends,
    List<ChatItemModel>? searchResults,
    String? searchQuery,
    bool? isLoadingFriends,
    String? errorMessage,
    bool? isGlobalSearchMode,
    bool? isSearchingUsers,
  }) {
    return ChatTabState(
      allFriends: allFriends ?? this.allFriends,
      filteredFriends: filteredFriends ?? this.filteredFriends,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingFriends: isLoadingFriends ?? this.isLoadingFriends,
      errorMessage: errorMessage ?? this.errorMessage,
      isGlobalSearchMode: isGlobalSearchMode ?? this.isGlobalSearchMode,
      isSearchingUsers: isSearchingUsers ?? this.isSearchingUsers,
    );
  }
}
