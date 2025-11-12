import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? userData;

  const ProfileState({this.loading = true, this.error, this.userData});

  ProfileState copyWith({
    bool? loading,
    String? error,
    Map<String, dynamic>? userData,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      userData: userData ?? this.userData,
    );
  }

  @override
  List<Object?> get props => [loading, error, userData];
}
