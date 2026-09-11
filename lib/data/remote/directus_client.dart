// ============================================================================
// DIRECTUS CLIENT — bọc REST API của Directus
// ============================================================================
//
// Directus không có SDK Dart chính thức, nhưng API của nó là REST thuần nên
// một lớp mỏng trên `dio` là đủ — và nhẹ hơn hẳn supabase_flutter mà nó thay.
//
// Backend: https://poolos-api.kjdybl.easypanel.host (Directus 12.3.1)
// Xem [[backend-directus]] trong memory để biết các bẫy đã gặp.
// ============================================================================

import 'dart:convert';

import 'package:dio/dio.dart';

/// Phiên đăng nhập Directus trả về.
class DirectusSession {
  const DirectusSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInMs,
  });

  final String accessToken;
  final String refreshToken;

  /// Directus trả `expires` tính bằng mili-giây kể từ lúc cấp.
  final int expiresInMs;

  factory DirectusSession.fromJson(Map<String, dynamic> json) {
    return DirectusSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresInMs: (json['expires'] as num?)?.toInt() ?? 0,
    );
  }

  /// Id người dùng, đọc từ payload JWT.
  ///
  /// Không gọi `/users/me` được: Directus bản này khoá mọi quyền tuỳ chỉnh
  /// trên collection hệ thống (`custom_permission_rules_enabled is a
  /// restricted resource`), nên người chơi không đọc nổi bản ghi của chính
  /// mình. May là token đã mang sẵn `id` và `role`.
  String? get userId => _claim('id');

  String? get roleId => _claim('role');

  /// Mốc hết hạn, đọc từ claim `exp` của JWT.
  ///
  /// KHÔNG dùng [expiresInMs] cho việc này: đó là *thời lượng* kể từ lúc cấp,
  /// mà không chỗ nào ghi lại mốc cấp — nên nó không trả lời được câu hỏi
  /// "token còn sống không". Claim `exp` là mốc tuyệt đối nên tự đủ.
  DateTime? get expiresAt {
    final seconds = _numClaim('exp');
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Token chắc chắn đã hết hạn.
  ///
  /// Token không đọc được coi như CÒN hạn — đoán bừa là hết hạn sẽ đăng xuất
  /// oan người dùng. Cứ để máy chủ trả 401 rồi xử lý, đó mới là nguồn sự thật.
  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().toUtc().isAfter(exp);
  }

  int? _numClaim(String key) {
    final parts = accessToken.split('.');
    if (parts.length != 3) return null;
    try {
      var payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final value = (decoded as Map)[key];
      return value is num ? value.toInt() : null;
    } catch (_) {
      return null;
    }
  }

  String? _claim(String key) {
    final parts = accessToken.split('.');
    if (parts.length != 3) return null;
    try {
      var payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final value = (decoded as Map)[key];
      return value is String ? value : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires': expiresInMs,
      };
}

/// Nơi cất phiên đăng nhập. Tách ra để test không cần SharedPreferences.
abstract class TokenStore {
  Future<DirectusSession?> read();
  Future<void> write(DirectusSession session);
  Future<void> clear();
}

class InMemoryTokenStore implements TokenStore {
  DirectusSession? _session;

  @override
  Future<DirectusSession?> read() async => _session;

  @override
  Future<void> write(DirectusSession session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}

/// Lỗi từ Directus, đã bóc khỏi lớp vỏ `{"errors":[{...}]}`.
class DirectusException implements Exception {
  DirectusException({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;

  /// Mã của Directus, ví dụ `INVALID_CREDENTIALS`, `LIMIT_EXCEEDED`.
  final String? code;
  final int? statusCode;

  /// Sai email hoặc mật khẩu — phân biệt với lỗi mạng/cấu hình để UI nói đúng.
  bool get isInvalidCredentials => code == 'INVALID_CREDENTIALS';

  @override
  String toString() => 'DirectusException($statusCode $code): $message';
}

class DirectusClient {
  DirectusClient({
    required String baseUrl,
    Dio? dio,
    TokenStore? tokenStore,
  })  : _tokenStore = tokenStore ?? InMemoryTokenStore(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            )) {
    // Client tự bóc `{"errors":[...]}` của Directus, nên dio KHÔNG được ném
    // trước ở mã 4xx/5xx — làm vậy sẽ mất payload lỗi và ta chỉ còn "status
    // code 401" trần trụi. Đặt ở đây thay vì trong BaseOptions để áp dụng cả
    // khi dio được tiêm từ ngoài vào (test, hoặc dio dùng chung của app).
    _dio.options.validateStatus = (_) => true;
  }

  final Dio _dio;
  final TokenStore _tokenStore;

  TokenStore get tokenStore => _tokenStore;

  // ==========================================================================
  // Auth
  // ==========================================================================

  Future<DirectusSession> login(String email, String password) async {
    final data = await _send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    final session =
        DirectusSession.fromJson(data as Map<String, dynamic>);
    await _tokenStore.write(session);
    return session;
  }

  /// Đăng ký tài khoản mới (không cần token).
  ///
  /// Dùng `/users/register`, không phải `/users` — endpoint sau đòi quyền
  /// admin trên `directus_users`. Server phải bật `public_registration` và
  /// đặt `public_registration_role`, nếu không sẽ trả lỗi quyền.
  ///
  /// Trả 204 không body, nên không có id ở đây; lấy id từ token sau khi đăng
  /// nhập.
  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    await _send(
      'POST',
      '/users/register',
      body: {
        'email': email,
        'password': password,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
      },
      authenticated: false,
    );
  }

  /// Gia hạn phiên bằng refresh token đang lưu.
  Future<DirectusSession> refresh() async {
    final current = await _tokenStore.read();
    if (current == null || current.refreshToken.isEmpty) {
      throw DirectusException(message: 'Chưa có phiên để gia hạn.');
    }
    final data = await _send(
      'POST',
      '/auth/refresh',
      body: {'refresh_token': current.refreshToken, 'mode': 'json'},
      authenticated: false,
    );
    final session = DirectusSession.fromJson(data as Map<String, dynamic>);
    await _tokenStore.write(session);
    return session;
  }

  /// Đăng xuất. Token cục bộ LUÔN bị xoá, kể cả khi server lỗi — nếu không
  /// người dùng sẽ kẹt ở trạng thái "đã đăng nhập" mà không thoát ra được.
  Future<void> logout() async {
    final current = await _tokenStore.read();
    try {
      if (current != null && current.refreshToken.isNotEmpty) {
        await _send(
          'POST',
          '/auth/logout',
          body: {'refresh_token': current.refreshToken, 'mode': 'json'},
          authenticated: false,
        );
      }
    } on DirectusException {
      // Bỏ qua: vẫn phải xoá phiên cục bộ.
    } finally {
      await _tokenStore.clear();
    }
  }

  /// Gửi email đặt lại mật khẩu.
  ///
  /// [resetUrl] phải nằm trong `PASSWORD_RESET_URL_ALLOW_LIST` của server và
  /// KHÔNG được chứa ký tự `#` — file .env coi `#` là bắt đầu comment nên giá
  /// trị bị cắt cụt. Dùng đường dẫn thường; nginx đã có SPA fallback.
  Future<void> requestPasswordReset(
    String email, {
    required String resetUrl,
  }) async {
    await _send(
      'POST',
      '/auth/password/request',
      body: {'email': email, 'reset_url': resetUrl},
      authenticated: false,
    );
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _send(
      'POST',
      '/auth/password/reset',
      body: {'token': token, 'password': password},
      authenticated: false,
    );
  }

  /// Hồ sơ người dùng đang đăng nhập.
  Future<Map<String, dynamic>> me() async {
    final data = await _send('GET', '/users/me');
    return (data as Map).cast<String, dynamic>();
  }

  // ==========================================================================
  // Items
  // ==========================================================================

  Future<List<Map<String, dynamic>>> readItems(
    String collection, {
    Map<String, dynamic>? query,
  }) async {
    final data = await _send('GET', '/items/$collection', query: query);
    return ((data as List?) ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, dynamic>> createItem(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final res = await _send('POST', '/items/$collection', body: data);
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateItem(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final res = await _send('PATCH', '/items/$collection/$id', body: data);
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> deleteItem(String collection, String id) async {
    await _send('DELETE', '/items/$collection/$id');
  }

  // ==========================================================================

  /// Gửi request và bóc lớp vỏ `{"data": ...}` / `{"errors": [...]}`.
  ///
  /// Gặp 401 thì **tự gia hạn phiên một lần rồi thử lại**. Trước đây bước này
  /// không có: `refresh()` viết sẵn từ đầu nhưng không chỗ nào gọi, mà access
  /// token mặc định của Directus chỉ sống 15 phút — qua mốc đó mọi thao tác
  /// đều 401 trong khi giao diện vẫn báo đã đăng nhập.
  ///
  /// [_retrying] chặn đệ quy: chỉ gia hạn đúng một lần cho mỗi request.
  Future<Object?> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    bool authenticated = true,
    bool retrying = false,
  }) async {
    final headers = <String, dynamic>{};
    if (authenticated) {
      var session = await _tokenStore.read();
      // Biết chắc đã hết hạn thì gia hạn ngay, đừng phí một vòng 401.
      if (session != null && session.isExpired && !retrying) {
        if (await _tryRefresh()) session = await _tokenStore.read();
      }
      if (session != null) {
        headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
    }

    late final Response<dynamic> response;
    try {
      response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method, headers: headers),
      );
    } on DioException catch (e) {
      throw DirectusException(
        message: e.message ?? 'Không kết nối được máy chủ.',
        statusCode: e.response?.statusCode,
      );
    }

    final status = response.statusCode ?? 0;
    final payload = response.data;

    if (status == 401 && authenticated && !retrying) {
      final renewed = await _tryRefresh();
      if (renewed) {
        return _send(method, path,
            body: body, query: query, authenticated: true, retrying: true);
      }
    }
    if (status >= 400) {
      throw _errorFrom(payload, status);
    }
    // 204 No Content (quên mật khẩu, đăng xuất) không có body.
    if (payload is Map && payload.containsKey('data')) return payload['data'];
    return null;
  }

  /// Thử gia hạn phiên. Trả `false` nếu không gia hạn được.
  ///
  /// Refresh token chết cũng là phiên chết — xoá luôn phần lưu cục bộ để app
  /// biết mà đưa người dùng về màn đăng nhập, thay vì kẹt ở trạng thái "đã
  /// đăng nhập" mà mọi thao tác đều hỏng.
  Future<bool> _tryRefresh() async {
    final current = await _tokenStore.read();
    if (current == null || current.refreshToken.isEmpty) return false;
    try {
      await refresh();
      return true;
    } on DirectusException {
      await _tokenStore.clear();
      return false;
    }
  }

  DirectusException _errorFrom(Object? payload, int status) {
    if (payload is Map) {
      final errors = payload['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first as Map;
        final ext = first['extensions'];
        return DirectusException(
          message: (first['message'] as String?) ?? 'Lỗi không xác định.',
          code: ext is Map ? ext['code'] as String? : null,
          statusCode: status,
        );
      }
    }
    return DirectusException(
      message: 'Máy chủ trả về lỗi $status.',
      statusCode: status,
    );
  }
}
