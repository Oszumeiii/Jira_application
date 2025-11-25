// features/dash_board/presentation/tab/chat_tab/create_group/create_group_state.dart
import 'package:equatable/equatable.dart';

class CreateGroupState extends Equatable {
  final String groupName;
  final List<Friend> friends;
  final List<Friend> searchResults;
  final List<String> selectedFriendIds;
  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;

  const CreateGroupState({
    this.groupName = '',
    this.friends = const [],
    this.searchResults = const [],
    this.selectedFriendIds = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
  });

  CreateGroupState copyWith({
    String? groupName,
    List<Friend>? friends,
    List<Friend>? searchResults,
    List<String>? selectedFriendIds,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return CreateGroupState(
      groupName: groupName ?? this.groupName,
      friends: friends ?? this.friends,
      searchResults: searchResults ?? this.searchResults,
      selectedFriendIds: selectedFriendIds ?? this.selectedFriendIds,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    groupName,
    friends,
    searchResults,
    selectedFriendIds,
    isLoading,
    isSuccess,
    errorMessage,
  ];
}

class Friend {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;

  Friend({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
  });
}
