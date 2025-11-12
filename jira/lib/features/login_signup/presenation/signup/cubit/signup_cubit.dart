import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/login_signup/presenation/signup/cubit/signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit()
    : super(
        SignUpState(
          emailErr: '',
          passWordErr: '',
          unameErr: '',
          isSignUpSuccess: false,
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

  bool verifyuname(String uname) {
    return uname.isNotEmpty;
  }

  void onchangeUname(String uname) {
    if (!verifyuname(uname)) {
      emit(state.copyWith(unameErr: 'Username không hợp lệ'));
    } else {
      emit(state.copyWith(unameErr: ''));
    }
  }

  void resetLoginSuccess() {
    emit(state.copyWith(isSignUpSuccess: false));
  }

  void resetErrorMessage() {
    emit(state.copyWith(errorMessage: ''));
  }

  Future<void> SignUp(
    String firstName,
    String lastName,
    String email,
    String passWord,
    String userName,
  ) async {
    emit(
      state.copyWith(errorMessage: '', isloading: true),
    ); // Sửa: thêm isloading = true

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: passWord);

      User? user = userCredential.user;

      // GỬI EMAIL XÁC MINH
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      // Lưu dữ liệu người dùng vào Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'userName': userName,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'role': 'member',
        'emailVerified': false, // Thêm trường này
      });

      emit(
        state.copyWith(
          isloading: false,
          isSignUpSuccess: true,
          errorMessage: '',
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = '';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Email đã được sử dụng';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Email không hợp lệ';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Mật khẩu quá yếu';
      } else {
        errorMsg = e.message ?? 'Lỗi đăng ký';
      }
      emit(
        state.copyWith(
          isloading: false,
          isSignUpSuccess: false,
          errorMessage: errorMsg,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isloading: false,
          isSignUpSuccess: false,
          errorMessage: 'Đã xảy ra lỗi kết nối',
        ),
      );
    }
  }
}
