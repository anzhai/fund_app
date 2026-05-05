import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ApiClient());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuth() async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      await getCurrentUser();
    }
  }

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.login(phone: phone, password: password);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) async {
        state = state.copyWith(isLoading: false, user: user, isAuthenticated: true);
        return true;
      },
    );
  }

  Future<bool> register({required String phone, required String password, required String smsCode}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.register(phone: phone, password: password, smsCode: smsCode);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user, isAuthenticated: true);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    await SecureStorage.clearTokens();
    state = const AuthState();
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user, isAuthenticated: true);
      },
    );
  }

  Future<void> sendSmsCode(String phone) async {
    await _repository.sendSmsCode(phone);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});