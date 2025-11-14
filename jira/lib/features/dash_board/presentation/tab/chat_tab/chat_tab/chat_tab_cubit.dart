import 'package:bloc/bloc.dart';

import 'package:jira/core/firebase_config.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/chat_item_model.dart';
import 'chat_tab_state.dart';

class ChatTabCubit extends Cubit<ChatTabState> {
  ChatTabCubit() : super(const ChatTabState()) {
    _loadFriends();
  }

  // tìm trong danh sách bạn bè đã load
  void searchFriends(String query) {
    final q = query.trim().toLowerCase();
    emit(state.copyWith(searchQuery: query));

    if (q.isEmpty) {
      emit(state.copyWith(filteredFriends: state.allFriends));
      return;
    }

    final filtered = state.allFriends.where((friend) {
      final name = (friend.name ?? '').toLowerCase();
      final email = (friend.email ?? '').toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    emit(state.copyWith(filteredFriends: filtered));
  }

  // tìm users (kể cả chưa là bạn bè) bằng range query trên userName
  Future<void> searchUsers(String query) async {
    emit(state.copyWith(searchQuery: query));

    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    try {
      final q = query.trim().toLowerCase();
      final uid = FirebaseConfig.auth.currentUser!.uid;

      final snapshot = await FirebaseConfig.firestore
          .collection('users')
          .orderBy('emailLower')
          .startAt([q])
          .endAt([q + '\uf8ff'])
          .limit(30)
          .get();

      final results = snapshot.docs
          .where((d) => d.id != uid) // bỏ bản thân
          .map((d) {
            final data = d.data();
            return ChatItemModel(
              id: d.id,
              name: data['userName'] ?? data['firstName'] ?? '',
              email: data['email'] ?? '',
              photoURL: data['photoURL'],
              isGroup: false,
              members: [uid, d.id],
              isOnline: data['online'] ?? false,
            );
          })
          .toList();

      emit(state.copyWith(searchResults: results));
    } catch (e) {
      print("Error searching users: $e");
      emit(state.copyWith(searchResults: []));
    }
  }

  Future<void> _loadFriends() async {
    emit(state.copyWith(isLoadingFriends: true));
    try {
      final uid = FirebaseConfig.auth.currentUser!.uid;
      final userDoc = await FirebaseConfig.firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        emit(state.copyWith(isLoadingFriends: false));
        return;
      }

      final friendIds = List<String>.from(userDoc['friends'] ?? []);
      final friends = <ChatItemModel>[];

      for (var friendId in friendIds) {
        try {
          final friendDoc = await FirebaseConfig.firestore
              .collection('users')
              .doc(friendId)
              .get();

          if (friendDoc.exists) {
            final friendData = friendDoc.data()!;
            friends.add(
              ChatItemModel(
                id: friendId,
                name:
                    friendData['userName'] ??
                    friendData['firstName'] ??
                    'Unknown',
                email: friendData['email'] ?? '',
                photoURL: friendData['photoURL'],
                isGroup: false,
                members: [uid, friendId],
                isOnline: friendData['online'] ?? false,
              ),
            );
          }
        } catch (e) {
          print('Error loading friend $friendId: $e');
        }
      }

      emit(
        state.copyWith(
          allFriends: friends,
          filteredFriends: friends,
          isLoadingFriends: false,
        ),
      );
    } catch (e) {
      print('Error loading friends: $e');
      emit(
        state.copyWith(
          errorMessage: 'Lỗi tải bạn bè: $e',
          isLoadingFriends: false,
        ),
      );
    }
  }

  Future<void> refreshFriends() async {
    await _loadFriends();
  }
}
