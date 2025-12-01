import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthState {
  final bool isLoggedIn;
  final String uid;
  final String token;

  AuthState({
    required this.isLoggedIn,
    this.uid = '',
    this.token = '',
  });

  AuthState copyWith({bool? isLoggedIn, String? uid, String? token}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }
}

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final _storage = const FlutterSecureStorage();

  AuthCubit() : super(AuthState(isLoggedIn: false)) {
    _loadPersistedAuth();
  }


  Future<void> _loadPersistedAuth() async {
    final uid = await _storage.read(key: 'uid');
    final token = await _storage.read(key: 'idToken');

    if (uid != null && token != null) {
      emit(AuthState(isLoggedIn: true, uid: uid, token: token));
    }
  }


  Future<void> login(String uid, String token) async {
    await _storage.write(key: 'uid', value: uid);
    await _storage.write(key: 'idToken', value: token);

    emit(AuthState(isLoggedIn: true, uid: uid, token: token));
  }


  Future<void> logout() async {
    await _storage.delete(key: 'uid');
    await _storage.delete(key: 'idToken');

    emit(AuthState(isLoggedIn: false));
  }
}
