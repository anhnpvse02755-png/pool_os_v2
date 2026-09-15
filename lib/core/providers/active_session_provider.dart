import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_item.dart';
import '../../knowledge/drill_code_bridge.dart';

/// Kết quả một bài trong buổi tập đang chạy.
class SessionResult {
  final String drillCode;
  final String drillName;
  final int made;
  final int missed;
  final int minutes;

  const SessionResult({
    required this.drillCode,
    required this.drillName,
    required this.made,
    required this.missed,
    required this.minutes,
  });

  int get attempts => made + missed;
  double get accuracy => attempts == 0 ? 0 : made / attempts * 100;
}

/// Trạng thái buổi tập đang chạy: chuỗi bài + con trỏ + kết quả từng bài.
///
/// Các bài ở đây đã được dịch sang mã `DrillLibrary` (BT…), vì màn tập chỉ
/// hiểu mã đó. Xem [ActiveSessionNotifier.start].
class ActiveSessionState {
  final List<SessionItem> items;
  final int currentIndex;
  final List<SessionResult> results;

  const ActiveSessionState({
    this.items = const [],
    this.currentIndex = 0,
    this.results = const [],
  });

  bool get isActive => items.isNotEmpty;

  SessionItem? get current =>
      currentIndex < items.length ? items[currentIndex] : null;

  /// Số thứ tự để hiển thị ("bài 2/3") — đếm từ 1.
  int get position => items.isEmpty ? 0 : currentIndex + 1;
  int get total => items.length;
  bool get isLast => items.isNotEmpty && currentIndex >= items.length - 1;

  int get totalMade => results.fold(0, (s, r) => s + r.made);
  int get totalMissed => results.fold(0, (s, r) => s + r.missed);
  int get totalMinutes => results.fold(0, (s, r) => s + r.minutes);

  /// Độ chính xác cả buổi — tính trên TỔNG số cú, không phải trung bình cộng
  /// của các bài. Một bài 1/10 và một bài 2/2 ra 25%, không phải 55%.
  double get accuracy {
    final attempts = totalMade + totalMissed;
    return attempts == 0 ? 0 : totalMade / attempts * 100;
  }

  ActiveSessionState copyWith({
    List<SessionItem>? items,
    int? currentIndex,
    List<SessionResult>? results,
  }) {
    return ActiveSessionState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
    );
  }
}

/// Tổng kết trả về khi buổi tập kết thúc (hết bài hoặc dừng sớm).
class SessionSummary {
  final List<SessionResult> results;
  final int plannedCount;

  const SessionSummary({required this.results, required this.plannedCount});

  int get completedCount => results.length;
  bool get finishedEarly => completedCount < plannedCount;

  int get totalMade => results.fold(0, (s, r) => s + r.made);
  int get totalMissed => results.fold(0, (s, r) => s + r.missed);
  int get totalMinutes => results.fold(0, (s, r) => s + r.minutes);

  double get accuracy {
    final attempts = totalMade + totalMissed;
    return attempts == 0 ? 0 : totalMade / attempts * 100;
  }
}

class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  ActiveSessionNotifier() : super(const ActiveSessionState());

  /// Bắt đầu một buổi tập từ danh sách bài đề xuất.
  ///
  /// Mã bài của knowledge graph (`BANK_SHOT`…) được dịch sang mã
  /// `DrillLibrary` (`BT14`…) ngay tại đây, để mọi nơi phía sau chỉ còn làm
  /// việc với một hệ mã. Bài nào không dịch được thì bị loại — thà buổi tập
  /// ngắn hơn còn hơn đẩy người dùng vào màn "bài tập không tồn tại".
  void start(List<SessionItem> proposed) {
    final resolved = <SessionItem>[];
    for (final item in proposed) {
      final code = resolveDrillCode(item.drillCode);
      if (code == null) continue;
      resolved.add(item.copyWith(drillCode: code));
    }
    state = ActiveSessionState(items: resolved);
  }

  /// Sang bài kế tiếp. Trả về bài đó, hoặc null nếu đã là bài cuối.
  SessionItem? advance() {
    if (state.isLast || !state.isActive) return null;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
    return state.current;
  }

  /// Ghi kết quả một bài. Gọi lại cùng một mã thì cập nhật, không thêm dòng —
  /// người dùng tập lại một bài không được tính thành hai lần.
  void recordResult({
    required String drillCode,
    required int made,
    required int missed,
    required int minutes,
    String? drillName,
  }) {
    if (!state.isActive) return;

    final name = drillName ??
        state.items
            .firstWhere(
              (i) => i.drillCode == drillCode,
              orElse: () => state.items.first,
            )
            .drillName;

    final result = SessionResult(
      drillCode: drillCode,
      drillName: name,
      made: made,
      missed: missed,
      minutes: minutes,
    );

    final updated = [...state.results];
    final existing = updated.indexWhere((r) => r.drillCode == drillCode);
    if (existing >= 0) {
      updated[existing] = result;
    } else {
      updated.add(result);
    }
    state = state.copyWith(results: updated);
  }

  /// Kết thúc buổi (hết bài hoặc dừng sớm) và trả về tổng kết.
  SessionSummary finish() {
    final summary = SessionSummary(
      results: List.unmodifiable(state.results),
      plannedCount: state.items.length,
    );
    state = const ActiveSessionState();
    return summary;
  }
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>(
  (ref) => ActiveSessionNotifier(),
);
