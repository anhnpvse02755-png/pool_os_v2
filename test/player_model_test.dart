// ============================================================================
// player_model_test.dart
// ----------------------------------------------------------------------------
// Sprint-17 Part 5C — Player Serialization regression tests.
//
// Tests verify that Player.toJson() includes all required fields for
// round-trip serialization with Player.fromJson().
//
// Root cause: toJson() was missing created_at/updated_at, causing
// fromJson() to throw FormatException when parsing stored player data.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/data/models/player.dart';

void main() {
  group('Player Serialization — Sprint-17 Part 5C', () {
    late Player testPlayer;

    setUp(() {
      testPlayer = Player(
        id: 'test_player_123',
        name: 'Test Player',
        email: 'test@example.com',
        currentLevel: 'B',
        yearsPlaying: 3,
        hoursPerWeek: 5.0,
        createdAt: DateTime(2026, 8, 24, 10, 30, 0),
        updatedAt: DateTime(2026, 8, 24, 10, 30, 0),
      );
    });

    test('1. toJson() includes created_at field', () {
      final json = testPlayer.toJson();

      expect(json.containsKey('created_at'), isTrue,
          reason: 'toJson() must include created_at field');
      expect(json['created_at'], isNotNull,
          reason: 'created_at must not be null');
      expect(json['created_at'], isA<String>(),
          reason: 'created_at must be a String (ISO8601)');
    });

    test('2. toJson() includes updated_at field', () {
      final json = testPlayer.toJson();

      expect(json.containsKey('updated_at'), isTrue,
          reason: 'toJson() must include updated_at field');
      expect(json['updated_at'], isNotNull,
          reason: 'updated_at must not be null');
      expect(json['updated_at'], isA<String>(),
          reason: 'updated_at must be a String (ISO8601)');
    });

    test('3. toJson() produces valid ISO8601 date strings', () {
      final json = testPlayer.toJson();

      final createdAtString = json['created_at'] as String;
      final updatedAtString = json['updated_at'] as String;

      // Should parse without throwing
      expect(() => DateTime.parse(createdAtString), returnsNormally,
          reason: 'created_at must be valid ISO8601');
      expect(() => DateTime.parse(updatedAtString), returnsNormally,
          reason: 'updated_at must be valid ISO8601');
    });

    test('4. toJson -> fromJson round-trip preserves all fields', () {
      final json = testPlayer.toJson();
      final restored = Player.fromJson(json);

      expect(restored.id, equals(testPlayer.id));
      expect(restored.name, equals(testPlayer.name));
      expect(restored.email, equals(testPlayer.email));
      expect(restored.currentLevel, equals(testPlayer.currentLevel));
      expect(restored.yearsPlaying, equals(testPlayer.yearsPlaying));
      expect(restored.hoursPerWeek, equals(testPlayer.hoursPerWeek));
      expect(restored.createdAt.millisecondsSinceEpoch,
          equals(testPlayer.createdAt.millisecondsSinceEpoch),
          reason: 'createdAt must be preserved through round-trip');
      expect(restored.updatedAt.millisecondsSinceEpoch,
          equals(testPlayer.updatedAt.millisecondsSinceEpoch),
          reason: 'updatedAt must be preserved through round-trip');
    });

    test('5. fromJson parses created_at correctly', () {
      final json = testPlayer.toJson();
      final restored = Player.fromJson(json);

      expect(restored.createdAt.year, equals(2026));
      expect(restored.createdAt.month, equals(8));
      expect(restored.createdAt.day, equals(24));
      expect(restored.createdAt.hour, equals(10));
      expect(restored.createdAt.minute, equals(30));
    });

    test('6. fromJson parses updated_at correctly', () {
      final json = testPlayer.toJson();
      final restored = Player.fromJson(json);

      expect(restored.updatedAt.year, equals(2026));
      expect(restored.updatedAt.month, equals(8));
      expect(restored.updatedAt.day, equals(24));
      expect(restored.updatedAt.hour, equals(10));
      expect(restored.updatedAt.minute, equals(30));
    });

    test('7. fromJson with all required fields succeeds', () {
      // Simulate the data that would be stored by createPlayer()
      final json = {
        'id': 'local_1234567890',
        'name': 'Player 5678',
        'current_level': 'B',
        'years_playing': 2,
        'hours_per_week': 5.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Should not throw
      expect(() => Player.fromJson(json), returnsNormally);
    });

    test('8. toJson includes all other required fields', () {
      final json = testPlayer.toJson();

      expect(json['id'], equals('test_player_123'));
      expect(json['name'], equals('Test Player'));
      expect(json['email'], equals('test@example.com'));
      expect(json['current_level'], equals('B'));
      expect(json['years_playing'], equals(3));
      expect(json['hours_per_week'], equals(5.0));
    });

    test('9. Player with null optional fields round-trips', () {
      final minimalPlayer = Player(
        id: 'minimal_player',
        name: 'Minimal',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = minimalPlayer.toJson();
      final restored = Player.fromJson(json);

      expect(restored.id, equals('minimal_player'));
      expect(restored.name, equals('Minimal'));
      expect(restored.email, isNull);
      expect(restored.currentLevel, equals('beginner'));
    });

    test('10. createPlayer -> getCurrentPlayer simulation works', () {
      // Simulate the exact flow in LocalPlayerRepository
      final player = Player(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Simulated Player',
        currentLevel: 'C',
        yearsPlaying: 1,
        hoursPerWeek: 3.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate savePlayer -> toJson
      final savedJson = player.toJson();

      // Verify saved JSON has required fields
      expect(savedJson['created_at'], isNotNull);
      expect(savedJson['updated_at'], isNotNull);

      // Simulate getPlayer -> fromJson
      final loadedPlayer = Player.fromJson(savedJson);

      // Verify loaded player matches original
      expect(loadedPlayer.id, equals(player.id));
      expect(loadedPlayer.name, equals(player.name));
      expect(loadedPlayer.currentLevel, equals(player.currentLevel));
      expect(loadedPlayer.yearsPlaying, equals(player.yearsPlaying));
      expect(loadedPlayer.hoursPerWeek, equals(player.hoursPerWeek));
    });
  });
}
