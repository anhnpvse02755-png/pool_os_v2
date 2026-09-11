// ============================================================================
// auth_guard_test.dart
//
// Router truoc day KHONG co guard nao (`redirect` = 0): chua dang nhap van vao
// duoc moi man, va khi phien het han thi khong gi dua nguoi dung ve dang nhap —
// ho ket o trang thai "da dang nhap" ma moi thao tac deu 401.
//
// Ranh gioi da chot: chan man doc/ghi DU LIEU RIENG; kien thuc va thu vien bai
// tap xem tu do.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/router/app_router.dart';

void main() {
  group('Man cong khai — xem duoc khi CHUA dang nhap', () {
    const publicPaths = [
      '/welcome',
      '/onboarding',
      '/onboarding/interests',
      '/auth/login',
      '/auth/register',
      '/reset-password',
      '/home',
      // Thu vien: gia tri cua app phai xem duoc truoc khi quyet dinh dang ky.
      '/training',
      '/training/drills',
      '/training/drills/aiming',
      '/training/drill/BT01',
      '/training/knowledge',
      '/training/knowledge/bridge',
      '/training/certification',
      '/training/certification/cert-1',
    ];

    for (final p in publicPaths) {
      test('$p khong doi dang nhap', () {
        expect(requiresAuth(p), isFalse, reason: '$p phai xem duoc tu do');
      });
    }
  });

  group('Man rieng tu — phai dang nhap', () {
    const privatePaths = [
      '/profile',
      '/profile/settings',
      '/profile/edit',
      '/profile/equipment',
      '/notifications',
      '/community',
      '/session/create',
      '/coach',
      '/coach/analysis',
      '/coach/chat',
      '/play',
      '/play/history',
      '/play/quick',
      '/play/tournament',
      '/training/progress',
      '/training/history',
      '/training/session/new',
      '/training/session/active',
      '/settings/black-box',
    ];

    for (final p in privatePaths) {
      test('$p doi dang nhap', () {
        expect(requiresAuth(p), isTrue, reason: '$p doc/ghi du lieu rieng');
      });
    }
  });

  group('Ranh gioi de nham', () {
    test('/training tu do nhung /training/progress thi khong', () {
      expect(requiresAuth('/training'), isFalse);
      expect(requiresAuth('/training/progress'), isTrue);
    });

    test('tien to khong duoc khop nua chung', () {
      // '/playbook' khong phai '/play' — dung chan nham vi trung tien to.
      expect(requiresAuth('/playbook'), isFalse);
      // nhung '/play' va '/play/...' thi co.
      expect(requiresAuth('/play'), isTrue);
      expect(requiresAuth('/play/log'), isTrue);
    });

    test('query string khong lam lech phan loai', () {
      expect(requiresAuth('/training/session/new?drill=BT01&level=1'), isTrue);
      expect(requiresAuth('/training/knowledge/bridge?from=home'), isFalse);
    });
  });
}
