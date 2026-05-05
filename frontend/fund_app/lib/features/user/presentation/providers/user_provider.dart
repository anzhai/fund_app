import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final AuthNotifier _authNotifier;

  UserNotifier(this._authNotifier) : super(const UserState());

  void loadUser() {
    final authState = _authNotifier.state;
    state = state.copyWith(user: authState.user);
  }

  Future<void> logout() async {
    await _authNotifier.logout();
    state = const UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return UserNotifier(authNotifier);
});