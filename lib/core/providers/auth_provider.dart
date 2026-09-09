// ============================================================================
// AUTH PROVIDER — trên nền Directus
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/directus_client.dart';
import '../../data/remote/prefs_token_store.dart';
import '../config/directus_config.dart';
import '../services/auth_service.dart';

/// Client Directus dùng chung. Phiên đăng nhập lưu xuống SharedPreferences
/// nên đóng app mở lại vẫn còn.
final directusClientProvider = Provider<DirectusClient>((ref) {
  return DirectusClient(
    baseUrl: DirectusConfig.baseUrl,
    tokenStore: PrefsTokenStore(),
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(directusClientProvider));
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.error,
  });

  final AuthStatus status;
  final String? userId;
  final String? email;

  /// Thông báo tiếng Việt cho người dùng, không phải lỗi kỹ thuật.
  final String? error;

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
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._auth) : super(const AuthState()) {
    _restore();
  }

  final AuthService _auth;

  /// Khôi phục phiên đã lưu khi mở app.
  Future<void> _restore() async {
    final userId = await _auth.currentUserId();
    state = userId == null
        ? const AuthState(status: AuthStatus.unauthenticated)
        : AuthState(status: AuthStatus.authenticated, userId: userId);
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(error: null);
    final r = await _auth.signIn(email: email, password: password);
    state = r.ok
        ? AuthState(
            status: AuthStatus.authenticated, userId: r.userId, email: email)
        : state.copyWith(
            status: AuthStatus.unauthenticated, error: r.errorMessage);
    return r.ok;
  }

  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(error: null);
    final r = await _auth.signUp(email: email, password: password);
    state = r.ok
        ? AuthState(
            status: AuthStatus.authenticated, userId: r.userId, email: email)
        : state.copyWith(error: r.errorMessage);
    return r.ok;
  }

  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(error: null);
    final r = await _auth.requestPasswordReset(email);
    if (!r.ok) state = state.copyWith(error: r.errorMessage);
    return r.ok;
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    state = state.copyWith(error: null);
    final r = await _auth.resetPassword(token: token, newPassword: newPassword);
    if (!r.ok) state = state.copyWith(error: r.errorMessage);
    return r.ok;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
