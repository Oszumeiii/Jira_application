import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/login_signup/presenation/login/cubit/login_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit()
    : super(
        LoginState(
          emailErr: '',
          passWordErr: '',
          isLoginSuccess: false,
          isloading: false,
          errorMessage: '',
        ),
      );
  bool verifyEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  void onchangeEmail(String email) {
    if (!verifyEmail(email)) {
      emit(state.copyWith(emailErr: 'Email không hợp lệ'));
    } else {
      emit(state.copyWith(emailErr: ''));
    }
  }

  bool verifyPassword(String passWord) {
    return passWord.length > 5;
  }

  void onchangePassword(String passWord) {
    if (!verifyPassword(passWord)) {
      emit(state.copyWith(passWordErr: 'Mật khẩu không hợp lệ'));
    } else {
      emit(state.copyWith(passWordErr: ''));
    }
  }

  void resetLoginSuccess() {
    emit(state.copyWith(isLoginSuccess: false));
  }

  void resetErrorMessage() {
    emit(state.copyWith(errorMessage: ''));
  }

  Future<void> login(String email, String password) async {
    if (state.emailErr.isEmpty && state.passWordErr.isEmpty) {
      emit(state.copyWith(isloading: true));
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();

          emit(
            state.copyWith(
              isloading: false,
              isLoginSuccess: false,
              errorMessage:
                  'Vui lòng xác minh email trước khi đăng nhập. '
                  'Chúng tôi đã gửi lại link xác minh đến $email.',
            ),
          );
          return;
        }

        final uid = user!.uid;
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        final snapshot = await userDoc.get();

        if (!snapshot.exists) {
          await userDoc.set({
            'uid': uid,
            'email': email,
            'firstName': '',
            'lastName': '',
            'userName': email.split('@')[0],
            'photoURL': 'https://i.pravatar.cc/150?u=$uid',
            'friends': <String>[],
            'online': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Cập nhật online
          await userDoc.update({'online': true});
        }

        String? token = await user.getIdToken();
        if (token != null) {
          final storage = FlutterSecureStorage();
          await storage.write(key: 'idToken', value: token);
        }

        emit(
          state.copyWith(
            isloading: false,
            isLoginSuccess: true,
            errorMessage: '',
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMsg = '';
        if (e.code == 'user-not-found') {
          errorMsg = 'Không tìm thấy người dùng';
        } else if (e.code == 'wrong-password') {
          errorMsg = 'Sai mật khẩu';
        } else if (e.code == 'too-many-requests') {
          errorMsg = 'Quá nhiều lần thử. Vui lòng thử lại sau.';
        } else {
          errorMsg = e.message ?? 'Lỗi đăng nhập';
        }

        emit(
          state.copyWith(
            isloading: false,
            isLoginSuccess: false,
            errorMessage: errorMsg,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            isloading: false,
            isLoginSuccess: false,
            errorMessage: 'Lỗi kết nối. Vui lòng kiểm tra mạng.',
          ),
        );
      }
    }
  }
}
