// features/dash_board/presentation/profile/cubit/profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jira/core/firebase_config.dart';
import 'dart:io';
import 'dart:typed_data';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> loadUser(String uid) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        emit(state.copyWith(userData: doc.data(), loading: false));
      } else {
        emit(state.copyWith(error: 'User not found', loading: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(error: 'Chưa đăng nhập', loading: false));
      return;
    }
    await loadUser(user.uid);
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? userName,
    String? photoURL,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    emit(state.copyWith(loading: true, error: null));
    try {
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (userName != null) {
        updateData['userName'] = userName;
        updateData['userNameLower'] = userName.toLowerCase();
      }
      if (photoURL != null) updateData['photoURL'] = photoURL;

      if (updateData.isNotEmpty) {
        await _db.collection('users').doc(user.uid).update(updateData);
        await loadUser(user.uid);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi cập nhật: $e', loading: false));
    }
  }

  // Mobile: File
  Future<String?> uploadAvatar(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      emit(state.copyWith(loading: true, error: null));
      final fileName =
          'avatars/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseConfig.storage.ref().child(fileName);
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      await updateProfile(photoURL: url);
      return url;
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi upload: $e', loading: false));
      return null;
    }
  }

  // Web: Uint8List
  Future<String?> uploadAvatarWeb(Uint8List bytes, String fileName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      emit(state.copyWith(loading: true, error: null));
      final path = 'avatars/${user.uid}_$fileName';
      final ref = FirebaseConfig.storage.ref().child(path);
      await ref.putData(bytes);
      final url = await ref.getDownloadURL();
      await updateProfile(photoURL: url);
      return url;
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi upload web: $e', loading: false));
      return null;
    }
  }
}
