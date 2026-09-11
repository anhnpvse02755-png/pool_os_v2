// ============================================================================
// login_session_expired_test.dart
//
// Phan NGUOI DUNG THAY khi phien chet giua chung. Tang duoi da bao hieu dung
// (xem auth_provider_test), nhung neu man dang nhap khong hien gi thi ho van bi
// da ve day ma khong hieu vi sao — dung cai cam giac "app tu nhien hong".
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/providers/auth_provider.dart';
import 'package:pool_os_v2/core/services/auth_service.dart';
import 'package:pool_os_v2/data/remote/directus_client.dart';
import 'package:pool_os_v2/presentation/screens/auth/login_screen.dart';

/// Khong tra loi gi — test nay chi quan tam phan hien thi.
class _DeadAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
      RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    return ResponseBody.fromString(
      jsonEncode({
        'errors': [
          {'message': 'khong dung toi'}
        ]
      }),
      503,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthService _deadService() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example'));
  dio.httpClientAdapter = _DeadAdapter();
  return AuthService(DirectusClient(
    baseUrl: 'https://api.example',
    dio: dio,
    tokenStore: InMemoryTokenStore(),
  ));
}

/// Dat san mot trang thai roi giu nguyen.
class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._fixed) : super(_deadService()) {
    state = _fixed;
  }

  final AuthState _fixed;
}

const _expiredNotice = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

Future<void> _pumpLogin(WidgetTester tester, AuthState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => _FixedAuthNotifier(state)),
      ],
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  // Man nay dung flutter_animate; `pump()` don thuan de lai timer treo va test
  // that bai o buoc don dep chu khong phai o phan kiem tra.
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phien het han thi hien thong bao giai thich', (tester) async {
    await _pumpLogin(
        tester,
        const AuthState(
            status: AuthStatus.unauthenticated, sessionExpired: true));

    expect(find.text(_expiredNotice), findsOneWidget,
        reason: 'Phai noi ro vi sao ho bi dua ve day');
  });

  testWidgets('vao thang man dang nhap thi KHONG hien thong bao do',
      (tester) async {
    await _pumpLogin(
        tester, const AuthState(status: AuthStatus.unauthenticated));

    expect(find.text(_expiredNotice), findsNothing,
        reason: 'Chua tung dang nhap ma bao het han la noi doi');
  });
}
