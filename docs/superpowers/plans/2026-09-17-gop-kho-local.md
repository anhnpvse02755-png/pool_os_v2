# Gộp kho local & hợp nhất bản ghi buổi tập — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Còn một kho local duy nhất, và buổi tập có một model / một key / một đường ghi để mọi bên đọc thấy cùng dữ liệu.

**Architecture:** `data/models/training_session.dart` thành `TrainingSession` duy nhất, thêm getter dẫn xuất `shotsAttempted` để hơn 20 chỗ đọc trong `coach_provider` không phải sửa. `TrainingNotifier` thôi chạm storage, đi qua `DrillRepository` (interface đã có sẵn đủ method). `LocalStorageService` bị xoá, ba nhóm key còn sống chuyển sang `LocalStorageDataSource` giữ nguyên tên key.

**Tech Stack:** Flutter 3.47.0 · Dart 3.13.0 · Riverpod 2.x · SharedPreferences

**Spec:** `docs/superpowers/specs/2026-09-17-gop-kho-local-design.md`

## Global Constraints

- Mọi lệnh `flutter` phải prefix PATH: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"` (PowerShell) hoặc `export PATH="/c/Users/anhnpv/flutter/bin:$PATH"` (Bash).
- `flutter analyze` phải **0 error**. Info/warning ở `test/` và `tools/` là nợ cũ, không tính.
- **Không sửa file tiếng Việt bằng PowerShell `Get-Content -Raw`** — nó đọc ANSI và làm hỏng UTF-8 vĩnh viễn. Dùng tool Edit.
- **Không** đụng `lib/core/models/training_session.dart` (khái niệm khác: buổi tập chứa nhiều `DrillRun`).
- **Không** đụng `TrainingSessionData` ở `lib/knowledge/player_intelligence.dart`.
- Commit sau mỗi task. Message tiếng Việt **không dấu**, theo lệ repo.

---

## Bản đồ file

| File | Vai trò sau khi xong |
|---|---|
| `lib/data/models/training_session.dart` | `TrainingSession` **duy nhất**; thêm getter dẫn xuất + `fromJson` khoan dung |
| `lib/data/models/drill_session.dart` | `toTrainingSessionMap()` phát ra key chuẩn |
| `lib/core/providers/training_provider.dart` | Chỉ còn `TrainingState` + `TrainingNotifier`; không khai model, không chạm storage |
| `lib/data/datasources/local/local_storage_datasource.dart` | Kho local **duy nhất**; nhận 3 nhóm key từ `LocalStorageService` |
| `lib/data/repositories/cache_repository.dart` | Trỏ sang `LocalStorageDataSource` |
| `lib/core/services/local_storage_service.dart` | **XOÁ** |
| `lib/main.dart` | Bỏ `LocalStorageService.init()` |

---

## Task 1: Model chuẩn — getter dẫn xuất và `fromJson` khoan dung

**Files:**
- Modify: `lib/data/models/training_session.dart`
- Test: `test/data/models/training_session_test.dart` (tạo mới)

**Interfaces:**
- Consumes: không có (task đầu)
- Produces: `TrainingSession.shotsAttempted` → `int` (getter dẫn xuất); `TrainingSession.fromJson(Map<String, dynamic>)` chấp nhận thêm khoá cũ `shotsAttempted` và `date`

**Vì sao `fromJson` phải khoan dung:** `DrillSession.toTrainingSessionMap()` (Task 2) và dữ liệu đã lưu trên máy dev đang dùng khoá cũ `shotsAttempted`/`date`. Nếu `fromJson` chỉ đọc khoá mới thì `shotsMissed` ra **0** và `completedAt` ra **thời điểm đọc** — sai âm thầm, không có lỗi nào nổ.

- [ ] **Step 1: Viết test đỏ**

Tạo `test/data/models/training_session_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/training_session.dart';

void main() {
  group('TrainingSession — shotsAttempted la du lieu dan xuat', () {
    test('shotsAttempted bang tong made va missed', () {
      final s = TrainingSession(
        id: 'a',
        drillCode: 'BT01',
        drillName: 'Bai 1',
        level: 1,
        score: 70,
        shotsMade: 7,
        shotsMissed: 3,
        duration: 10,
        completedAt: DateTime(2026, 9, 17),
      );

      expect(s.shotsAttempted, equals(10));
    });
  });

  group('TrainingSession.fromJson — khoan dung voi khoa cu', () {
    test('suy ra shotsMissed tu shotsAttempted khi thieu shotsMissed', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'level': 1,
        'score': 70,
        'shotsAttempted': 10,
        'shotsMade': 7,
        'duration': 10,
        'date': '2026-09-17T08:00:00.000',
      });

      expect(s.shotsMissed, equals(3), reason: '10 danh - 7 vao = 3 truot');
      expect(s.shotsAttempted, equals(10));
    });

    test('doc khoa cu `date` khi thieu `completedAt`', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'date': '2026-09-17T08:00:00.000',
      });

      expect(s.completedAt, equals(DateTime.parse('2026-09-17T08:00:00.000')),
          reason: 'thieu cho nay thi moi buoi tap deu mang gio doc, khong phai gio tap');
    });

    test('uu tien khoa moi khi co ca hai', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'shotsAttempted': 10,
        'shotsMade': 7,
        'shotsMissed': 2,
        'completedAt': '2026-09-18T08:00:00.000',
        'date': '2026-09-17T08:00:00.000',
      });

      expect(s.shotsMissed, equals(2));
      expect(s.completedAt, equals(DateTime.parse('2026-09-18T08:00:00.000')));
    });

    test('shotsMissed khong bao gio am', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'shotsAttempted': 3,
        'shotsMade': 7,
      });

      expect(s.shotsMissed, equals(0), reason: 'du lieu ban khong duoc sinh so am');
    });
  });
}
```

- [ ] **Step 2: Chạy test, xác nhận ĐỎ**

```bash
export PATH="/c/Users/anhnpv/flutter/bin:$PATH"
flutter test test/data/models/training_session_test.dart
```

Kỳ vọng: FAIL. Test đầu báo `shotsAttempted` không tồn tại (getter chưa có); các test `fromJson` báo sai giá trị.

- [ ] **Step 3: Thêm getter và làm `fromJson` khoan dung**

Trong `lib/data/models/training_session.dart`, thêm getter ngay sau constructor (sau dòng `});` của constructor, trước `factory fromJson`):

```dart
  /// Tong so cu da danh. DU LIEU DAN XUAT — khong luu tru.
  /// Giu ten nay de cac noi doc `session.shotsAttempted` khong phai sua.
  int get shotsAttempted => shotsMade + shotsMissed;
```

Thay toàn bộ `factory TrainingSession.fromJson` bằng:

```dart
  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    final made = json['shotsMade'] ?? json['shots_made'] ?? 0;

    // Khoa cu chi luu `shotsAttempted`. Suy ra so truot, chan so am
    // phong khi du lieu ban.
    final int missed;
    if (json['shotsMissed'] != null || json['shots_missed'] != null) {
      missed = json['shotsMissed'] ?? json['shots_missed'];
    } else if (json['shotsAttempted'] != null) {
      final attempted = json['shotsAttempted'] as int;
      missed = attempted - (made as int) < 0 ? 0 : attempted - made;
    } else {
      missed = 0;
    }

    // Khoa cu dung `date`. Bo qua no thi moi buoi tap deu mang gio DOC.
    final rawDate = json['completedAt'] ?? json['completed_at'] ?? json['date'];

    return TrainingSession(
      id: json['id'] ?? json['drillCode'] ?? '',
      drillCode: json['drillCode'] ?? json['drill_code'] ?? '',
      drillName: json['drillName'] ?? json['drill_name'] ?? '',
      level: json['level'] ?? 1,
      score: json['score'] ?? 0,
      shotsMade: made,
      shotsMissed: missed,
      duration: json['duration'] ?? 0,
      completedAt: rawDate != null ? DateTime.parse(rawDate) : DateTime.now(),
    );
  }
```

- [ ] **Step 4: Chạy test, xác nhận XANH**

```bash
flutter test test/data/models/training_session_test.dart
```

Kỳ vọng: PASS, 5 test.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/training_session.dart test/data/models/training_session_test.dart
git commit -m "feat(model): shotsAttempted thanh getter dan xuat, fromJson doc duoc khoa cu

Khoa cu (shotsAttempted, date) van con trong du lieu da luu va trong
DrillSession.toTrainingSessionMap. Khong khoan dung thi shotsMissed ra 0
va completedAt ra gio DOC chu khong phai gio tap — sai am tham.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: `toTrainingSessionMap()` phát ra khoá chuẩn

**Files:**
- Modify: `lib/data/models/drill_session.dart:218-231` (nhánh `drillRuns.isNotEmpty`) và nhánh `return` thứ hai (dòng ~233)
- Test: `test/data/models/drill_session_map_test.dart` (tạo mới)

**Interfaces:**
- Consumes: `TrainingSession.fromJson` (Task 1)
- Produces: `DrillSession.toTrainingSessionMap()` → `Map` chứa `shotsMissed` và `completedAt`

Task 1 làm `fromJson` chịu được khoá cũ. Task này sửa **nguồn phát** để dữ liệu mới không sinh ra khoá cũ nữa. Hai lớp bảo vệ: nguồn phát đúng, và bên đọc vẫn đỡ được dữ liệu cũ.

- [ ] **Step 1: Viết test đỏ**

Tạo `test/data/models/drill_session_map_test.dart`. **Trước khi viết**, mở `lib/data/models/drill_session.dart` đọc constructor của `DrillSession` và `DrillRun` để dựng đối tượng đúng tham số — plan này không chép lại vì hai lớp đó không nằm trong phạm vi sửa.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/drill_session.dart';
import 'package:pool_os_v2/data/models/training_session.dart';

void main() {
  test('toTrainingSessionMap phat ra shotsMissed va completedAt', () {
    // Dung mot DrillSession co dung mot DrillRun: 10 lan danh, 7 vao.
    // Tham so chinh xac: xem constructor trong drill_session.dart
    final session = /* dung DrillSession voi drillRuns = [DrillRun(attempts: 10, successes: 7, ...)] */;

    final map = session.toTrainingSessionMap();

    expect(map.containsKey('shotsMissed'), isTrue,
        reason: 'thieu khoa nay thi model dich doc ra 0');
    expect(map['shotsMissed'], equals(3));
    expect(map.containsKey('completedAt'), isTrue,
        reason: 'thieu khoa nay thi buoi tap mang gio doc');

    // Vong tron: map -> model phai giu nguyen y nghia
    final restored = TrainingSession.fromJson(map);
    expect(restored.shotsMade, equals(7));
    expect(restored.shotsMissed, equals(3));
    expect(restored.shotsAttempted, equals(10));
  });
}
```

- [ ] **Step 2: Chạy test, xác nhận ĐỎ**

```bash
flutter test test/data/models/drill_session_map_test.dart
```

Kỳ vọng: FAIL — `containsKey('shotsMissed')` là `false`.

- [ ] **Step 3: Sửa nguồn phát**

Trong `lib/data/models/drill_session.dart`, nhánh `drillRuns.isNotEmpty` (dòng 221-231), đổi hai khoá:

```dart
      return {
        'id': id,
        'drillCode': run.drillCode,
        'drillName': run.drillName,
        'level': run.level,
        'score': run.successRate.round(),
        'shotsMade': run.successes,
        'shotsMissed': run.attempts - run.successes,
        'duration': totalMinutes > 0 ? totalMinutes : run.durationSeconds ~/ 60,
        'completedAt': (completedAt ?? DateTime.now()).toIso8601String(),
      };
```

Đọc tiếp nhánh `return` thứ hai (dòng ~233 trở đi) và áp cùng cách đổi: bỏ `shotsAttempted`, thêm `shotsMissed`, đổi `date` thành `completedAt`. Nếu nhánh đó không có trường số cú thì chỉ đổi `date`.

- [ ] **Step 4: Chạy test, xác nhận XANH**

```bash
flutter test test/data/models/drill_session_map_test.dart test/data/models/training_session_test.dart
```

Kỳ vọng: PASS cả hai file.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/drill_session.dart test/data/models/drill_session_map_test.dart
git commit -m "fix(model): toTrainingSessionMap phat khoa chuan shotsMissed/completedAt

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Hợp nhất bản ghi buổi tập — một model, một key, một đường ghi

**Files:**
- Modify: `lib/core/providers/training_provider.dart` (xoá class `TrainingSession` inline, rewire `TrainingNotifier`)
- Modify: `lib/core/providers/coach_provider.dart:168,242,746,759` (`session.date` → `session.completedAt`)
- Modify: `lib/core/providers/dashboard_provider.dart:265` (xem Step 5)
- Modify: `test/unit/coach_integration_test.dart` (constructor đổi)
- Test: `test/training/session_record_unified_test.dart` (tạo mới)

**Interfaces:**
- Consumes: `TrainingSession` từ `lib/data/models/training_session.dart` (Task 1); `DrillRepository.getTrainingHistory({int? limit})` và `DrillRepository.saveTrainingSession(TrainingSession)` — **đã có sẵn**, không sửa interface
- Produces: `TrainingNotifier(Ref ref, {bool autoStart = true, TrainingState? initialState})`; `trainingNotifierProvider`; `TrainingState.sessions` → `List<TrainingSession>` (model chuẩn)

**Đây là task chứng minh bug.** Test ở Step 1 phải ĐỎ trước khi sửa. Nếu nó xanh ngay thì giả thuyết sai — **dừng lại, báo cáo, đừng sửa tiếp**.

- [ ] **Step 1: Viết test hồi quy — phải ĐỎ**

Tạo `test/training/session_record_unified_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart';
import 'package:pool_os_v2/core/providers/training_provider.dart';
import 'package:pool_os_v2/data/models/training_session.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSourceInitHelper.init();
  });

  test('buoi tap luu qua notifier phai hien ra o repository', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(trainingNotifierProvider.notifier);
    final repo = container.read(drillRepositoryProvider);

    await notifier.addSession(TrainingSession(
      id: 's1',
      drillCode: 'BT01',
      drillName: 'Bai 1',
      level: 1,
      score: 70,
      shotsMade: 7,
      shotsMissed: 3,
      duration: 10,
      completedAt: DateTime(2026, 9, 17),
    ));

    final history = await repo.getTrainingHistory();

    expect(history.map((s) => s.id), contains('s1'),
        reason: 'hai ban ghi tach roi: notifier ghi vao drill_sessions, '
            'repository doc tu training_history');
  });

  test('buoi tap luu qua repository phai hien ra o notifier sau refresh', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repo = container.read(drillRepositoryProvider);
    await repo.saveTrainingSession(TrainingSession(
      id: 's2',
      drillCode: 'BT02',
      drillName: 'Bai 2',
      level: 1,
      score: 80,
      shotsMade: 8,
      shotsMissed: 2,
      duration: 12,
      completedAt: DateTime(2026, 9, 17),
    ));

    final notifier = container.read(trainingNotifierProvider.notifier);
    await notifier.refresh();

    expect(
      container.read(trainingNotifierProvider).sessions.map((s) => s.id),
      contains('s2'),
    );
  });
}
```

**Lưu ý về `LocalStorageDataSourceInitHelper`:** đó là chỗ giữ chỗ — thay bằng import và gọi thật:

```dart
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
// ...
await LocalStorageDataSource.init();
```

Task 4 sẽ chuyển `LocalStorageService` đi, nhưng ở task này `main.dart` vẫn init cả hai nên test chỉ cần `LocalStorageDataSource.init()`. Nếu test báo lỗi *"LocalStorageService not initialized"*, thêm `await LocalStorageService.init();` vào `setUp` và gỡ nó ở Task 4.

- [ ] **Step 2: Chạy test, xác nhận ĐỎ**

```bash
flutter test test/training/session_record_unified_test.dart
```

Kỳ vọng: FAIL ở test thứ nhất — `history` rỗng, không chứa `'s1'`.

**Cổng kiểm:** nếu test này XANH thì giả thuyết của spec sai. Dừng, báo cáo, không sửa tiếp.

- [ ] **Step 3: Viết lại `training_provider.dart`**

Thay toàn bộ nội dung `lib/core/providers/training_provider.dart` bằng:

```dart
// ============================================================================
// TRAINING PROVIDER
// ============================================================================
// Buoi tap di qua DrillRepository, KHONG cham storage truc tiep.
// Nho vay Sprint 3 (noi Directus) chi phai doi mot dong o
// repository_providers.dart.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/training_session.dart';
import 'repository_providers.dart';

class TrainingState {
  final List<TrainingSession> sessions;
  final bool isLoading;
  final String? error;

  const TrainingState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  TrainingState copyWith({
    List<TrainingSession>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return TrainingState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrainingNotifier extends StateNotifier<TrainingState> {
  /// [autoStart] va [initialState] la khe cho test. Mac dinh giu nguyen
  /// hanh vi cu nen ma chay that khong doi. Cung khuon voi
  /// CoachStateNotifier — xem .claude/memory/poolos.md muc 9.
  TrainingNotifier(
    this._ref, {
    bool autoStart = true,
    TrainingState? initialState,
  }) : super(initialState ?? const TrainingState()) {
    if (autoStart) _loadData();
  }

  final Ref _ref;

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final sessions =
          await _ref.read(drillRepositoryProvider).getTrainingHistory();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addSession(TrainingSession session) async {
    try {
      await _ref.read(drillRepositoryProvider).saveTrainingSession(session);
      state = state.copyWith(sessions: [session, ...state.sessions]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }

  Map<String, dynamic> getStats() {
    final sessions = state.sessions;
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalMinutes': 0,
        'avgScore': 0,
        'totalShots': 0,
      };
    }

    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.duration);
    final avgScore =
        sessions.fold<int>(0, (sum, s) => sum + s.score) ~/ totalSessions;
    final totalShots = sessions.fold<int>(0, (sum, s) => sum + s.shotsMade);

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'avgScore': avgScore,
      'totalShots': totalShots,
    };
  }

  List<TrainingSession> getSessionsByDrill(String drillCode) {
    return state.sessions.where((s) => s.drillCode == drillCode).toList();
  }

  List<TrainingSession> getSessionsInRange(DateTime start, DateTime end) {
    return state.sessions.where((s) {
      return s.completedAt.isAfter(start) && s.completedAt.isBefore(end);
    }).toList();
  }
}

final trainingNotifierProvider =
    StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
  return TrainingNotifier(ref);
});

final trainingStatsProvider = Provider<Map<String, dynamic>>((ref) {
  ref.watch(trainingNotifierProvider);
  return ref.read(trainingNotifierProvider.notifier).getStats();
});
```

**Ba thay đổi có chủ ý, đừng bỏ sót:**
1. `updateSession` và `deleteSession` **bị xoá** — không ai gọi (đã truy toàn repo).
2. `getSessionsInRange` dùng `s.completedAt` thay `s.date`.
3. `trainingStatsProvider` thêm `ref.watch(trainingNotifierProvider)`. Bản cũ chỉ `ref.read` nên **không bao giờ tính lại** khi có buổi tập mới. Lỗi có sẵn, sửa luôn vì đang đứng ngay đây.

- [ ] **Step 4: Sửa 4 chỗ `session.date` trong `coach_provider.dart`**

Dòng 168, 242, 746, 759 — đổi `session.date` thành `session.completedAt`. Không đổi gì khác.

- [ ] **Step 5: Xem `dashboard_provider.dart:265`**

Dòng đó đang là `final date = session.date as DateTime?;`. Mở đọc ngữ cảnh: nếu `session` ở đó là `TrainingSession` của model chuẩn thì đổi thành `session.completedAt` và **bỏ ép kiểu** (`completedAt` vốn là `DateTime` không nullable). Nếu nó là `Map` hoặc `dynamic` từ nguồn khác thì để nguyên và ghi lại lý do trong commit message.

- [ ] **Step 6: Sửa `test/unit/coach_integration_test.dart`**

File dựng `TrainingSession` bằng constructor cũ. Với mỗi chỗ dựng (khoảng dòng 29, 46, 72, 83):
- Bỏ `shotsAttempted: N`, thay bằng `shotsMade: M` và `shotsMissed: N - M`
- Đổi `date:` thành `completedAt:`
- Thêm `level:` và `score:` nếu constructor mới đòi (cả hai là `required`)

Dòng 98 (`sum + s.shotsAttempted`) **giữ nguyên** — getter dẫn xuất vẫn đúng tên.

Cập nhật luôn chú thích ở đầu file (dòng 10-11) cho khớp thực tế.

- [ ] **Step 7: Chạy test hồi quy, xác nhận XANH**

```bash
flutter test test/training/session_record_unified_test.dart test/unit/coach_integration_test.dart
```

Kỳ vọng: PASS hết.

- [ ] **Step 8: Kiểm bằng đột biến**

Theo bài học ở `.claude/memory/poolos.md` mục 9 — test xanh chưa chắc test đúng.

Tạm đổi `addSession` để nó **không** gọi repository (comment dòng `saveTrainingSession`), chạy lại test hồi quy. Nó **phải ĐỎ**. Nếu vẫn xanh thì test đang khẳng định thứ khác chứ không phải đường đi thật — sửa test. Khôi phục lại dòng vừa comment sau khi kiểm xong.

- [ ] **Step 9: Chạy toàn bộ suite**

```bash
flutter analyze && flutter test
```

Kỳ vọng: 0 error. Test đỏ nào còn lại phải sửa trước khi commit.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "fix(training): hop nhat hai ban ghi buoi tap ve mot duong ghi

Truoc day training_provider ghi vao key drill_sessions va chi minh no doc;
LocalDrillRepository ghi vao training_history ma dashboard + coach doc. Buoi
tap ghi qua duong nay khong bao gio hien o duong kia.

Nay TrainingNotifier di qua DrillRepository, dung model chuan o
data/models/training_session.dart. Xoa class TrainingSession khai inline,
xoa updateSession/deleteSession (khong ai goi), bo truong improvement
(khong noi nao doc).

Sua kem: trainingStatsProvider chi ref.read nen khong bao gio tinh lai.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Gộp kho — xoá `LocalStorageService`

**Files:**
- Modify: `lib/data/datasources/local/local_storage_datasource.dart` (nhận 3 nhóm key)
- Modify: `lib/data/repositories/cache_repository.dart` (trỏ sang kho mới)
- Modify: `lib/core/providers/coach_provider.dart:211,414,419,426,781` (đổi tên lớp)
- Modify: `lib/main.dart` (bỏ một dòng init)
- Delete: `lib/core/services/local_storage_service.dart`
- Test: `test/data/local_store_merge_test.dart` (tạo mới)

**Interfaces:**
- Consumes: `LocalStorageDataSource.prefs`, `.getJson`, `.setJson` — đã có sẵn
- Produces: `LocalStorageDataSource.getLatestMatchAnalysis()` → `Map<String, dynamic>?` (đồng bộ); `.saveLatestMatchAnalysis(Map)`; `.clearLatestMatchAnalysis()`; `.getPlayerIntelligence()` → `Map<String, dynamic>?` (đồng bộ); `.savePlayerIntelligence(Map)`; `.getKnowledgeProgress()` → `Future<Map<String, dynamic>>`

**Giữ nguyên chữ ký đồng bộ/bất đồng bộ như bản cũ** — `getLatestMatchAnalysis` và `getPlayerIntelligence` là **đồng bộ** (không `Future`) ở `LocalStorageService`, và `coach_provider` gọi chúng không `await`. Đổi thành async sẽ làm vỡ chỗ gọi.

- [ ] **Step 1: Viết test đỏ**

Tạo `test/data/local_store_merge_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSource.init();
  });

  test('latest_match_analysis: luu roi doc lai', () async {
    await LocalStorageDataSource.saveLatestMatchAnalysis({'score': 7});
    expect(LocalStorageDataSource.getLatestMatchAnalysis(), equals({'score': 7}));

    await LocalStorageDataSource.clearLatestMatchAnalysis();
    expect(LocalStorageDataSource.getLatestMatchAnalysis(), isNull);
  });

  test('player_intelligence: luu roi doc lai', () async {
    await LocalStorageDataSource.savePlayerIntelligence({'level': 3});
    expect(LocalStorageDataSource.getPlayerIntelligence(), equals({'level': 3}));
  });

  test('giu nguyen ten key nen du lieu cu van doc duoc', () async {
    SharedPreferences.setMockInitialValues({
      'latest_match_analysis': '{"score":9}',
      'player_intelligence': '{"level":5}',
    });
    await LocalStorageDataSource.init();

    expect(LocalStorageDataSource.getLatestMatchAnalysis(), equals({'score': 9}));
    expect(LocalStorageDataSource.getPlayerIntelligence(), equals({'level': 5}));
  });
}
```

- [ ] **Step 2: Chạy test, xác nhận ĐỎ**

```bash
flutter test test/data/local_store_merge_test.dart
```

Kỳ vọng: FAIL — các method chưa tồn tại trên `LocalStorageDataSource`.

- [ ] **Step 3: Thêm 3 nhóm key vào `LocalStorageDataSource`**

Thêm hai hằng khoá vào khối `// Keys` (sau dòng `_keyFirstLaunch`):

```dart
  static const String _keyLatestMatchAnalysis = 'latest_match_analysis';
  static const String _keyPlayerIntelligence = 'player_intelligence';
```

Thêm khối method (đặt trước method `clearAll`):

```dart
  // ==========================================================================
  // Coach — phan tich tran gan nhat & ho so nang luc
  // Chuyen tu LocalStorageService (17/9/2026). Chu ky DONG BO giu nguyen
  // nhu ban cu vi coach_provider goi khong await.
  // ==========================================================================

  static Future<void> saveLatestMatchAnalysis(
      Map<String, dynamic> analysis) async {
    await prefs.setString(_keyLatestMatchAnalysis, jsonEncode(analysis));
  }

  static Map<String, dynamic>? getLatestMatchAnalysis() {
    final data = prefs.getString(_keyLatestMatchAnalysis);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> clearLatestMatchAnalysis() async {
    await prefs.remove(_keyLatestMatchAnalysis);
  }

  static Future<void> savePlayerIntelligence(
      Map<String, dynamic> intelligence) async {
    await prefs.setString(_keyPlayerIntelligence, jsonEncode(intelligence));
  }

  static Map<String, dynamic>? getPlayerIntelligence() {
    final data = prefs.getString(_keyPlayerIntelligence);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }
```

**`knowledge_progress`:** `LocalStorageDataSource` đã có sẵn `getKnowledgeProgress()`. Giữ nó, và **xoá `saveKnowledgeProgress(Map)`** (không ai gọi).

Thêm hai dòng vào `clearAll()`:

```dart
    await prefs.remove(_keyLatestMatchAnalysis);
    await prefs.remove(_keyPlayerIntelligence);
```

- [ ] **Step 4: Chạy test, xác nhận XANH**

```bash
flutter test test/data/local_store_merge_test.dart
```

Kỳ vọng: PASS, 3 test.

- [ ] **Step 5: Trỏ `cache_repository.dart` sang kho mới**

Thay import ở dòng 17:

```dart
import '../datasources/local/local_storage_datasource.dart';
```

Thay thân `LocalCacheRepository` (dòng 32-46):

```dart
class LocalCacheRepository implements ICacheRepository {
  @override
  String? getString(String key) => LocalStorageDataSource.prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      LocalStorageDataSource.prefs.setString(key, value);

  @override
  Set<String> getKeys() => LocalStorageDataSource.prefs.getKeys();

  @override
  Future<Map<String, dynamic>> getKnowledgeProgress() =>
      LocalStorageDataSource.getKnowledgeProgress();
}
```

Sửa luôn chú thích ở dòng 9 và 25 đang nhắc `LocalStorageService`.

- [ ] **Step 6: Đổi 5 chỗ gọi trong `coach_provider.dart`**

Dòng 211, 414, 419, 426, 781 — đổi `LocalStorageService.` thành `LocalStorageDataSource.`. Sửa import ở đầu file cho khớp.

- [ ] **Step 7: Xoá `LocalStorageService` và dòng init**

```bash
git rm lib/core/services/local_storage_service.dart
```

Trong `lib/main.dart`, xoá dòng `await LocalStorageService.init();` (dòng 75) và import của nó.

- [ ] **Step 8: Xác nhận không còn tham chiếu nào**

```bash
grep -rn "LocalStorageService" lib/ test/ --include=*.dart
```

Kỳ vọng: **không có kết quả nào**. Còn chỗ nào thì sửa nốt (có thể còn trong `test/drill_session_recovery_test.dart` — đổi sang `LocalStorageDataSource.init()`).

- [ ] **Step 9: Chạy toàn bộ suite**

```bash
flutter analyze && flutter test
```

Kỳ vọng: 0 error, toàn bộ test xanh.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "refactor(storage): gop ve mot kho local duy nhat

Chuyen 3 nhom key con song sang LocalStorageDataSource, GIU NGUYEN ten key
nen du lieu da luu doc duoc nhu cu. Xoa LocalStorageService cung 11 method
khong ai goi.

Chu ky dong bo cua getLatestMatchAnalysis/getPlayerIntelligence giu nguyen
vi coach_provider goi khong await.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Chốt hạ và cập nhật tài liệu

**Files:**
- Modify: `BACKLOG.md` (mục Sprint 5)
- Modify: `.claude/memory/poolos.md` (nếu học được bẫy mới)

- [ ] **Step 1: Chạy đủ ba vòng kiểm**

```bash
flutter analyze
flutter test
```

Kỳ vọng: 0 error; số test **nhiều hơn** mốc 920 trước đợt này (đã thêm ~10 test).

- [ ] **Step 2: Xác nhận bug đã hết bằng đường thật**

```bash
flutter test test/training/session_record_unified_test.dart --reporter expanded
```

Kỳ vọng: cả hai test PASS.

- [ ] **Step 3: Cập nhật `BACKLOG.md`**

Ở mục **Sprint 5 — Local-first + Sync**, gạch dòng *"Hợp nhất 2 kho local"* và ghi kết quả thật:

```markdown
- [x] ~~Hợp nhất 2 kho local~~ — XONG 17/9/2026. Ghi chú: key
      `knowledge_progress` trùng nhau **không phải** bug đang sống (không bên
      nào ghi vào nó). Bug thật là buổi tập nằm ở hai bản ghi tách rời
      (`drill_sessions` vs `training_history`) nên dashboard và Coach không
      thấy buổi tập ghi qua `training_provider`. Xem
      `docs/superpowers/specs/2026-09-17-gop-kho-local-design.md`.
```

Thêm một dòng vào mục TODO cho việc đã phát hiện nhưng chưa sửa:

```markdown
- [ ] Mục "Tiến độ kiến thức" ở màn Profile luôn rỗng — không gì ghi vào
      `knowledge_progress`. Quyết định: nối `markKnowledgeAsRead` vào màn đọc
      kiến thức, hoặc gỡ mục đó khỏi Profile.
```

- [ ] **Step 4: Ghi memory nếu có bẫy mới**

Chỉ ghi nếu học được thứ **còn đúng sau ba tháng**. Ứng viên: *"đổi model mà quên nguồn phát `toJson`/`toMap` thì `fromJson` trả mặc định im lặng — số 0 và `DateTime.now()`, không lỗi nào nổ"*. Nếu ghi, thêm vào `.claude/memory/poolos.md` **mục 9**, đừng tạo file mới.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "docs: cap nhat BACKLOG sau khi gop kho local

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Tự kiểm plan này

**Phủ spec:**

| Mục spec | Task |
|---|---|
| 4 — gộp kho, giữ tên key | Task 4 |
| 5.1 — model chuẩn, getter dẫn xuất, bỏ `improvement` | Task 1, Task 3 |
| 5.2 — đổi `date` → `completedAt` 6 chỗ | Task 3 Step 4-6 |
| 5.3 — đường ghi qua `DrillRepository`, xoá `update`/`deleteSession` | Task 3 Step 3 |
| 5.4 — khe test `autoStart`/`initialState` | Task 3 Step 3 |
| 6 — test hồi quy phải đỏ trước | Task 3 Step 1-2, kiểm đột biến Step 8 |
| 7 — lỗi tiến độ kiến thức, không sửa | Task 5 Step 3 (ghi vào BACKLOG) |

**Hai điểm plan này bổ sung so với spec** (phát hiện khi đọc mã để viết plan):

1. **`toTrainingSessionMap()` phát ra khoá cũ** `shotsAttempted`/`date`. Spec không nhắc. Nếu bỏ qua, mọi buổi tập mới sẽ có `shotsMissed = 0` và `completedAt` = giờ đọc. Task 1 + Task 2 xử lý bằng hai lớp: nguồn phát đúng, bên đọc vẫn đỡ được dữ liệu cũ.
2. **`trainingStatsProvider` chỉ `ref.read`** nên không bao giờ tính lại. Lỗi có sẵn, sửa trong Task 3 vì đang đứng ngay đó.

**Đính chính spec:** spec liệt kê `test/unit/sprint14_product_verification_test.dart` là file cần sửa. Sai — file đó dùng `TrainingSessionData` (lớp của Coach AI), không phải model bị đổi. Nó không vỡ. Hai file thật sự cần chú ý: `test/unit/coach_integration_test.dart` (chắc chắn vỡ) và `test/drill_session_recovery_test.dart` (gọi `LocalStorageService.init()`, vỡ ở Task 4).
