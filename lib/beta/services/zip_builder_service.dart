// ============================================================================
// ZIP Builder Service — Phase B.5
// Creates the ZIP package for export
// ============================================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

/// Creates ZIP package for Black Box export
class ZipBuilderService {
  /// Build ZIP file and return path
  Future<String> buildZip({
    required Map<String, String> files,
    required String testerId,
    String? outputPath,
  }) async {
    final archive = Archive();

    // Add all files to archive
    for (final entry in files.entries) {
      final path = entry.key;
      final content = entry.value;

      // Convert string to bytes
      final bytes = Uint8List.fromList(content.codeUnits);

      // Add to archive
      archive.addFile(ArchiveFile(path, bytes.length, bytes));
    }

    // Encode as ZIP
    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception('Failed to encode ZIP');
    }

    // Generate filename
    final timestamp = DateTime.now();
    final timestampStr = _formatTimestamp(timestamp);
    final zipName = 'PoolOS_Coach_v2.0_${testerId}_$timestampStr.zip';

    // Get output path
    final output = outputPath ?? await _getDefaultOutputPath();
    final zipPath = '$output/$zipName';

    // Ensure directory exists
    final dir = Directory(output);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Write ZIP file
    final file = File(zipPath);
    await file.writeAsBytes(zipData);

    debugPrint('BlackBox: ZIP created at $zipPath');

    return zipPath;
  }

  /// Build ZIP and return as bytes
  Future<Uint8List> buildZipBytes({
    required Map<String, String> files,
  }) async {
    final archive = Archive();

    for (final entry in files.entries) {
      final bytes = Uint8List.fromList(entry.value.codeUnits);
      archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
    }

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception('Failed to encode ZIP');
    }

    return Uint8List.fromList(zipData);
  }

  /// Get the default output directory
  Future<String> _getDefaultOutputPath() async {
    // Try Downloads directory first
    if (Platform.isAndroid) {
      try {
        final downloads = Directory('/storage/emulated/0/Download/PoolOS');
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        return downloads.path;
      } catch (e) {
        debugPrint('BlackBox: Could not use Downloads, using app directory');
      }
    }

    // Fallback to app documents directory
    final docs = await getApplicationDocumentsDirectory();
    final poolOS = Directory('${docs.path}/PoolOS');
    if (!await poolOS.exists()) {
      await poolOS.create(recursive: true);
    }
    return poolOS.path;
  }

  /// List existing ZIP files
  Future<List<BlackBoxZipInfo>> listExports() async {
    final output = await _getDefaultOutputPath();
    final dir = Directory(output);

    if (!await dir.exists()) {
      return [];
    }

    final files = await dir.list().toList();
    final zips = <BlackBoxZipInfo>[];

    for (final file in files) {
      if (file is File && file.path.endsWith('.zip')) {
        final stat = await file.stat();
        final name = file.path.split('/').last;

        // Parse filename: PoolOS_Coach_v2.0_A01_20260807_2115.zip
        final parts = name.split('_');
        String? testerId;
        DateTime? createdAt;

        if (parts.length >= 5) {
          testerId = parts[3];
          try {
            final dateStr = parts[4];
            final timeStr = parts.length > 5 ? parts[5].replaceAll('.zip', '') : '0000';
            createdAt = DateTime.parse('${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}T${timeStr.substring(0, 2)}:${timeStr.substring(2, 4)}:00');
          } catch (e) {
            createdAt = stat.modified;
          }
        }

        zips.add(BlackBoxZipInfo(
          path: file.path,
          name: name,
          testerId: testerId ?? 'unknown',
          createdAt: createdAt ?? stat.modified,
          size: stat.size,
        ));
      }
    }

    // Sort by date, newest first
    zips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return zips;
  }

  /// Delete an export
  Future<void> deleteExport(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      debugPrint('BlackBox: Deleted $path');
    }
  }

  /// Get total size of exports
  Future<int> getTotalExportSize() async {
    final exports = await listExports();
    int total = 0;
    for (final exp in exports) {
      total += exp.size;
    }
    return total;
  }

  /// Clean up old exports (keep last N)
  Future<void> cleanupOldExports({int keepLast = 10}) async {
    final exports = await listExports();
    if (exports.length <= keepLast) return;

    // Delete oldest exports
    for (int i = keepLast; i < exports.length; i++) {
      await deleteExport(exports[i].path);
    }

    debugPrint('BlackBox: Cleaned up old exports, kept $keepLast');
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}_${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Format size for display
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Info about a ZIP export
class BlackBoxZipInfo {
  final String path;
  final String name;
  final String testerId;
  final DateTime createdAt;
  final int size;

  BlackBoxZipInfo({
    required this.path,
    required this.name,
    required this.testerId,
    required this.createdAt,
    required this.size,
  });

  String get formattedSize {
    final kb = size / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
