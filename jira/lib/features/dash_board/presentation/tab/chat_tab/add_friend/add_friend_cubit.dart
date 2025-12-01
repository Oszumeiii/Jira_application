import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jira/core/firebase_config.dart';
import 'add_friend_state.dart';

class AddFriendCubit extends Cubit<AddFriendState> {
  AddFriendCubit() : super(const AddFriendState());

  void onQueryChanged(String query) {
    final trimmed = query.trim();
    emit(state.copyWith(query: trimmed));

    if (trimmed.length >= 3) {
      _searchUsers(trimmed);
    } else {
      emit(state.copyWith(suggestions: [], message: null));
    }
  }

  Future<void> _searchUsers(String email) async {
    emit(state.copyWith(isLoading: true, message: null));

    try {
      final currentUid = FirebaseConfig.auth.currentUser!.uid;

      final snapshot = await FirebaseConfig.firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: email)
          .where('email', isLessThanOrEqualTo: '$email\uf8ff')
          .limit(10)
          .get();

      final users = <UserSuggestion>[];

      for (var doc in snapshot.docs) {
        final uid = doc.id;
        if (uid == currentUid) continue;

        final data = doc.data();
        final friends = List<String>.from(data['friends'] ?? []);
        if (friends.contains(currentUid)) continue;

        users.add(
          UserSuggestion(
            uid: uid,
            name: data['userName'] ?? data['firstName'] ?? 'Unknown',
            email: data['email'] ?? '',
            photoURL: data['photoURL'],
          ),
        );
      }

      emit(
        state.copyWith(
          suggestions: users,
          isLoading: false,
          message: users.isEmpty ? 'No users found' : null,
        ),
      );
    } catch (e, st) {
      print('[AddFriendCubit._searchUsers] $e\n$st');
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Search failed. Please try again.',
        ),
      );
    }
  }

  Future<void> sendFriendRequest(String targetUid) async {
    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
    try {
      final meUid = FirebaseConfig.auth.currentUser!.uid;
      if (meUid == targetUid) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Cannot send request to yourself',
          ),
        );
        return;
      }

      final targetRef = FirebaseConfig.firestore
          .collection('users')
          .doc(targetUid);
      final targetDoc = await targetRef.get();
      if (!targetDoc.exists) {
        emit(
          state.copyWith(isLoading: false, errorMessage: 'User does not exist'),
        );
        return;
      }

      final targetData = targetDoc.data()!;
      final targetFriends = List<String>.from(targetData['friends'] ?? []);
      if (targetFriends.contains(meUid)) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Already friends with this user',
          ),
        );
        return;
      }

      final existing = await targetRef
          .collection('notifications')
          .where('type', isEqualTo: 'friend_request')
          .where('fromUid', isEqualTo: meUid)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Friend request already sent',
          ),
        );
        return;
      }

      final meDoc = await FirebaseConfig.firestore
          .collection('users')
          .doc(meUid)
          .get();
      final meName = meDoc.data()?['userName'] ?? '';
      final mePhoto = meDoc.data()?['photoURL'];

      final payload = {
        'type': 'friend_request',
        'fromUid': meUid,
        'fromName': meName,
        'fromPhoto': mePhoto,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await targetRef.collection('notifications').add(payload);

      emit(
        state.copyWith(isLoading: false, successMessage: 'Friend request sent'),
      );
    } catch (e, st) {
      print('[AddFriendCubit.sendFriendRequest] $e\n$st');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to send request: $e',
        ),
      );
    }
  }

  void clearMessage() {
    emit(
      state.copyWith(message: null, errorMessage: null, successMessage: null),
    );
  }
}
