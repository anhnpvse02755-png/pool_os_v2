// ============================================================================
// WARMUP PROVIDER - Dac-Ta-Che-Do-Khoi-Dong.md
// Check if warmup done today + log warmup results
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/warmup_models.dart';
import '../../data/datasources/local/local_storage_datasource.dart';

/// Provider: đã warmup hôm nay chưa?
/// Dac-Ta-Che-Do-Khoi-Dong.md: "Chỉ hiện gợi ý 1 lần đầu phiên trong ngày"
final warmupDoneTodayProvider = FutureProvider<bool>((ref) async {
  final logs = await LocalStorageDataSource.getWarmupLogs();
  if (logs.isEmpty) return false;

  final today = DateTime.now();
  final todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  for (final log in logs) {
    if (log['didWarmup'] == true) {
      final logDate = (log['date'] as String).substring(0, 10);
      if (logDate == todayStr) return true;
    }
  }
  return false;
});

/// Provider: số lần đã warmup hôm nay
final warmupCountTodayProvider = FutureProvider<int>((ref) async {
  final logs = await LocalStorageDataSource.getWarmupLogs();
  if (logs.isEmpty) return 0;

  final today = DateTime.now();
  final todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  return logs.where((log) {
    if (log['didWarmup'] != true) return false;
    final logDate = (log['date'] as String).substring(0, 10);
    return logDate == todayStr;
  }).length;
});

/// Provider: ghi nhận kết quả warmup
Future<void> logWarmup({
  required bool didWarmup,
  required double durationActualMinutes,
  required String ledTo,
  List<int> phasesCompleted = const [],
}) async {
  final logs = await LocalStorageDataSource.getWarmupLogs();

  final entry = WarmupLog(
    date: DateTime.now(),
    didWarmup: didWarmup,
    durationActualMinutes: durationActualMinutes,
    ledTo: ledTo,
    phasesCompleted: phasesCompleted,
  ).toJson();

  logs.add(entry);
  await LocalStorageDataSource.saveWarmupLogs(logs);
}
