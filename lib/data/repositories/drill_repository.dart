import '../models/training_session.dart';
import '../models/drill_progress.dart';

/// Drill Repository Interface
/// Abstracts data access for drill-related operations
abstract class DrillRepository {
  /// Get all available drills
  Future<List<DrillInfo>> getAllDrills();

  /// Get drills by category
  Future<List<DrillInfo>> getDrillsByCategory(String categoryId);

  /// Get drill by code
  Future<DrillInfo?> getDrillByCode(String drillCode);

  /// Get drill categories
  Future<List<DrillCategory>> getCategories();

  /// Get user's drill progress
  Future<List<DrillProgress>> getUserProgress();

  /// Get progress for specific drill
  Future<DrillProgress?> getDrillProgress(String drillCode);

  /// Update drill progress
  Future<void> updateDrillProgress(DrillProgress progress);

  /// Get training history
  Future<List<TrainingSession>> getTrainingHistory({int? limit});

  /// Save training session
  Future<void> saveTrainingSession(TrainingSession session);

  /// Get recommended drills for user
  Future<List<DrillInfo>> getRecommendedDrills();

  /// Mark drill as completed
  Future<void> markDrillCompleted(String drillCode, int level);
}

/// Drill Info Model (for displaying drill list)
class DrillInfo {
  final String code;
  final String nameVi;
  final String nameEn;
  final String categoryId;
  final String categoryName;
  final int difficulty; // 1-5
  final String description;
  final int estimatedMinutes;
  final String icon;
  final List<int> levels;

  DrillInfo({
    required this.code,
    required this.nameVi,
    required this.nameEn,
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
    required this.description,
    required this.estimatedMinutes,
    required this.icon,
    required this.levels,
  });
}

/// Drill Category Model
class DrillCategory {
  final String id;
  final String name;
  final String icon;
  final int order;

  DrillCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
  });
}
