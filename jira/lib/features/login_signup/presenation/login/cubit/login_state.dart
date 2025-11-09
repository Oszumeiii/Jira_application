class LoginState {
  final String emailErr;
  final String passWordErr;
  final bool isLoginSuccess;
  final bool isloading;
  final String errorMessage;
  LoginState({
    required this.emailErr,
    required this.passWordErr,
    required this.isLoginSuccess,
    required this.isloading,
    required this.errorMessage,
  });
  LoginState copyWith({
    String? emailErr,
    String? passWordErr,
    bool? isLoginSuccess,
    bool? isloading,
    String? errorMessage,
  }) {
    return LoginState(
      emailErr: emailErr ?? this.emailErr,
      passWordErr: passWordErr ?? this.passWordErr,
      isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
      isloading: isloading ?? this.isloading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
