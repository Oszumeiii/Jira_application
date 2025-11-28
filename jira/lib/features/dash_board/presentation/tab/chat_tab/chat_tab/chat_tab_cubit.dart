import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jira/core/firebase_config.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/chat_item_model.dart';
import 'chat_tab_state.dart';

class ChatTabCubit extends Cubit<ChatTabState> {
  ChatTabCubit() : super(const ChatTabState()) {
    _loadFriends();
  }

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
          .orderBy('userName')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(30)
          .get();

      final results = snapshot.docs.where((d) => d.id != uid).map((d) {
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
      }).toList();

      emit(state.copyWith(searchResults: results));
    } catch (e) {
      print("Error searching users: $e");
      emit(state.copyWith(searchResults: []));
    }
  }

  void fixGroupSearchKey() async {
    final chatsSnapshot = await FirebaseConfig.firestore
        .collection('chats')
        .where('isGroup', isEqualTo: true)
        .get();

    final batch = FirebaseConfig.firestore.batch();
    int count = 0;

    for (var doc in chatsSnapshot.docs) {
      final data = doc.data();
      final groupName = (data['name'] as String?) ?? '';

      if (groupName.isNotEmpty) {
        final searchKey = groupName
            .toLowerCase()
            .replaceAll('đ', 'd')
            .replaceAll(RegExp(r'[àáảãạăắằẳẵặâấầẩẫậ]'), 'a')
            .replaceAll(RegExp(r'[èéẻẽẹêếềểễệ]'), 'e')
            .replaceAll(RegExp(r'[ìíỉĩị]'), 'i')
            .replaceAll(RegExp(r'[òóỏõọôốồổỗộơớờởỡợ]'), 'o')
            .replaceAll(RegExp(r'[ùúủũụưứừửữự]'), 'u')
            .replaceAll(' ', '');

        batch.update(doc.reference, {'nameSearch': searchKey});
        count++;
      }
    }

    if (count > 0) await batch.commit();
    print("Đã thêm nameSearch cho $count nhóm");
  }

  Future<void> searchAll(String query) async {
    emit(state.copyWith(searchQuery: query));

    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    final q = query
        .trim()
        .toLowerCase()
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'[àáảãạăắằẳẵặâấầẩẫậ]'), 'a')
        .replaceAll(RegExp(r'[èéẻẽẹêếềểễệ]'), 'e')
        .replaceAll(RegExp(r'[ìíỉĩị]'), 'i')
        .replaceAll(RegExp(r'[òóỏõọôốồổỗộơớờởỡợ]'), 'o')
        .replaceAll(RegExp(r'[ùúủũụưứừửữự]'), 'u')
        .replaceAll(' ', '');

    final uid = FirebaseConfig.auth.currentUser!.uid;
    final results = <ChatItemModel>[];

    try {
      // 1. Tìm người dùng
      final userSnapshot = await FirebaseConfig.firestore
          .collection('users')
          .orderBy('userNameSearch')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(20)
          .get();

      for (var doc in userSnapshot.docs) {
        if (doc.id == uid) continue;
        results.add(ChatItemModel.fromUserDoc(doc));
      }

      final groupSnapshot = await FirebaseConfig.firestore
          .collection('chats')
          .where('isGroup', isEqualTo: true)
          .orderBy('nameSearch')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(20)
          .get();

      for (var doc in groupSnapshot.docs) {
        results.add(ChatItemModel.fromChatDoc(doc));
      }

      emit(state.copyWith(searchResults: results));
    } catch (e) {
      print("Search error: $e");
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

      if (friendIds.isEmpty) {
        emit(
          state.copyWith(
            allFriends: [],
            filteredFriends: [],
            isLoadingFriends: false,
          ),
        );
        return;
      }

      final friends = <ChatItemModel>[];

      for (var i = 0; i < friendIds.length; i += 10) {
        final chunk = friendIds.sublist(
          i,
          i + 10 > friendIds.length ? friendIds.length : i + 10,
        );

        final snapshot = await FirebaseConfig.firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();

          friends.add(
            ChatItemModel(
              id: doc.id,
              name: data['userName'] ?? data['firstName'] ?? 'Unknown',
              email: data['email'] ?? '',
              photoURL: data['photoURL'],
              isGroup: false,
              members: [uid, doc.id],
              isOnline: data['online'] ?? false,
            ),
          );
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
      print("Error loading friends: $e");
      emit(
        state.copyWith(
          errorMessage: "Lỗi tải bạn bè: $e",
          isLoadingFriends: false,
        ),
      );
    }
  }

  Future<void> refreshFriends() async {
    await _loadFriends();
  }
}
