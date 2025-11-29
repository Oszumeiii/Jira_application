import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jira/core/firebase_config.dart';
import 'create_group_state.dart';
import 'dart:async';

class CreateGroupCubit extends Cubit<CreateGroupState> {
  CreateGroupCubit() : super(const CreateGroupState()) {
    _loadFriends();
  }

  Timer? _searchTimer;

  void onGroupNameChanged(String name) =>
      emit(state.copyWith(groupName: name, errorMessage: ''));

  Future<void> searchUsers(String query) async {
    final q = query.trim();
    _searchTimer?.cancel();

    if (q.isEmpty) {
      await _loadFriends();
      return;
    }

    if (q.length < 2) {
      emit(state.copyWith(friends: [], isLoading: false, errorMessage: ''));
      return;
    }

    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSearch(q);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final me = FirebaseConfig.auth.currentUser!.uid;
      final results = <Friend>[];

      final emailQuery = query.toLowerCase();

      try {
        final snapshot = await FirebaseConfig.firestore
            .collection('users')
            .where('email', isGreaterThanOrEqualTo: emailQuery)
            .where('email', isLessThanOrEqualTo: '$emailQuery\uf8ff')
            .limit(30)
            .get();

        for (var doc in snapshot.docs) {
          if (doc.id == me) continue;
          final data = doc.data();
          final email = (data['email'] ?? '').toString().toLowerCase();
          if (email.contains(emailQuery)) {
            results.add(
              Friend(
                uid: doc.id,
                name: data['userName'] ?? data['firstName'] ?? '',
                email: data['email'] ?? '',
                photoURL: data['photoURL'],
              ),
            );
          }
        }
      } catch (e) {
        if (e.toString().contains('index')) {
          try {
            final allUsers = await FirebaseConfig.firestore
                .collection('users')
                .limit(100)
                .get();

            for (var doc in allUsers.docs) {
              if (doc.id == me) continue;
              final data = doc.data();
              final email = (data['email'] ?? '').toString().toLowerCase();
              if (email.contains(emailQuery)) {
                results.add(
                  Friend(
                    uid: doc.id,
                    name: data['userName'] ?? data['firstName'] ?? '',
                    email: data['email'] ?? '',
                    photoURL: data['photoURL'],
                  ),
                );
              }
            }
          } catch (_) {}
        } else {
          rethrow;
        }
      }

      emit(
        state.copyWith(friends: results, isLoading: false, errorMessage: ''),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error searching users: $e',
          friends: [],
        ),
      );
    }
  }

  void toggleFriend(String uid) {
    final selected = List<String>.from(state.selectedFriendIds);
    if (selected.contains(uid)) {
      selected.remove(uid);
    } else {
      selected.add(uid);
    }
    emit(state.copyWith(selectedFriendIds: selected));
  }

  Future<void> _loadFriends() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      final uid = FirebaseConfig.auth.currentUser!.uid;
      final userDoc = await FirebaseConfig.firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        emit(state.copyWith(friends: [], isLoading: false));
        return;
      }

      final friendIds = List<String>.from(userDoc.data()?['friends'] ?? []);
      final friends = <Friend>[];

      for (var friendId in friendIds) {
        try {
          final friendDoc = await FirebaseConfig.firestore
              .collection('users')
              .doc(friendId)
              .get();

          if (friendDoc.exists) {
            final friendData = friendDoc.data()!;
            friends.add(
              Friend(
                uid: friendId,
                name: friendData['userName'] ?? friendData['firstName'] ?? '',
                email: friendData['email'] ?? '',
                photoURL: friendData['photoURL'],
              ),
            );
          }
        } catch (_) {}
      }

      emit(state.copyWith(friends: friends, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error loading friends: $e',
        ),
      );
    }
  }

  Future<void> createGroup() async {
    final name = state.groupName.trim();
    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter a group name'));
      return;
    }
    if (state.selectedFriendIds.isEmpty) {
      emit(state.copyWith(errorMessage: 'Select at least 1 member'));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final uid = FirebaseConfig.auth.currentUser!.uid;
      final members = <String>[uid, ...state.selectedFriendIds];

      await FirebaseConfig.firestore.collection('chats').add({
        'name': name,
        'isGroup': true,
        'members': members,
        'admin': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'photoURL': null,
      });

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create group: $e',
        ),
      );
    }
  }

  void resetSuccess() {
    emit(state.copyWith(isSuccess: false));
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
