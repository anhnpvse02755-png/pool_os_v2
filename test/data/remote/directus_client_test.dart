// ============================================================================
// directus_client_test.dart
//
// Bọc REST của Directus. Test chạy trên một HttpClientAdapter giả nên không
// chạm mạng — nhưng hình dạng request/response đúng như instance thật ở
// https://poolos-api.kjdybl.easypanel.host (đã đối chiếu bằng curl).
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/remote/directus_client.dart';

/// Ghi lại request và trả về đáp án đã dựng sẵn theo `METHOD path`.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);

  final Map<String, (int, Object)> routes;
  final List<RequestOptions> seen = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    final key = '${options.method} ${options.path}';
    final entry = routes[key];
    if (entry == null) {
      return ResponseBody.fromString(
        jsonEncode({
          'errors': [
            {'message': 'no route for $key'}
          ]
        }),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        },
      );
    }
    final (status, body) = entry;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DirectusClient _clientWith(_FakeAdapter adapter, {InMemoryTokenStore? store}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example'));
  dio.httpClientAdapter = adapter;
  return DirectusClient(
    baseUrl: 'https://api.example',
    dio: dio,
    tokenStore: store ?? InMemoryTokenStore(),
  );
}

void main() {
  group('Đăng nhập', () {
    test('trả về token và lưu vào store', () async {
      final store = InMemoryTokenStore();
      final adapter = _FakeAdapter({
        'POST /auth/login': (
          200,
          {
            'data': {
              'access_token': 'acc-1',
              'refresh_token': 'ref-1',
              'expires': 900000,
            }
          }
        ),
      });
      final client = _clientWith(adapter, store: store);

      final session = await client.login('a@b.vn', 'secret');

      expect(session.accessToken, 'acc-1');
      expect(session.refreshToken, 'ref-1');
      expect(await store.read(), isNotNull);
      expect((await store.read())!.accessToken, 'acc-1');

      final sent = (adapter.seen.single.data as Map).cast<String, dynamic>();
      expect(sent['email'], 'a@b.vn');
      expect(sent['password'], 'secret');
    });

    test('sai mật khẩu ném DirectusException đọc được', () async {
      final client = _clientWith(_FakeAdapter({
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

      expect(
        () => client.login('a@b.vn', 'sai'),
        throwsA(isA<DirectusException>()
            .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });

  group('Quên mật khẩu', () {
    test('gửi email kèm reset_url', () async {
      final adapter = _FakeAdapter({'POST /auth/password/request': (204, {})});
      final client = _clientWith(adapter);

      await client.requestPasswordReset(
        'a@b.vn',
        resetUrl: 'https://app.example/reset-password',
      );

      final sent = (adapter.seen.single.data as Map).cast<String, dynamic>();
      expect(sent['email'], 'a@b.vn');
      // Directus chỉ chấp nhận URL nằm trong PASSWORD_RESET_URL_ALLOW_LIST,
      // và giá trị đó KHÔNG được chứa '#' (file .env cắt cụt tại dấu thăng).
      expect(sent['reset_url'], 'https://app.example/reset-password');
      expect(sent['reset_url'], isNot(contains('#')));
    });

    test('đặt lại mật khẩu bằng token', () async {
      final adapter = _FakeAdapter({'POST /auth/password/reset': (204, {})});
      final client = _clientWith(adapter);

      await client.resetPassword(token: 'tok-9', password: 'MậtKhẩuMới1');

      final sent = (adapter.seen.single.data as Map).cast<String, dynamic>();
      expect(sent['token'], 'tok-9');
      expect(sent['password'], 'MậtKhẩuMới1');
    });
  });

  group('Items', () {
    test('đọc danh sách trả về data', () async {
      final client = _clientWith(_FakeAdapter({
        'GET /items/poolos_matches': (
          200,
          {
            'data': [
              {'id': 'm1', 'game_type': '9-ball'},
              {'id': 'm2', 'game_type': '8-ball'},
            ]
          }
        ),
      }));

      final items = await client.readItems('poolos_matches');

      expect(items, hasLength(2));
      expect(items.first['id'], 'm1');
    });

    test('tạo item gắn Authorization khi đã đăng nhập', () async {
      final store = InMemoryTokenStore();
      await store.write(const DirectusSession(
          accessToken: 'acc-7', refreshToken: 'r', expiresInMs: 900000));
      final adapter = _FakeAdapter({
        'POST /items/poolos_matches': (
          200,
          {
            'data': {'id': 'new-1'}
          }
        ),
      });
      final client = _clientWith(adapter, store: store);

      final created =
          await client.createItem('poolos_matches', {'game_type': '9-ball'});

      expect(created['id'], 'new-1');
      expect(adapter.seen.single.headers['Authorization'], 'Bearer acc-7');
    });

    test('chưa đăng nhập thì không gắn Authorization', () async {
      final adapter = _FakeAdapter({
        'GET /items/poolos_matches': (200, {'data': []}),
      });
      final client = _clientWith(adapter);

      await client.readItems('poolos_matches');

      expect(adapter.seen.single.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('Đăng xuất', () {
    test('xoá token khỏi store', () async {
      final store = InMemoryTokenStore();
      await store.write(const DirectusSession(
          accessToken: 'a', refreshToken: 'r', expiresInMs: 1));
      final client = _clientWith(
        _FakeAdapter({'POST /auth/logout': (204, {})}),
        store: store,
      );

      await client.logout();

      expect(await store.read(), isNull);
    });

    test('vẫn xoá token cục bộ dù server lỗi', () async {
      final store = InMemoryTokenStore();
      await store.write(const DirectusSession(
          accessToken: 'a', refreshToken: 'r', expiresInMs: 1));
      final client = _clientWith(
        _FakeAdapter({'POST /auth/logout': (500, {'errors': []})}),
        store: store,
      );

      await client.logout();

      expect(await store.read(), isNull,
          reason: 'Server lỗi không được giữ người dùng ở trạng thái đăng nhập.');
    });
  });

  group('Danh tính từ JWT', () {
    // Payload thật của Directus: {"id":"...","role":"...","iss":"directus"}
    const realShapeToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpZCI6IjNiYTkzN2IxLTMxNGMtNDA4Ni1iOWNlLTNhZWVkMjBiYWJmMCIsInJvbGUiOiJmYzEzNWFhYy00YTA3LTRhM2UtYjE0ZC1kODhkNzExZDUwZTMiLCJpc3MiOiJkaXJlY3R1cyJ9'
        '.chu-ky-khong-can-kiem-tra';

    test('đọc được userId và roleId', () {
      const s = DirectusSession(
          accessToken: realShapeToken, refreshToken: 'r', expiresInMs: 1);
      expect(s.userId, '3ba937b1-314c-4086-b9ce-3aeed20babf0');
      expect(s.roleId, 'fc135aac-4a07-4a3e-b14d-d88d711d50e3');
    });

    test('token hỏng trả null thay vì ném', () {
      const s = DirectusSession(
          accessToken: 'khong-phai-jwt', refreshToken: 'r', expiresInMs: 1);
      expect(s.userId, isNull);
      expect(s.roleId, isNull);
    });
  });
}
