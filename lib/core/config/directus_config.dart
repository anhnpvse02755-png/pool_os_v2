// ============================================================================
// DIRECTUS CONFIG — nguồn duy nhất cho địa chỉ backend
// ============================================================================
//
// Thay cho supabase_config.dart. Khác biệt quan trọng: backend này KHÔNG cần
// khoá bí mật ở phía client (Directus dùng token phiên đăng nhập), nên URL có
// giá trị mặc định và app chạy được ngay mà không cần --dart-define.
//
// Đổi backend khi build:
//   flutter build web --dart-define=DIRECTUS_URL=https://api.example.com
// ============================================================================

class DirectusConfig {
  const DirectusConfig._();

  /// Địa chỉ Directus. Mặc định trỏ instance đang chạy thật.
  static const String baseUrl = String.fromEnvironment(
    'DIRECTUS_URL',
    defaultValue: 'https://poolos-api.kjdybl.easypanel.host',
  );

  /// Địa chỉ app, dùng để dựng link đặt lại mật khẩu.
  static const String appUrl = String.fromEnvironment(
    'APP_URL',
    defaultValue: 'https://poolos.kjdybl.easypanel.host',
  );

  /// Đích của link trong email đặt lại mật khẩu.
  ///
  /// KHÔNG được chứa `#`: Directus đối chiếu giá trị này với
  /// `PASSWORD_RESET_URL_ALLOW_LIST` trong file .env của server, mà .env coi
  /// `#` là bắt đầu comment nên giá trị bị cắt cụt. Dùng đường dẫn thường —
  /// nginx có SPA fallback, app tự đọc token từ query string.
  static String get passwordResetUrl => '$appUrl/reset-password';

  static bool get isConfigured => baseUrl.isNotEmpty;
}
