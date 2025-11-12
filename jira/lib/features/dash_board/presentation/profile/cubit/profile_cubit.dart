import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> loadUser(String uid) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final doc = await _db.collection('users').doc(uid).get();
      print("UID hiện tại: $uid");
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
      emit(state.copyWith(error: 'User chưa đăng nhập', loading: false));
      return;
    }
    await loadUser(user.uid);
  }
}
