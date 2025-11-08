import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:jira/presenation/login/cubit/login_state.dart';

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

  final Dio dio = Dio();
  Future<void> login(String email, String password) async {
    try {
      emit(state.copyWith(isloading: true));

      emit(
        state.copyWith(
          isLoginSuccess: true,
          isloading: false,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isloading: false,
          isLoginSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
