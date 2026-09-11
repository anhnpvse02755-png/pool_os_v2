// ============================================================================
// AUTH PROVIDER — trên nền Directus
// ============================================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/directus_client.dart';
import '../../data/remote/prefs_token_store.dart';
import '../config/directus_config.dart';
import '../services/auth_service.dart';

/// Client Directus dùng chung. Phiên đăng nhập lưu xuống SharedPreferences
/// nên đóng app mở lại vẫn còn.
final directusClientProvider = Provider<DirectusClient>((ref) {
  final client = DirectusClient(
    baseUrl: DirectusConfig.baseUrl,
    tokenStore: PrefsTokenStore(),
  );
  // Client giữ một StreamController cho tín hiệu hết phiên — phải đóng.
  ref.onDispose(client.dispose);
  return client;
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
    this.sessionExpired = false,
  });

  final AuthStatus status;
  final String? userId;
  final String? email;

  /// Thông báo tiếng Việt cho người dùng, không phải lỗi kỹ thuật.
  final String? error;

  /// Phiên chết **giữa chừng**, không phải do người dùng bấm Đăng xuất.
  ///
  /// Tách khỏi [error] có chủ đích: `error` là kết quả của thao tác vừa rồi,
  /// còn cờ này là lời giải thích cho việc người dùng *đột nhiên* bị đưa về
  /// màn đăng nhập dù họ không làm gì cả. Gộp chung sẽ khiến thông báo hết hạn
  /// bị xoá mất ngay khi họ bấm Đăng nhập.
  final bool sessionExpired;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? error,
    bool? sessionExpired,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      error: error,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._auth) : super(const AuthState()) {
    _restore();
    // Phiên có thể chết giữa chừng (refresh token hết hạn hoặc bị thu hồi).
    // Client xoá token khi đó; không nghe tín hiệu này thì notifier vẫn tin là
    // đang đăng nhập và guard không đưa người dùng đi đâu cả.
    _expirySub = _auth.onSessionExpired.listen((_) => _onSessionExpired());
  }

  final AuthService _auth;
  StreamSubscription<void>? _expirySub;

  @override
  void dispose() {
    _expirySub?.cancel();
    super.dispose();
  }

  void _onSessionExpired() {
    if (!mounted) return;
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      sessionExpired: true,
    );
  }

  /// Khôi phục phiên đã lưu khi mở app.
  ///
  /// Đọc phiên là thao tác bất đồng bộ, mà notifier có thể đã bị huỷ trước khi
  /// nó xong — người dùng đóng app ngay lúc mở, hoặc provider bị dựng lại.
  /// Gán `state` sau khi huỷ sẽ ném "Tried to use AuthNotifier after dispose".
  Future<void> _restore() async {
    final userId = await _auth.currentUserId();
    if (!mounted) return;
    // Chỉ điền vào chỗ CHƯA biết. Đọc phiên là bất đồng bộ, trong lúc chờ có
    // thể đã có chuyện xảy ra — phiên hết hạn, hoặc người dùng kịp đăng nhập.
    // Ghi đè ở đây sẽ xoá mất những thứ đó, và thông báo hết hạn biến mất
    // đúng lúc cần hiện nhất.
    if (state.status != AuthStatus.unknown) return;
    state = userId == null
        ? const AuthState(status: AuthStatus.unauthenticated)
        : AuthState(status: AuthStatus.authenticated, userId: userId);
  }

  Future<bool> signIn(String email, String password) async {
    // Bắt tay đăng nhập là đã tiếp nhận thông báo hết hạn — xoá đi, nếu không
    // nó sẽ hiện chồng với lỗi "sai mật khẩu" và người dùng không biết đọc cái
    // nào.
    state = state.copyWith(error: null, sessionExpired: false);
    final r = await _auth.signIn(email: email, password: password);
    // Chỉ chặn việc gán state, vẫn trả kết quả THẬT — thao tác đã chạy xong
    // trên máy chủ rồi, báo sai sẽ khiến chỗ gọi hiểu nhầm.
    if (!mounted) return r.ok;
    state = r.ok
        ? AuthState(
            status: AuthStatus.authenticated, userId: r.userId, email: email)
        : state.copyWith(
            status: AuthStatus.unauthenticated, error: r.errorMessage);
    return r.ok;
  }

  /// Đăng ký. [fullName] là ô "Họ và tên" người dùng gõ ở màn đăng ký.
  ///
  /// Bản trước bỏ tham số này: màn đăng ký thu thập họ tên rồi **vứt đi**, tài
  /// khoản tạo ra không có tên. Directus tách `first_name`/`last_name` nên
  /// phải cắt — tiếng Việt đặt họ trước, nên từ đầu tiên là họ, phần còn lại
  /// là tên đệm + tên. Gõ mỗi một từ thì coi cả cụm là tên.
  Future<bool> signUp(String email, String password, {String? fullName}) async {
    state = state.copyWith(error: null);
    final (firstName, lastName) = _splitName(fullName);
    final r = await _auth.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    if (!mounted) return r.ok;
    state = r.ok
        ? AuthState(
            status: AuthStatus.authenticated, userId: r.userId, email: email)
        : state.copyWith(error: r.errorMessage);
    return r.ok;
  }

  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(error: null);
    final r = await _auth.requestPasswordReset(email);
    if (!r.ok && mounted) state = state.copyWith(error: r.errorMessage);
    return r.ok;
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    state = state.copyWith(error: null);
    final r = await _auth.resetPassword(token: token, newPassword: newPassword);
    if (!r.ok && mounted) state = state.copyWith(error: r.errorMessage);
    return r.ok;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Cắt "Họ và tên" thành `(first_name, last_name)` theo lối đặt tên Việt.
  ///
  /// "Nguyễn Văn A" -> first: "Văn A", last: "Nguyễn".
  /// "An"           -> first: "An",   last: null.
  static (String?, String?) _splitName(String? fullName) {
    final name = fullName?.trim() ?? '';
    if (name.isEmpty) return (null, null);
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, null);
    return (parts.sublist(1).join(' '), parts.first);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
