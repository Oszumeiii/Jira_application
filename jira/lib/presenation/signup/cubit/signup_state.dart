class SignUpState {
  final String emailErr;
  final String passWordErr;
  final String unameErr;
  final bool isSignUpSuccess;
  final bool isloading;
  final String errorMessage;
  SignUpState({
    required this.emailErr,
    required this.passWordErr,
    required this.unameErr,
    required this.isSignUpSuccess,
    required this.isloading,
    required this.errorMessage,
  });
  SignUpState copyWith({
    String? emailErr,
    String? passWordErr,
    String? unameErr,
    bool? isSignUpSuccess,
    bool? isloading,
    String? errorMessage,
  }) {
    return SignUpState(
      emailErr: emailErr ?? this.emailErr,
      passWordErr: passWordErr ?? this.passWordErr,
      unameErr: unameErr ?? this.unameErr,
      isSignUpSuccess: isSignUpSuccess ?? this.isSignUpSuccess,
      isloading: isloading ?? this.isloading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}