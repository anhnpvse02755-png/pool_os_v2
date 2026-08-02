import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth Service - Handles authentication operations
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Get user ID
  String? get userId => currentUser?.id;

  /// Auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update user metadata
  Future<void> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
        data: data,
      ),
    );
  }

  /// Refresh session
  Future<Session?> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return response.session;
  }
}
