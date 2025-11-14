// features/add_friend/cubit/add_friend_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_friend_state.dart';

class AddFriendCubit extends Cubit<AddFriendState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _debounce;

  AddFriendCubit() : super(const AddFriendState());

  void onQueryChanged(String query) {
    emit(state.copyWith(query: query, message: null));

    if (query.isEmpty || query.length < 2) {
      emit(state.copyWith(suggestions: [], isLoading: false));
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchUsers(query.trim());
    });
  }

  Future<void> _searchUsers(String query) async {
    emit(state.copyWith(isLoading: true, suggestions: []));

    try {
      final currentUid = _auth.currentUser!.uid;

      final snapshot = await _db
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(5)
          .get();

      final currentDoc = await _db.collection('users').doc(currentUid).get();
      final friends = List<String>.from(currentDoc['friends'] ?? []);

      final suggestions = <UserSuggestion>[];
      for (var doc in snapshot.docs) {
        final uid = doc.id;
        if (uid == currentUid || friends.contains(uid)) continue;

        final data = doc.data();
        suggestions.add(
          UserSuggestion(
            uid: uid,
            name: data['name'] ?? 'Unknown',
            email: data['email'],
            photoURL: data['photoURL'],
          ),
        );
      }

      emit(state.copyWith(isLoading: false, suggestions: suggestions));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Tìm kiếm thất bại. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> addFriend(String friendUid) async {
    emit(state.copyWith(isLoading: true, message: null));

    try {
      final currentUid = _auth.currentUser!.uid;

      final currentDoc = await _db.collection('users').doc(currentUid).get();
      final friends = List<String>.from(currentDoc['friends'] ?? []);
      if (friends.contains(friendUid)) {
        emit(
          state.copyWith(
            isLoading: false,
            message: 'Bạn đã là bạn bè với người này.',
          ),
        );
        return;
      }

      await Future.wait([
        _db.collection('users').doc(currentUid).update({
          'friends': FieldValue.arrayUnion([friendUid]),
        }),
        _db.collection('users').doc(friendUid).update({
          'friends': FieldValue.arrayUnion([currentUid]),
        }),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          message: 'Đã thêm bạn thành công!',
          query: '',
          suggestions: [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, message: 'Lỗi: Không thể thêm bạn.'),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
