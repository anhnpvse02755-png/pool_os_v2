// ============================================================================
// io.dart — file system abstraction
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// FileSystemAdapter wraps dart:io operations so the rest of the
// pipeline can be tested with an in-memory fake. Today: just the
// read/write/list surface. SHA256 + sorted listing land in Commit 4.
// ============================================================================

import 'dart:io' as io;

class FileSystemAdapter {
  Future<bool> exists(String path) async => io.File(path).exists();

  Future<String> read(String path) async => io.File(path).readAsString();

  Future<void> write(String path, String content) async {
    await io.File(path).parent.create(recursive: true);
    await io.File(path).writeAsString(content, flush: true);
  }

  Future<List<String>> listFiles(String dir, {String? extension}) async {
    final entries = io.Directory(dir).listSync();
    final filtered = entries.whereType<io.File>().where((f) {
      return extension == null || f.path.endsWith(extension);
    }).toList();
    filtered.sort((a, b) => a.path.compareTo(b.path));
    return filtered.map((f) => f.path).toList();
  }
}