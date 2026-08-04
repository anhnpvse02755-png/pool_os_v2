// ============================================================================
// hash_utils.dart — SHA256 helpers for deterministic migration
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// Commit 4 will call these to verify body byte-equality.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

class HashUtils {
  /// SHA256 of file bytes (used for body byte-equality verification).
  static Future<String> sha256OfFile(String path) async {
    final bytes = await File(path).readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// SHA256 of a string.
  static String sha256OfString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// SHA256 of an entire directory tree (sorted by path).
  /// Used to verify deterministic migration (IDM-4).
  static Future<String> sha256OfDirectory(String dir) async {
    final entries = Directory(dir).listSync(recursive: true)
      ..sort((a, b) => a.path.compareTo(b.path));

    final digests = <String>[];
    for (final entry in entries.whereType<File>()) {
      final digest = await sha256OfFile(entry.path);
      digests.add('$digest  ${entry.path}');
    }
    // Hash the concatenated digests (deterministic order).
    return sha256OfString(digests.join('\n'));
  }
}