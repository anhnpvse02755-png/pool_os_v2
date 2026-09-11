import 'dart:io';
import 'dart:convert';
// ============================================================================
// content_validation_test.dart - Sprint-10A
// Content integrity validation tests for drills and knowledge articles
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/utils/drills_library.dart';

void main() {
  group('Drill Library Validation', () {
    late List<Drill> allDrills;

    setUpAll(() {
      allDrills = DrillLibrary.getAllDrills();
    });

    test('no duplicate drill codes', () {
      final codes = allDrills.map((d) => d.code).toList();
      final uniqueCodes = codes.toSet();

      expect(
        codes.length,
        equals(uniqueCodes.length),
        reason: 'Found ${codes.length - uniqueCodes.length} duplicate drill codes',
      );
    });

    test('all drills have required fields', () {
      for (final drill in allDrills) {
        expect(drill.code, isNotEmpty, reason: 'Drill ${drill.code} missing code');
        expect(drill.name, isNotEmpty, reason: 'Drill ${drill.code} missing name');
        expect(drill.nameVi, isNotEmpty, reason: 'Drill ${drill.code} missing nameVi');
        expect(drill.category, isNotEmpty, reason: 'Drill ${drill.code} missing category');
        expect(drill.difficulty, isNotEmpty, reason: 'Drill ${drill.code} missing difficulty');
      }
    });

    test('all drills have valid difficulty levels', () {
      final validDifficulties = ['easy', 'medium', 'hard', 'expert'];

      for (final drill in allDrills) {
        expect(
          validDifficulties.contains(drill.difficulty),
          isTrue,
          reason: 'Drill ${drill.code} has invalid difficulty: ${drill.difficulty}',
        );
      }
    });

    test('all drills have valid categories', () {
      // 10 danh muc tu 6 phan + them Psychology & Rules
      final validCategories = [
        'aiming', 'fundamentals', 'shotmaking', 'positioning',
        'strategy', 'psychology', 'rules', 'equipment',
      ];

      for (final drill in allDrills) {
        expect(
          validCategories.contains(drill.category),
          isTrue,
          reason: 'Drill ${drill.code} has invalid category: ${drill.category}',
        );
      }
    });

    test('all drills have at least one level', () {
      for (final drill in allDrills) {
        expect(
          drill.levels.isNotEmpty,
          isTrue,
          reason: 'Drill ${drill.code} has no levels defined',
        );
      }
    });

    test('all drill levels have valid structure', () {
      for (final drill in allDrills) {
        for (final level in drill.levels) {
          expect(level.level, greaterThan(0),
              reason: 'Drill ${drill.code} has invalid level number');
          expect(level.attempts, greaterThan(0),
              reason: 'Drill ${drill.code} level ${level.level} has 0 attempts');
          expect(level.passCount, lessThanOrEqualTo(level.attempts),
              reason: 'Drill ${drill.code} level ${level.level} passCount > attempts');
        }
      }
    });

    test('knowledgeIds are strings', () {
      for (final drill in allDrills) {
        for (final knowledgeId in drill.knowledgeIds) {
          expect(knowledgeId, isA<String>(),
              reason: 'Drill ${drill.code} has non-string knowledgeId');
          expect(knowledgeId.isNotEmpty, isTrue,
              reason: 'Drill ${drill.code} has empty knowledgeId');
        }
      }
    });

    test('drill count meets minimum threshold', () {
      // 24 bài từ 6 phần nguồn — đủ cho người mới luyện đủ 6 tháng
      expect(allDrills.length, greaterThanOrEqualTo(24),
          reason: 'Expected at least 24 drills, found ${allDrills.length}');
    });

    test('all categories have drills', () {
      final categoriesWithDrills = allDrills.map((d) => d.category).toSet();

      // 8 danh muc tu 6 phan nguon
      final expectedCategories = [
        'aiming', 'fundamentals', 'shotmaking', 'positioning',
        'strategy', 'psychology', 'rules', 'equipment',
      ];

      for (final category in expectedCategories) {
        expect(
          categoriesWithDrills.contains(category),
          isTrue,
          reason: 'Category "$category" has no drills',
        );
      }
    });

    test('difficulty distribution is reasonable', () {
      final difficulties = allDrills.map((d) => d.difficulty).toList();

      final easyCount = difficulties.where((d) => d == 'easy').length;
      final mediumCount = difficulties.where((d) => d == 'medium').length;
      final hardCount = difficulties.where((d) => d == 'hard').length;
      final expertCount = difficulties.where((d) => d == 'expert').length;

      // Should have at least some beginner-friendly drills
      expect(easyCount, greaterThan(0),
          reason: 'No easy drills found - bad for onboarding');

      // Expert drills should be rare
      expect(expertCount, lessThan(allDrills.length ~/ 2),
          reason: 'Too many expert drills');
    });
  });

  group('Cross-Reference Validation', () {
    // Truoc day nhom nay doi chieu voi `knowledgeArticlesVi` — bo 21 bai CHET
    // (khong man nao doc) — va chi `print` canh bao thay vi fail. Ket qua: lien
    // ket drill -> kien thuc hong 0/50 ma khong ai biet.
    //
    // Nay doi chieu voi nguon THAT (assets/knowledge/knowledge.json) va FAIL.
    test('drill knowledgeIds tro toi bai kien thuc co that', () {
      final raw = File('assets/knowledge/knowledge.json').readAsStringSync();
      final ids = (json.decode(raw) as List)
          .map((e) => (e as Map<String, dynamic>)['id'] as String)
          .toSet();
      expect(ids, isNotEmpty);

      final dangling = <String>[];
      for (final drill in DrillLibrary.getAllDrills()) {
        for (final kid in drill.knowledgeIds) {
          if (!ids.contains(kid)) dangling.add('${drill.code} -> $kid');
        }
      }

      expect(dangling, isEmpty,
          reason: 'Bài tập trỏ tới kiến thức không tồn tại: '
              '${dangling.join(" | ")}');
    });

    test('moi bai tap deu gan it nhat mot bai kien thuc', () {
      final orphan = DrillLibrary.getAllDrills()
          .where((d) => d.knowledgeIds.isEmpty)
          .map((d) => d.code)
          .toList();
      expect(orphan, isEmpty,
          reason: 'Bai tap khong gan kien thuc nao: ${orphan.join(', ')}');
    });
  });
}
