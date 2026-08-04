import '../../data/datasources/local/local_storage_datasource.dart';
import '../../data/repositories/drill_repository.dart';
import '../../data/models/training_session.dart';
import '../../data/models/drill_progress.dart';

/// Local Drill Repository Implementation
class LocalDrillRepository implements DrillRepository {
  @override
  Future<List<DrillInfo>> getAllDrills() async {
    final data = await LocalStorageDataSource.getDrills();
    return data.map((json) => DrillInfo(
      code: json['code'],
      nameVi: json['nameVi'],
      nameEn: json['nameEn'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      difficulty: json['difficulty'],
      description: json['description'],
      estimatedMinutes: json['estimatedMinutes'],
      icon: json['icon'],
      levels: List<int>.from(json['levels']),
    )).toList();
  }

  @override
  Future<List<DrillInfo>> getDrillsByCategory(String categoryId) async {
    final drills = await getAllDrills();
    return drills.where((d) => d.categoryId == categoryId).toList();
  }

  @override
  Future<DrillInfo?> getDrillByCode(String drillCode) async {
    final drills = await getAllDrills();
    try {
      return drills.firstWhere((d) => d.code == drillCode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DrillCategory>> getCategories() async {
    final drills = await getAllDrills();
    final categoryMap = <String, DrillCategory>{};
    for (final drill in drills) {
      if (!categoryMap.containsKey(drill.categoryId)) {
        categoryMap[drill.categoryId] = DrillCategory(
          id: drill.categoryId,
          name: drill.categoryName,
          icon: drill.icon,
          order: _getCategoryOrder(drill.categoryId),
        );
      }
    }
    return categoryMap.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  int _getCategoryOrder(String categoryId) {
    const order = {'basics': 1, 'position': 2, 'spin': 3, 'bank': 4, 'safety': 5, 'advanced': 6};
    return order[categoryId] ?? 99;
  }

  @override
  Future<List<DrillProgress>> getUserProgress() async {
    final data = await LocalStorageDataSource.getDrillProgress();
    return data.map((json) => DrillProgress.fromJson(json)).toList();
  }

  @override
  Future<DrillProgress?> getDrillProgress(String drillCode) async {
    final progress = await getUserProgress();
    try {
      return progress.firstWhere((p) => p.drillCode == drillCode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateDrillProgress(DrillProgress progress) async {
    final allProgress = await LocalStorageDataSource.getDrillProgress();
    final index = allProgress.indexWhere((p) => p['drillCode'] == progress.drillCode);
    if (index != -1) {
      allProgress[index] = progress.toJson();
    } else {
      allProgress.add(progress.toJson());
    }
    await LocalStorageDataSource.saveDrillProgress(allProgress);
  }

  @override
  Future<List<TrainingSession>> getTrainingHistory({int? limit}) async {
    var data = await LocalStorageDataSource.getTrainingHistory();
    data = data.map((json) {
      json['id'] = json['id'] ?? json['drillCode'];
      return json;
    }).toList();

    if (limit != null && data.length > limit) {
      data = data.take(limit).toList();
    }
    return data.map((json) => TrainingSession.fromJson(json)).toList();
  }

  @override
  Future<void> saveTrainingSession(TrainingSession session) async {
    final history = await LocalStorageDataSource.getTrainingHistory();
    history.insert(0, session.toJson());
    await LocalStorageDataSource.saveTrainingHistory(history);
  }

  @override
  Future<List<DrillInfo>> getRecommendedDrills() async {
    final drills = await getAllDrills();
    final progress = await getUserProgress();
    final completedCodes = progress.map((p) => p.drillCode).toSet();

    // Return drills not yet completed
    return drills.where((d) => !completedCodes.contains(d.code)).take(5).toList();
  }

  @override
  Future<void> markDrillCompleted(String drillCode, int level) async {
    final progress = await getUserProgress();
    final existing = progress.where((p) => p.drillCode == drillCode).toList();

    final newProgress = DrillProgress(
      drillCode: drillCode,
      currentLevel: level,
      bestScore: existing.isNotEmpty ? existing.first.bestScore : 100,
      attempts: (existing.isNotEmpty ? existing.first.attempts : 0) + 1,
      completedAt: DateTime.now(),
    );
    await updateDrillProgress(newProgress);
  }
}
