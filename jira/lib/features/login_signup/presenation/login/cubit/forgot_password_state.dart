class ForgotPasswordState {
  final String emailErr;
  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;
  final String email;

  ForgotPasswordState({
    required this.emailErr,
    required this.isLoading,
    required this.isSuccess,
    required this.errorMessage,
    required this.email,
  });

  ForgotPasswordState copyWith({
    String? emailErr,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? email,
  }) {
    return ForgotPasswordState(
      emailErr: emailErr ?? this.emailErr,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email,
    );
  }
}
