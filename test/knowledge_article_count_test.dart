import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knowledge.json contains at least 110 articles', () async {
    final raw = await rootBundle.loadString('assets/knowledge/knowledge.json');
    final list = json.decode(raw) as List;
    expect(
      list.length,
      greaterThanOrEqualTo(110),
      reason: 'Expected >= 110 articles in assets/knowledge/knowledge.json. '
          'Found ${list.length}.',
    );
  });

  test('every knowledge entry has required fields', () async {
    final raw = await rootBundle.loadString('assets/knowledge/knowledge.json');
    final list = json.decode(raw) as List;
    for (final entry in list) {
      final m = entry as Map<String, dynamic>;
      expect(m['id'], isNotNull, reason: 'missing id');
      expect(m['slug'], isNotNull, reason: 'missing slug');
      expect(m['title'], isNotNull, reason: 'missing title');
      expect(m['content'], isNotNull, reason: 'missing content');
      expect(m['categoryId'], isNotNull, reason: 'missing categoryId');
      expect(m['difficulty'], isNotNull, reason: 'missing difficulty');
      expect(m['relatedDrillCodes'], isA<List>(),
          reason: 'relatedDrillCodes must be a list');
    }
  });
}
