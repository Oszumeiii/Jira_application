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
    
    // Hủy timer trước đó nếu có
    _searchTimer?.cancel();
    
    if (q.isEmpty) {
      await _loadFriends();
      return;
    }

    // Chỉ tìm kiếm nếu query có ít nhất 2 ký tự
    if (q.length < 2) {
      emit(state.copyWith(friends: [], isLoading: false, errorMessage: ''));
      return;
    }

    // Debounce: đợi 300ms sau khi người dùng ngừng gõ
    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSearch(q);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final me = FirebaseConfig.auth.currentUser!.uid;
      final results = <Friend>[];

      // Tìm kiếm theo email (prefix search)
      // Tương tự như add_friend_cubit.dart
      final emailQuery = query.toLowerCase();
      
      try {
        final snapshot = await FirebaseConfig.firestore
            .collection('users')
            .where('email', isGreaterThanOrEqualTo: emailQuery)
            .where('email', isLessThanOrEqualTo: '$emailQuery\uf8ff')
            .limit(30)
            .get();

        print('[CreateGroupCubit] Found ${snapshot.docs.length} users matching email: $emailQuery');

        for (var doc in snapshot.docs) {
          if (doc.id == me) continue; // Bỏ qua chính mình
          final data = doc.data();
          final email = (data['email'] ?? '').toString().toLowerCase();
          
          // Kiểm tra email có chứa query không (case-insensitive)
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
        print('[CreateGroupCubit._performSearch] Email search error: $e');
        // Nếu lỗi do index, thử cách khác
        if (e.toString().contains('index')) {
          // Fallback: lấy tất cả users và filter ở client (chỉ dùng khi ít users)
          try {
            final allUsers = await FirebaseConfig.firestore
                .collection('users')
                .limit(100)
                .get();
            
            final emailQuery = query.toLowerCase();
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
          } catch (e2) {
            print('[CreateGroupCubit._performSearch] Fallback error: $e2');
          }
        } else {
          rethrow;
        }
      }

      print('[CreateGroupCubit._performSearch] Returning ${results.length} results');
      emit(
        state.copyWith(friends: results, isLoading: false, errorMessage: ''),
      );
    } catch (e) {
      print('[CreateGroupCubit._performSearch] Error: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tìm người: $e',
        friends: [],
      ));
    }
  }

  void toggleFriend(String uid) {
    final selected = List<String>.from(state.selectedFriendIds);
    if (selected.contains(uid))
      selected.remove(uid);
    else
      selected.add(uid);
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

      // Lấy danh sách friendIds từ mảng friends trong user document
      final friendIds = List<String>.from(userDoc.data()?['friends'] ?? []);
      final friends = <Friend>[];

      // Load thông tin từng friend
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
                name: friendData['userName'] ??
                     friendData['firstName'] ??
                     '',
                email: friendData['email'] ?? '',
                photoURL: friendData['photoURL'],
              ),
            );
          }
        } catch (e) {
          print('[CreateGroupCubit._loadFriends] Error loading friend $friendId: $e');
        }
      }

      emit(state.copyWith(friends: friends, isLoading: false));
    } catch (e) {
      print('[CreateGroupCubit._loadFriends] $e');
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Lỗi tải bạn bè: $e'),
      );
    }
  }

  Future<void> createGroup() async {
    final name = state.groupName.trim();
    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập tên nhóm'));
      return;
    }
    if (state.selectedFriendIds.isEmpty) {
      emit(state.copyWith(errorMessage: 'Chọn ít nhất 1 thành viên'));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final uid = FirebaseConfig.auth.currentUser!.uid;
      final members = <String>[uid]..addAll(state.selectedFriendIds);

      final docRef = await FirebaseConfig.firestore.collection('chats').add({
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
      print('Created group ${docRef.id}');
    } catch (e) {
      print('[CreateGroupCubit.createGroup] $e');
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Tạo nhóm thất bại: $e'),
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
