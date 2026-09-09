// ============================================================================
// auth_service_test.dart — AuthService trên nền Directus
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/services/auth_service.dart';
import 'package:pool_os_v2/data/remote/directus_client.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);
  final Map<String, (int, Object)> routes;
  final List<RequestOptions> seen = [];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s,
      Future<void>? c) async {
    seen.add(o);
    final (status, body) = routes['${o.method} ${o.path}'] ??
        (404, {
          'errors': [
            {'message': 'no route'}
          ]
        });
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

/// Token có payload thật của Directus: {"id":"u-1","role":"r-1"}
const _token = 'eyJhbGciOiJIUzI1NiJ9'
    '.eyJpZCI6InUtMSIsInJvbGUiOiJyLTEiLCJpc3MiOiJkaXJlY3R1cyJ9'
    '.sig';

AuthService _serviceWith(_FakeAdapter adapter, {InMemoryTokenStore? store}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example'));
  dio.httpClientAdapter = adapter;
  return AuthService(
    DirectusClient(
      baseUrl: 'https://api.example',
      dio: dio,
      tokenStore: store ?? InMemoryTokenStore(),
    ),
  );
}

void main() {
  group('Đăng nhập', () {
    test('thành công trả về userId đọc từ JWT', () async {
      final service = _serviceWith(_FakeAdapter({
        'POST /auth/login': (
          200,
          {
            'data': {
              'access_token': _token,
              'refresh_token': 'r-1',
              'expires': 900000
            }
          }
        ),
      }));

      final result = await service.signIn(email: 'a@b.vn', password: 'x');

      expect(result.ok, isTrue);
      expect(result.userId, 'u-1');
      expect(result.errorMessage, isNull);
      expect(await service.isSignedIn(), isTrue);
    });

    test('sai mật khẩu trả thông báo tiếng Việt, KHÔNG lộ lỗi kỹ thuật',
        () async {
      final service = _serviceWith(_FakeAdapter({
        'POST /auth/login': (
          401,
          {
            'errors': [
              {
                'message': 'Invalid user credentials.',
                'extensions': {'code': 'INVALID_CREDENTIALS'}
              }
            ]
          }
        ),
      }));

      final result = await service.signIn(email: 'a@b.vn', password: 'sai');

      expect(result.ok, isFalse);
      expect(result.errorMessage, 'Email hoặc mật khẩu không đúng.');
      expect(result.errorMessage, isNot(contains('Invalid user credentials')));
    });

    test('máy chủ chết trả thông báo khác hẳn lỗi sai mật khẩu', () async {
      final service = _serviceWith(_FakeAdapter({
        'POST /auth/login': (503, {'errors': []}),
      }));

      final result = await service.signIn(email: 'a@b.vn', password: 'x');

      expect(result.ok, isFalse);
      // Đây là điểm hỏng cũ: đổ lỗi cho mật khẩu người dùng khi thật ra là
      // backend chưa cấu hình. Không được lặp lại.
      expect(result.errorMessage, isNot(contains('mật khẩu không đúng')));
      expect(result.errorMessage!.toLowerCase(), contains('máy chủ'));
    });
  });

  group('Đăng ký', () {
    test('tạo tài khoản rồi đăng nhập luôn', () async {
      final adapter = _FakeAdapter({
        'POST /users/register': (204, {}),
        'POST /auth/login': (
          200,
          {
            'data': {
              'access_token': _token,
              'refresh_token': 'r-1',
              'expires': 900000
            }
          }
        ),
      });
      final service = _serviceWith(adapter);

      final result = await service.signUp(email: 'a@b.vn', password: 'x');

      expect(result.ok, isTrue);
      expect(result.userId, 'u-1');
      expect(adapter.seen.map((r) => r.path),
          containsAllInOrder(['/users/register', '/auth/login']));
    });

    test('email đã tồn tại báo đúng nguyên nhân', () async {
      final service = _serviceWith(_FakeAdapter({
        'POST /users/register': (
          400,
          {
            'errors': [
              {
                'message': 'Value has to be unique.',
                'extensions': {'code': 'RECORD_NOT_UNIQUE'}
              }
            ]
          }
        ),
      }));

      final result = await service.signUp(email: 'a@b.vn', password: 'x');

      expect(result.ok, isFalse);
      expect(result.errorMessage, contains('đã được đăng ký'));
    });
  });

  group('Quên mật khẩu', () {
    test('gửi kèm reset_url không chứa dấu thăng', () async {
      final adapter = _FakeAdapter({'POST /auth/password/request': (204, {})});
      final service = _serviceWith(adapter);

      final result = await service.requestPasswordReset('a@b.vn');

      expect(result.ok, isTrue);
      final sent = (adapter.seen.single.data as Map).cast<String, dynamic>();
      expect(sent['reset_url'], isNot(contains('#')));
      expect(sent['reset_url'], contains('/reset-password'));
    });

    test('đặt lại bằng token', () async {
      final adapter = _FakeAdapter({'POST /auth/password/reset': (204, {})});
      final service = _serviceWith(adapter);

      final result =
          await service.resetPassword(token: 't-1', newPassword: 'MớiMật1');

      expect(result.ok, isTrue);
      final sent = (adapter.seen.single.data as Map).cast<String, dynamic>();
      expect(sent['token'], 't-1');
    });

    test('token hết hạn báo rõ để người dùng biết phải xin link mới', () async {
      final service = _serviceWith(_FakeAdapter({
        'POST /auth/password/reset': (
          401,
          {
            'errors': [
              {
                'message': 'Token expired.',
                'extensions': {'code': 'INVALID_TOKEN'}
              }
            ]
          }
        ),
      }));

      final result =
          await service.resetPassword(token: 'cũ', newPassword: 'MớiMật1');

      expect(result.ok, isFalse);
      expect(result.errorMessage, contains('hết hạn'));
    });
  });

  group('Đăng xuất', () {
    test('xoá phiên kể cả khi máy chủ lỗi', () async {
      final store = InMemoryTokenStore();
      await store.write(const DirectusSession(
          accessToken: _token, refreshToken: 'r', expiresInMs: 1));
      final service = _serviceWith(
        _FakeAdapter({'POST /auth/logout': (500, {'errors': []})}),
        store: store,
      );

      await service.signOut();

      expect(await service.isSignedIn(), isFalse);
    });
  });
}
