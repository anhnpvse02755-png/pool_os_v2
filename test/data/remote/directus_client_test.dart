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
  _mainRefresh();
  _mainExpiry();
  _mainExpiredSignal();

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

// ============================================================================
// Gia han phien — nhom nay vach ra lo hong da de app "dang nhap gia".
//
// `refresh()` co san tu dau nhung KHONG AI GOI. Access token mac dinh cua
// Directus song 15 phut; qua moc do moi lenh tra 401 trong khi giao dien van
// bao da dang nhap. Nguoi dung thay moi thu hong ma khong hieu vi sao.
// ============================================================================

/// Adapter tra lan luot nhieu dap an cho CUNG mot route.
class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this.routes);

  /// 'METHOD path' -> hang doi cac (status, body).
  final Map<String, List<(int, Object)>> routes;
  final List<RequestOptions> seen = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    final queue = routes['${options.method} ${options.path}'];
    if (queue == null || queue.isEmpty) {
      return ResponseBody.fromString(
        jsonEncode({
          'errors': [
            {'message': 'het dap an cho ${options.method} ${options.path}'}
          ]
        }),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        },
      );
    }
    final (status, body) = queue.removeAt(0);
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

DirectusClient _seqClient(_SequenceAdapter a, InMemoryTokenStore store) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example'));
  dio.httpClientAdapter = a;
  return DirectusClient(
      baseUrl: 'https://api.example', dio: dio, tokenStore: store);
}

void _mainRefresh() {
  group('Gia han phien', () {
    const expired = DirectusSession(
        accessToken: 'token-het-han', refreshToken: 'refresh-con-tot',
        expiresInMs: 0);

    test('gap 401 thi tu gia han roi thu lai, nguoi dung khong thay gi', () async {
      final store = InMemoryTokenStore();
      await store.write(expired);

      final adapter = _SequenceAdapter({
        // Lan dau 401 vi token het han, lan hai thanh cong voi token moi.
        'GET /items/poolos_players': [
          (401, {
            'errors': [
              {
                'message': 'Token expired.',
                'extensions': {'code': 'TOKEN_EXPIRED'}
              }
            ]
          }),
          (200, {'data': <Map<String, dynamic>>[]}),
        ],
        'POST /auth/refresh': [
          (200, {
            'data': {
              'access_token': 'token-moi',
              'refresh_token': 'refresh-moi',
              'expires': 900000,
            }
          }),
        ],
      });

      final client = _seqClient(adapter, store);
      final items = await client.readItems('poolos_players');

      expect(items, isEmpty, reason: 'Lenh phai thanh cong sau khi gia han');
      expect((await store.read())!.accessToken, 'token-moi',
          reason: 'Token moi phai duoc luu lai');

      final paths = adapter.seen.map((r) => '${r.method} ${r.path}').toList();
      expect(paths, [
        'GET /items/poolos_players',
        'POST /auth/refresh',
        'GET /items/poolos_players',
      ]);
      expect(adapter.seen.last.headers['Authorization'], 'Bearer token-moi',
          reason: 'Lan thu lai phai dung token MOI');
    });

    test('refresh token cung chet thi xoa phien, khong lap vo han', () async {
      final store = InMemoryTokenStore();
      await store.write(expired);

      final adapter = _SequenceAdapter({
        'GET /items/poolos_players': [
          (401, {
            'errors': [
              {
                'message': 'Token expired.',
                'extensions': {'code': 'TOKEN_EXPIRED'}
              }
            ]
          }),
        ],
        'POST /auth/refresh': [
          (401, {
            'errors': [
              {
                'message': 'Invalid refresh token.',
                'extensions': {'code': 'INVALID_CREDENTIALS'}
              }
            ]
          }),
        ],
      });

      final client = _seqClient(adapter, store);

      await expectLater(
        () => client.readItems('poolos_players'),
        throwsA(isA<DirectusException>()),
      );
      expect(await store.read(), isNull,
          reason: 'Phien chet phai bi xoa de nguoi dung duoc dua ve dang nhap');
      // Dung 2 lan: request goc + 1 lan refresh. Khong thu lai vo han.
      expect(adapter.seen.length, 2);
    });

    test('401 khi CHUA dang nhap thi khong goi refresh', () async {
      final store = InMemoryTokenStore();
      final adapter = _SequenceAdapter({
        'GET /items/poolos_players': [
          (401, {
            'errors': [
              {'message': 'Forbidden'}
            ]
          }),
        ],
      });

      final client = _seqClient(adapter, store);
      await expectLater(
        () => client.readItems('poolos_players'),
        throwsA(isA<DirectusException>()),
      );
      expect(adapter.seen.length, 1,
          reason: 'Khong co refresh token thi dung goi /auth/refresh');
    });
  });
}

// ============================================================================
// Han token doc tu JWT
//
// Truong `expiresInMs` cua phien la KHOANG THOI LUONG ("con song bao lau ke tu
// luc cap"), ma khong cho nao ghi lai moc cap — nen no khong dung duoc de biet
// token con song hay khong. May la JWT cua Directus mang san claim `exp`.
// ============================================================================
void _mainExpiry() {
  // exp = 1000000000 -> 09/09/2001, chac chan da qua.
  const tokenHetHan =
      'eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9'
      '.eyJpZCI6ICJ1LTEiLCAicm9sZSI6ICJyLTEiLCAiZXhwIjogMTAwMDAwMDAwMCwgImlzcyI6ICJkaXJlY3R1cyJ9'
      '.chu-ky';
  // exp = 4000000000 -> nam 2096.
  const tokenConHan =
      'eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9'
      '.eyJpZCI6ICJ1LTEiLCAicm9sZSI6ICJyLTEiLCAiZXhwIjogNDAwMDAwMDAwMCwgImlzcyI6ICJkaXJlY3R1cyJ9'
      '.chu-ky';

  group('Han token', () {
    test('doc duoc moc het han tu claim exp', () {
      const s = DirectusSession(
          accessToken: tokenConHan, refreshToken: 'r', expiresInMs: 900000);
      expect(s.expiresAt, DateTime.fromMillisecondsSinceEpoch(4000000000 * 1000,
          isUtc: true));
      expect(s.isExpired, isFalse);
    });

    test('token qua han bi nhan dien', () {
      const s = DirectusSession(
          accessToken: tokenHetHan, refreshToken: 'r', expiresInMs: 900000);
      expect(s.isExpired, isTrue);
    });

    test('token khong phai JWT thi COI NHU con han, de 401 quyet dinh', () {
      const s = DirectusSession(
          accessToken: 'khong-phai-jwt', refreshToken: 'r', expiresInMs: 0);
      expect(s.expiresAt, isNull);
      expect(s.isExpired, isFalse,
          reason: 'Doan bua la het han se dang xuat oan nguoi dung');
    });

    test('biet truoc la het han thi gia han NGAY, khong phi mot vong 401',
        () async {
      final store = InMemoryTokenStore();
      await store.write(const DirectusSession(
          accessToken: tokenHetHan,
          refreshToken: 'refresh-con-tot',
          expiresInMs: 0));

      final adapter = _SequenceAdapter({
        'POST /auth/refresh': [
          (200, {
            'data': {
              'access_token': tokenConHan,
              'refresh_token': 'refresh-moi',
              'expires': 900000,
            }
          }),
        ],
        'GET /items/poolos_players': [
          (200, {'data': <Map<String, dynamic>>[]}),
        ],
      });

      final client = _seqClient(adapter, store);
      await client.readItems('poolos_players');

      final paths = adapter.seen.map((r) => '${r.method} ${r.path}').toList();
      expect(paths, ['POST /auth/refresh', 'GET /items/poolos_players'],
          reason: 'Gia han truoc, khong gui request chac chan that bai');
    });
  });
}

// ============================================================================
// Bao hieu phien chet
//
// `_tryRefresh` xoa token khi refresh that bai, nhung truoc day KHONG BAO CHO
// AI. AuthNotifier van o trang thai `authenticated`, guard thay `isAuthenticated
// == true` nen khong da nguoi dung di dau — ho ngoi nguyen tren man rieng tu
// ma moi request deu 401.
// ============================================================================
void _mainExpiredSignal() {
  group('Bao hieu phien chet', () {
    const song = DirectusSession(
        accessToken: 'token-cu', refreshToken: 'refresh-cu', expiresInMs: 900000);

    test('refresh that bai thi phat tin hieu onSessionExpired', () async {
      final store = InMemoryTokenStore();
      await store.write(song);

      final adapter = _SequenceAdapter({
        'GET /items/poolos_players': [
          (401, {
            'errors': [
              {'message': 'Token expired.',
               'extensions': {'code': 'TOKEN_EXPIRED'}}
            ]
          }),
        ],
        'POST /auth/refresh': [
          (401, {
            'errors': [
              {'message': 'Invalid refresh token.',
               'extensions': {'code': 'INVALID_CREDENTIALS'}}
            ]
          }),
        ],
      });

      final client = _seqClient(adapter, store);
      final phatTinHieu = client.onSessionExpired.first;

      await expectLater(
        () => client.readItems('poolos_players'),
        throwsA(isA<DirectusException>()),
      );

      await expectLater(
        phatTinHieu.timeout(const Duration(seconds: 1)),
        completes,
        reason: 'Phien chet phai bao ra ngoai de app dua ve dang nhap',
      );
    });

    test('gia han THANH CONG thi KHONG phat tin hieu', () async {
      final store = InMemoryTokenStore();
      await store.write(song);

      final adapter = _SequenceAdapter({
        'GET /items/poolos_players': [
          (401, {
            'errors': [
              {'message': 'Token expired.',
               'extensions': {'code': 'TOKEN_EXPIRED'}}
            ]
          }),
          (200, {'data': <Map<String, dynamic>>[]}),
        ],
        'POST /auth/refresh': [
          (200, {
            'data': {
              'access_token': 'token-moi',
              'refresh_token': 'refresh-moi',
              'expires': 900000,
            }
          }),
        ],
      });

      final client = _seqClient(adapter, store);
      var phat = false;
      final sub = client.onSessionExpired.listen((_) => phat = true);

      await client.readItems('poolos_players');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      expect(phat, isFalse,
          reason: 'Gia han duoc thi phien VAN SONG, dung bat dang nhap lai');
    });

    test('dang xuat CHU DONG khong phat tin hieu het han', () async {
      final store = InMemoryTokenStore();
      await store.write(song);

      final adapter = _SequenceAdapter({
        'POST /auth/logout': [(204, {})],
      });

      final client = _seqClient(adapter, store);
      var phat = false;
      final sub = client.onSessionExpired.listen((_) => phat = true);

      await client.logout();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      expect(phat, isFalse,
          reason: 'Tu bam dang xuat thi dung bao "phien da het han"');
    });
  });
}
