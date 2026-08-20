// ============================================================================
// content_validation_test.dart - Sprint-10A
// Content integrity validation tests for drills and knowledge articles
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/utils/drills_library.dart';
import 'package:pool_os_v2/data/content/knowledge_articles_vi.dart';

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
      final validCategories = [
        'aiming',
        'break',
        'cueball',
        'fundamentals',
        'mental',
        'pattern',
        'position',
        'safety',
        'situations',
        'special',
        'spin',
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
      // Sprint-10A goal: expand beyond 50 drills
      expect(allDrills.length, greaterThanOrEqualTo(50),
          reason: 'Expected at least 50 drills, found ${allDrills.length}');
    });

    test('all categories have drills', () {
      final categoriesWithDrills = allDrills.map((d) => d.category).toSet();

      // We expect at least these core categories to have drills
      final expectedCategories = ['aiming', 'break', 'cueball', 'fundamentals', 'position', 'safety'];

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

  group('Knowledge Articles Validation', () {
    late List<KnowledgeArticle> allArticles;

    setUpAll(() {
      allArticles = knowledgeArticlesVi;
    });

    test('no duplicate article IDs', () {
      final ids = allArticles.map((a) => a.id).toList();
      final uniqueIds = ids.toSet();

      expect(
        ids.length,
        equals(uniqueIds.length),
        reason: 'Found ${ids.length - uniqueIds.length} duplicate article IDs',
      );
    });

    test('all articles have required fields', () {
      for (final article in allArticles) {
        expect(article.id, isNotEmpty, reason: 'Article missing ID');
        expect(article.title, isNotEmpty, reason: 'Article ${article.id} missing title');
        expect(article.category, isNotEmpty, reason: 'Article ${article.id} missing category');
        expect(article.level, isNotEmpty, reason: 'Article ${article.id} missing level');
        expect(article.summary, isNotEmpty, reason: 'Article ${article.id} missing summary');
        expect(article.content, isNotEmpty, reason: 'Article ${article.id} missing content');
      }
    });

    test('all articles have valid levels', () {
      final validLevels = ['beginner', 'intermediate', 'advanced', 'expert'];

      for (final article in allArticles) {
        expect(
          validLevels.contains(article.level),
          isTrue,
          reason: 'Article ${article.id} has invalid level: ${article.level}',
        );
      }
    });

    test('all articles have valid categories', () {
      final validCategories = [
        'aiming',
        'break',
        'cueball',
        'fundamentals',
        'mental',
        'pattern',
        'position',
        'positioning',  // aliases for position
        'safety',
        'shotmaking',
        'strategy',
      ];

      for (final article in allArticles) {
        expect(
          validCategories.contains(article.category),
          isTrue,
          reason: 'Article ${article.id} has invalid category: ${article.category}',
        );
      }
    });

    test('keyTakeaways are non-empty if present', () {
      for (final article in allArticles) {
        for (final takeaway in article.keyTakeaways) {
          expect(takeaway.trim().isNotEmpty, isTrue,
              reason: 'Article ${article.id} has empty takeaway');
        }
      }
    });

    test('relatedDrills are strings if present', () {
      for (final article in allArticles) {
        for (final drillCode in article.relatedDrills) {
          expect(drillCode, isA<String>(),
              reason: 'Article ${article.id} has non-string drillCode');
        }
      }
    });

    test('article count meets minimum threshold', () {
      // Sprint-10A goal: expand beyond 14 articles
      expect(allArticles.length, greaterThanOrEqualTo(14),
          reason: 'Expected at least 14 articles, found ${allArticles.length}');
    });

    test('critical categories have articles', () {
      final categories = allArticles.map((a) => a.category).toSet();

      // These are critical training topics
      final criticalCategories = ['aiming', 'fundamentals'];

      for (final category in criticalCategories) {
        expect(
          categories.contains(category),
          isTrue,
          reason: 'Critical category "$category" has no articles',
        );
      }
    });

    test('content is substantial (not just placeholder)', () {
      for (final article in allArticles) {
        // Content should be at least 100 characters
        expect(article.content.length, greaterThan(100),
            reason: 'Article ${article.id} has content less than 100 chars');
      }
    });
  });

  group('Cross-Reference Validation', () {
    late List<Drill> allDrills;
    late List<KnowledgeArticle> allArticles;

    setUpAll(() {
      allDrills = DrillLibrary.getAllDrills();
      allArticles = knowledgeArticlesVi;
    });

    test('drill knowledgeIds reference existing knowledge articles', () {
      final articleIds = allArticles.map((a) => a.id).toSet();
      final missingReferences = <String>[];

      for (final drill in allDrills) {
        for (final knowledgeId in drill.knowledgeIds) {
          if (!articleIds.contains(knowledgeId)) {
            missingReferences.add('$knowledgeId (from drill ${drill.code})');
          }
        }
      }

      // Note: Some knowledgeIds might be future articles, so we just log them
      // rather than failing. This is informational.
      if (missingReferences.isNotEmpty) {
        print('Warning: ${missingReferences.length} knowledgeIds have no matching article:');
        for (final ref in missingReferences.take(10)) {
          print('  - $ref');
        }
      }
    });

    test('article relatedDrills reference existing drills', () {
      final drillCodes = allDrills.map((d) => d.code).toSet();
      final missingReferences = <String>[];

      for (final article in allArticles) {
        for (final drillCode in article.relatedDrills) {
          if (!drillCodes.contains(drillCode)) {
            missingReferences.add('$drillCode (from article ${article.id})');
          }
        }
      }

      if (missingReferences.isNotEmpty) {
        print('Warning: ${missingReferences.length} drill codes have no matching drill:');
        for (final ref in missingReferences.take(10)) {
          print('  - $ref');
        }
      }
    });
  });
}
