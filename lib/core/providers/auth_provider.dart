import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/player_service.dart';

/// Supabase Client Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

/// Player Service Provider
final playerServiceProvider = Provider<PlayerService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PlayerService(client);
});

/// Auth State
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: user.id,
        email: user.email,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _authService.signIn(email: email, password: password);
      final user = _authService.currentUser;
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          userId: user.id,
          email: user.email,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await _authService.signUp(email: email, password: password);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    try {
      await _authService.signInWithApple();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
