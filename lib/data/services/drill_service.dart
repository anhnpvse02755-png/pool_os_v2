import 'dart:convert';
import 'package:flutter/services.dart';

/// Drill Service - loads and manages drill data
class DrillService {
  static Map<String, dynamic>? _drillsData;
  static List<Map<String, dynamic>>? _drills;
  static List<Map<String, dynamic>>? _categories;

  /// Load drills from JSON asset
  static Future<void> loadDrills() async {
    if (_drillsData != null) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/drills_data.json');
      _drillsData = json.decode(jsonString);
      _drills = List<Map<String, dynamic>>.from(_drillsData!['drills']);
      _categories = List<Map<String, dynamic>>.from(_drillsData!['categories']);
    } catch (e) {
      _drills = [];
      _categories = [];
    }
  }

  /// Get all drills
  static List<Map<String, dynamic>> getAllDrills() {
    return _drills ?? [];
  }

  /// Get all categories
  static List<Map<String, dynamic>> getCategories() {
    return _categories ?? [];
  }

  /// Get drills by category
  static List<Map<String, dynamic>> getDrillsByCategory(String categoryId) {
    return (_drills ?? []).where((d) => d['categoryId'] == categoryId).toList();
  }

  /// Get drills by difficulty
  static List<Map<String, dynamic>> getDrillsByDifficulty(String difficulty) {
    return (_drills ?? []).where((d) => d['difficultyLevel'] == difficulty).toList();
  }

  /// Get drills by category and difficulty
  static List<Map<String, dynamic>> getFilteredDrills({
    String? categoryId,
    String? difficulty,
    String? searchQuery,
  }) {
    var drills = _drills ?? [];

    if (categoryId != null && categoryId.isNotEmpty) {
      drills = drills.where((d) => d['categoryId'] == categoryId).toList();
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      drills = drills.where((d) => d['difficultyLevel'] == difficulty).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      drills = drills.where((d) {
        return (d['nameVi'] ?? '').toLowerCase().contains(query) ||
            (d['nameEn'] ?? '').toLowerCase().contains(query) ||
            (d['description'] ?? '').toLowerCase().contains(query);
      }).toList();
    }

    return drills;
  }

  /// Get drill by code
  static Map<String, dynamic>? getDrillByCode(String code) {
    try {
      return (_drills ?? []).firstWhere((d) => d['code'] == code);
    } catch (_) {
      return null;
    }
  }

  /// Get drill count by category
  static int getDrillCountByCategory(String categoryId) {
    return (_drills ?? []).where((d) => d['categoryId'] == categoryId).length;
  }

  /// Get total drill count
  static int getTotalDrillCount() {
    return (_drills ?? []).length;
  }

  /// Get drill count by difficulty
  static Map<String, int> getDrillCountByDifficulty() {
    final counts = <String, int>{
      'Beginner': 0,
      'Intermediate': 0,
      'Advanced': 0,
    };

    for (final drill in (_drills ?? [])) {
      final level = drill['difficultyLevel'] as String?;
      if (level != null && counts.containsKey(level)) {
        counts[level] = counts[level]! + 1;
      }
    }

    return counts;
  }
}
