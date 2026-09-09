// ============================================================================
// AUTH SERVICE — trên nền Directus
// ============================================================================
//
// Thay bản cũ viết cho Supabase. Nhiệm vụ chính: biến lỗi kỹ thuật của
// Directus thành thông báo tiếng Việt mà người dùng hiểu được, và phân biệt
// rõ "bạn gõ sai mật khẩu" với "máy chủ có vấn đề".
//
// Bản Supabase cũ hỏng đúng ở chỗ này: mọi lỗi đều hiện "Email hoặc mật khẩu
// không đúng", kể cả khi nguyên nhân thật là backend chưa được cấu hình —
// người dùng bị đổ lỗi cho thứ họ không sai.
// ============================================================================

import '../config/directus_config.dart';
import '../../data/remote/directus_client.dart';

/// Kết quả một thao tác auth, đã sẵn sàng để UI hiển thị.
class AuthResult {
  const AuthResult._({required this.ok, this.userId, this.errorMessage});

  const AuthResult.success({String? userId})
      : ok = true,
        userId = userId,
        errorMessage = null;

  const AuthResult.failure(String message)
      : ok = false,
        userId = null,
        errorMessage = message;

  final bool ok;
  final String? userId;

  /// Thông báo tiếng Việt, đã sạch chi tiết kỹ thuật.
  final String? errorMessage;
}

class AuthService {
  AuthService(this._client);

  final DirectusClient _client;

  DirectusClient get client => _client;

  Future<bool> isSignedIn() async =>
      (await _client.tokenStore.read()) != null;

  Future<String?> currentUserId() async =>
      (await _client.tokenStore.read())?.userId;

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _client.login(email, password);
      return AuthResult.success(userId: session.userId);
    } on DirectusException catch (e) {
      return AuthResult.failure(_loginMessage(e));
    } catch (_) {
      return const AuthResult.failure(
          'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.');
    }
  }

  /// Đăng ký rồi đăng nhập luôn — người dùng không phải gõ lại mật khẩu.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      await _client.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
    } on DirectusException catch (e) {
      return AuthResult.failure(_signUpMessage(e));
    } catch (_) {
      return const AuthResult.failure(
          'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.');
    }
    // Tài khoản đã tạo; nếu bước đăng nhập hỏng thì đừng báo "tạo thất bại".
    final signedIn = await signIn(email: email, password: password);
    if (signedIn.ok) return signedIn;
    return const AuthResult.failure(
        'Đã tạo tài khoản nhưng chưa đăng nhập được. Hãy thử đăng nhập.');
  }

  /// Gửi email đặt lại mật khẩu.
  Future<AuthResult> requestPasswordReset(String email) async {
    try {
      await _client.requestPasswordReset(email, resetUrl: _resetUrl);
      return const AuthResult.success();
    } on DirectusException {
      // Directus trả 204 kể cả khi email không tồn tại (chống dò tài khoản).
      // Lỗi ở đây gần như chắc chắn là mạng hoặc cấu hình.
      return const AuthResult.failure(
          'Không gửi được email lúc này. Thử lại sau ít phút.');
    } catch (_) {
      return const AuthResult.failure(
          'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.');
    }
  }

  Future<AuthResult> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _client.resetPassword(token: token, password: newPassword);
      return const AuthResult.success();
    } on DirectusException catch (e) {
      return AuthResult.failure(_resetMessage(e));
    } catch (_) {
      return const AuthResult.failure(
          'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.');
    }
  }

  Future<void> signOut() => _client.logout();

  // ==========================================================================

  String get _resetUrl => DirectusConfig.passwordResetUrl;

  String _loginMessage(DirectusException e) {
    if (e.isInvalidCredentials) return 'Email hoặc mật khẩu không đúng.';
    if (e.statusCode != null && e.statusCode! >= 500) {
      return 'Máy chủ đang gặp sự cố. Thử lại sau ít phút.';
    }
    return 'Không đăng nhập được. Thử lại sau ít phút.';
  }

  String _signUpMessage(DirectusException e) {
    if (e.code == 'RECORD_NOT_UNIQUE') {
      return 'Email này đã được đăng ký. Thử đăng nhập hoặc quên mật khẩu.';
    }
    if (e.code == 'FAILED_VALIDATION') {
      return 'Email hoặc mật khẩu không hợp lệ.';
    }
    return 'Không tạo được tài khoản. Thử lại sau ít phút.';
  }

  String _resetMessage(DirectusException e) {
    if (e.code == 'INVALID_TOKEN' || (e.statusCode == 401)) {
      return 'Liên kết đã hết hạn hoặc không hợp lệ. Hãy yêu cầu gửi lại.';
    }
    return 'Không đặt lại được mật khẩu. Thử lại sau ít phút.';
  }
}
