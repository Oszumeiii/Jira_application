import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/presenation/signup/cubit/signup_state.dart';

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

  final Dio dio = Dio();

  void SignUp(
    String firstName,
    String lastName,
    String email,
    String passWord,
    String userName,
  ) async {
    emit(state.copyWith(errorMessage: '', isSignUpSuccess: true));
  }
}
