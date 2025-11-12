import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/login_signup/presenation/login/cubit/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit()
    : super(
        ForgotPasswordState(
          emailErr: '',
          isLoading: false,
          isSuccess: false,
          errorMessage: '',
          email: '',
        ),
      );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _verifyEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void onEmailChanged(String email) {
    if (!_verifyEmail(email)) {
      emit(state.copyWith(emailErr: 'Email không hợp lệ'));
    } else {
      emit(state.copyWith(emailErr: ''));
    }
  }

  Future<void> sendResetEmail(String email) async {
    if (state.emailErr.isNotEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));

    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(state.copyWith(isLoading: false, isSuccess: true, email: email));
    } on FirebaseAuthException catch (e) {
      String msg = '';
      if (e.code == 'user-not-found') {
        msg = 'Không tìm thấy tài khoản với email này';
      } else if (e.code == 'invalid-email') {
        msg = 'Email không hợp lệ';
      } else {
        msg = e.message ?? 'Gửi thất bại';
      }
      emit(state.copyWith(isLoading: false, errorMessage: msg));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi kết nối. Vui lòng thử lại.',
        ),
      );
    }
  }

  void reset() {
    emit(state.copyWith(isSuccess: false, errorMessage: ''));
  }

  void resetError() {
    emit(state.copyWith(errorMessage: ''));
  }
}
