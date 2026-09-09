// ============================================================================
// DRILL REPOSITORY — local-first, đẩy tiến độ lên Directus khi có thể
// ============================================================================
//
// Vertical slice đầu tiên đưa dữ liệu nghiệp vụ lên server.
//
// Vì sao bọc `DrillRepository` chứ không phải `IDrillProgressRepository`:
// luồng ghi thật của app đi qua `drill_session_screen.dart:250` ->
// `drillRepo.updateDrillProgress(...)`. `IDrillProgressRepository` tuy có
// đầy đủ `recordAttempt` nhưng **không được nối vào đâu cả** — bọc nó thì
// không chứng minh được gì.
//
// Nguyên tắc kiến trúc (giữ tới sprint sync engine):
//   * Local là NGUỒN SỰ THẬT. Mọi thao tác đọc lấy từ local.
//   * Đẩy lên server chạy sau khi ghi local xong, và là việc phụ.
//   * Server hỏng / mất mạng / chưa đăng nhập KHÔNG làm hỏng thao tác của
//     người dùng.
//
// Chưa phải sync engine: không hàng đợi, không kéo về, không xử lý xung đột.
// Đẩy hỏng là mất lần đó. Sprint 5 sẽ thay bằng dirty/updated_at/tombstone.
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/drill_progress.dart';
import '../models/training_session.dart';
import '../remote/directus_client.dart';
import 'drill_repository.dart';

/// Phần chạm mạng, tách ra để test không cần HTTP.
abstract class DrillProgressRemote {
  Future<bool> isSignedIn();
  Future<void> upsert(DrillProgress progress);
}

class DirectusDrillProgressRemote implements DrillProgressRemote {
  DirectusDrillProgressRemote(this._client);

  final DirectusClient _client;

  static const String _collection = 'poolos_drill_progress';

  @override
  Future<bool> isSignedIn() async => (await _client.tokenStore.read()) != null;

  @override
  Future<void> upsert(DrillProgress p) async {
    final fields = {
      'drill_code': p.drillCode,
      'best_level': p.currentLevel,
      'total_attempts': p.attempts,
      'total_successes': p.bestScore,
      'last_practiced_at':
          (p.lastAttemptAt ?? DateTime.now()).toUtc().toIso8601String(),
    };

    // Quyền trên server đã lọc theo `user_created`, nên truy vấn này chỉ thấy
    // bản ghi của chính người đang đăng nhập — không cần lọc thêm playerId.
    final existing = await _client.readItems(_collection, query: {
      'filter[drill_code][_eq]': p.drillCode,
      'limit': 1,
    });

    if (existing.isEmpty) {
      await _client.createItem(_collection, fields);
    } else {
      await _client.updateItem(
          _collection, existing.first['id'] as String, fields);
    }
  }
}

class SyncingDrillRepository implements DrillRepository {
  SyncingDrillRepository({
    required DrillRepository local,
    required DrillProgressRemote remote,
  })  : _local = local,
        _remote = remote;

  final DrillRepository _local;
  final DrillProgressRemote _remote;

  // ---- Ghi: local trước, server sau -----------------------------------------

  @override
  Future<void> updateDrillProgress(DrillProgress progress) async {
    await _local.updateDrillProgress(progress);
    await _pushQuietly(progress);
  }

  @override
  Future<void> markDrillCompleted(String drillCode, int level) async {
    await _local.markDrillCompleted(drillCode, level);
    final updated = await _local.getDrillProgress(drillCode);
    if (updated != null) await _pushQuietly(updated);
  }

  // ---- Còn lại: chuyển thẳng xuống local ------------------------------------

  @override
  Future<List<DrillInfo>> getAllDrills() => _local.getAllDrills();

  @override
  Future<List<DrillInfo>> getDrillsByCategory(String categoryId) =>
      _local.getDrillsByCategory(categoryId);

  @override
  Future<DrillInfo?> getDrillByCode(String drillCode) =>
      _local.getDrillByCode(drillCode);

  @override
  Future<List<DrillCategory>> getCategories() => _local.getCategories();

  @override
  Future<List<DrillProgress>> getUserProgress() => _local.getUserProgress();

  @override
  Future<DrillProgress?> getDrillProgress(String drillCode) =>
      _local.getDrillProgress(drillCode);

  @override
  Future<List<TrainingSession>> getTrainingHistory({int? limit}) =>
      _local.getTrainingHistory(limit: limit);

  @override
  Future<void> saveTrainingSession(TrainingSession session) =>
      _local.saveTrainingSession(session);

  @override
  Future<List<DrillInfo>> getRecommendedDrills() =>
      _local.getRecommendedDrills();

  // ---------------------------------------------------------------------------

  /// Đẩy lên server, nuốt mọi lỗi.
  ///
  /// Cố ý không ném ra ngoài: người dùng vừa tập xong, dữ liệu đã nằm an toàn
  /// ở local. Bắt họ nhìn lỗi mạng ở đây là vô nghĩa.
  Future<void> _pushQuietly(DrillProgress progress) async {
    try {
      if (!await _remote.isSignedIn()) return;
      await _remote.upsert(progress);
    } catch (e) {
      debugPrint('[DrillProgress] không đẩy lên server được: $e');
    }
  }
}
