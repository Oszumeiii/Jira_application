import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/chat_item_model.dart';

class ChatTabState {
  final List<ChatItemModel> allFriends;
  final List<ChatItemModel> filteredFriends;
  final List<ChatItemModel>
  searchResults; // kết quả tìm kiếm users (không chỉ bạn bè)
  final String searchQuery;
  final bool isLoadingFriends;
  final String errorMessage;

  const ChatTabState({
    this.allFriends = const [],
    this.filteredFriends = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.isLoadingFriends = false,
    this.errorMessage = '',
  });

  ChatTabState copyWith({
    List<ChatItemModel>? allFriends,
    List<ChatItemModel>? filteredFriends,
    List<ChatItemModel>? searchResults,
    String? searchQuery,
    bool? isLoadingFriends,
    String? errorMessage,
  }) {
    return ChatTabState(
      allFriends: allFriends ?? this.allFriends,
      filteredFriends: filteredFriends ?? this.filteredFriends,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingFriends: isLoadingFriends ?? this.isLoadingFriends,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
