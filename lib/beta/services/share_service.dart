// ============================================================================
// Share Service — Phase B.6
// Handles sharing and saving of Black Box packages
// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:permission_handler/permission_handler.dart';

/// Handles sharing and saving of Black Box packages
class ShareService {
  /// Share the ZIP file using native share sheet
  Future<bool> shareZip({
    required String zipPath,
    String? subject,
    String? text,
  }) async {
    try {
      await share_plus.Share.shareXFiles(
        [share_plus.XFile(zipPath)],
        subject: subject ?? 'PoolOS Coach Package',
        text: text ?? 'Coach AI Debug Package from PoolOS Beta',
      );

      debugPrint('BlackBox: Shared ZIP at $zipPath');
      return true;
    } on PlatformException catch (e) {
      debugPrint('BlackBox: Share failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('BlackBox: Share error: $e');
      return false;
    }
  }

  /// Share ZIP as bytes (for in-memory ZIP)
  Future<bool> shareZipBytes({
    required List<int> zipBytes,
    required String fileName,
    String? subject,
    String? text,
  }) async {
    try {
      // For bytes sharing, we need to save to temp first
      final temp = await _saveToTemp(zipBytes, fileName);
      if (temp == null) {
        debugPrint('BlackBox: Could not save to temp');
        return false;
      }

      return await shareZip(zipPath: temp, subject: subject, text: text);
    } catch (e) {
      debugPrint('BlackBox: Share bytes error: $e');
      return false;
    }
  }

  /// Save ZIP to Downloads folder
  Future<String?> saveToDownloads({
    required String zipPath,
    String? destinationFolder,
  }) async {
    try {
      String destFolder = destinationFolder ?? '/storage/emulated/0/Download/PoolOS';

      // Create directory if needed
      final dir = Directory(destFolder);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Get filename from path
      final fileName = zipPath.split('/').last;
      final destPath = '$destFolder/$fileName';

      // Copy file
      final source = File(zipPath);
      await source.copy(destPath);

      debugPrint('BlackBox: Saved to $destPath');
      return destPath;
    } catch (e) {
      debugPrint('BlackBox: Save to downloads failed: $e');

      // Try alternative: app documents directory
      try {
        return await _saveToAppDirectory(zipPath);
      } catch (e2) {
        debugPrint('BlackBox: Alternative save also failed: $e2');
        return null;
      }
    }
  }

  /// Request storage permissions (Android)
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // For Android 13+, we don't need storage permission for Downloads
      // But for older versions, we might need it
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('BlackBox: Permission request error: $e');
      return false;
    }
  }

  /// Check if we can save to Downloads
  Future<bool> canSaveToDownloads() async {
    if (!Platform.isAndroid) return true;

    try {
      final dir = Directory('/storage/emulated/0/Download');
      return await dir.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get the PoolOS export directory
  Future<String> getExportDirectory() async {
    String baseDir;

    if (Platform.isAndroid) {
      baseDir = '/storage/emulated/0/Download/PoolOS';
    } else {
      baseDir = '${Directory.current.path}/PoolOS';
    }

    final dir = Directory(baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return baseDir;
  }

  /// Save to temp and return path
  Future<String?> _saveToTemp(List<int> bytes, String fileName) async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);
      return tempFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Save to app directory as fallback
  Future<String?> _saveToAppDirectory(String sourcePath) async {
    try {
      // This would use path_provider
      // For now, return the source path
      return sourcePath;
    } catch (e) {
      return null;
    }
  }

  /// Copy ZIP to clipboard (as path reference)
  Future<bool> copyPathToClipboard(String zipPath) async {
    try {
      await Clipboard.setData(ClipboardData(text: zipPath));
      return true;
    } catch (e) {
      debugPrint('BlackBox: Clipboard error: $e');
      return false;
    }
  }
}

/// Simple XFile implementation for sharing
class XFile {
  final String path;

  XFile(this.path);

  String get name => path.split('/').last;

  Future<List<int>> readAsBytes() async {
    final file = File(path);
    return await file.readAsBytes();
  }
}
