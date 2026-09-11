// ============================================================================
// auth_provider_test.dart — AuthNotifier phan ung khi phien chet
//
// Phien co the chet GIUA CHUNG: refresh token het han (mac dinh Directus 30
// ngay) hoac bi thu hoi. Luc do client xoa token, nhung neu AuthNotifier khong
// biet thi guard van thay `isAuthenticated == true` — nguoi dung ngoi nguyen
// tren man rieng tu ma moi request deu 401.
//
// Phai phan biet HAI viec khac han nhau:
//   * phien HET HAN  -> bao "phien da het han, dang nhap lai"
//   * tu bam DANG XUAT -> khong bao gi ca, ho co y lam vay
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/providers/auth_provider.dart';
import 'package:pool_os_v2/core/services/auth_service.dart';
import 'package:pool_os_v2/data/remote/directus_client.dart';

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this.routes);
  final Map<String, List<(int, Object)>> routes;

  @override
  Future<ResponseBody> fetch(
      RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    final queue = routes['${o.method} ${o.path}'];
    final (status, body) = (queue == null || queue.isEmpty)
        ? (
            404,
            {
              'errors': [
                {'message': 'no route'}
              ]
            }
          )
        : queue.removeAt(0);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

const _token = 'eyJhbGciOiJIUzI1NiJ9'
    '.eyJpZCI6InUtMSIsInJvbGUiOiJyLTEiLCJpc3MiOiJkaXJlY3R1cyJ9'
    '.sig';

/// Tra ca client de test goi duoc request that, khong can hook debug nao.
(AuthNotifier, DirectusClient) _notifierWith(_SequenceAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example'));
  dio.httpClientAdapter = adapter;
  final client = DirectusClient(
      baseUrl: 'https://api.example',
      dio: dio,
      tokenStore: InMemoryTokenStore());
  return (AuthNotifier(AuthService(client)), client);
}

/// Dung mot request bat ky de lam lo ra chuyen phien da chet.
Future<void> _chamVaoPhienChet(DirectusClient client) async {
  try {
    await client.readItems('poolos_players');
  } on DirectusException {
    // Mong doi: phien chet nen request hong.
  }
}

/// Cho `_restore()` trong constructor chay xong.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  group('Phien chet giua chung', () {
    test('gia han that bai -> unauthenticated VA co co bao het han', () async {
      final adapter = _SequenceAdapter({
        'POST /auth/login': [
          (200, {
            'data': {
              'access_token': _token,
              'refresh_token': 'r-1',
              'expires': 900000,
            }
          }),
        ],
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

      final (notifier, client) = _notifierWith(adapter);
      addTearDown(notifier.dispose);
      await _settle();

      expect(await notifier.signIn('a@b.c', 'mk'), isTrue);
      expect(notifier.state.isAuthenticated, isTrue);

      await _chamVaoPhienChet(client);
      await _settle();

      expect(notifier.state.isAuthenticated, isFalse,
          reason: 'Phai thoi tin la dang dang nhap');
      expect(notifier.state.sessionExpired, isTrue,
          reason: 'Phai co co de man dang nhap noi ro ly do');
    });

    test('tu bam dang xuat thi KHONG bat co het han', () async {
      final adapter = _SequenceAdapter({
        'POST /auth/login': [
          (200, {
            'data': {
              'access_token': _token,
              'refresh_token': 'r-1',
              'expires': 900000,
            }
          }),
        ],
        'POST /auth/logout': [(204, {})],
      });

      final (notifier, _) = _notifierWith(adapter);
      addTearDown(notifier.dispose);
      await _settle();

      await notifier.signIn('a@b.c', 'mk');
      await notifier.signOut();

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.sessionExpired, isFalse,
          reason: 'Ho co y dang xuat — bao "het han" la sai su that');
    });

    test('dang nhap lai thi xoa co het han', () async {
      final loginOk = (200, {
        'data': {
          'access_token': _token,
          'refresh_token': 'r-1',
          'expires': 900000,
        }
      });
      final adapter = _SequenceAdapter({
        // Dang nhap -> phien chet -> dang nhap lai.
        'POST /auth/login': [loginOk, loginOk],
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

      final (notifier, client) = _notifierWith(adapter);
      addTearDown(notifier.dispose);
      await _settle();

      await notifier.signIn('a@b.c', 'mk');
      await _chamVaoPhienChet(client);
      await _settle();
      expect(notifier.state.sessionExpired, isTrue);

      await notifier.signIn('a@b.c', 'mk');
      expect(notifier.state.sessionExpired, isFalse,
          reason: 'Dang nhap xong thi thong bao cu phai bien mat');
      expect(notifier.state.isAuthenticated, isTrue);
    });
  });
}
