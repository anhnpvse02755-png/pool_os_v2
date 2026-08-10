// ============================================================================
// Test Logging Service
// ============================================================================
// Logs all user actions for testing purposes.
// All actions are stored locally and can be exported as JSON/CSV.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Single log entry
class TestLogEntry {
  final String id;
  final DateTime timestamp;
  final String screen;
  final String actionType; // tap, swipe, navigation, input, scroll, long_press
  final String actionDetails;
  final Map<String, dynamic>? metadata;

  TestLogEntry({
    required this.id,
    required this.timestamp,
    required this.screen,
    required this.actionType,
    required this.actionDetails,
    this.metadata,
  });

  factory TestLogEntry.create({
    required String screen,
    required String actionType,
    required String actionDetails,
    Map<String, dynamic>? metadata,
  }) {
    return TestLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_counter++}',
      timestamp: DateTime.now(),
      screen: screen,
      actionType: actionType,
      actionDetails: actionDetails,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'screen': screen,
        'actionType': actionType,
        'actionDetails': actionDetails,
        if (metadata != null) 'metadata': metadata,
      };

  String toCsvRow() =>
      '$timestamp,$screen,$actionType,"$actionDetails"';
}

int _counter = 0;

/// Singleton service for test logging
class TestLoggingService {
  static final TestLoggingService _instance = TestLoggingService._internal();
  factory TestLoggingService() => _instance;
  TestLoggingService._internal();

  final List<TestLogEntry> _logs = [];
  bool _isEnabled = true;
  DateTime? _sessionStart;

  bool get isEnabled => _isEnabled;
  int get logCount => _logs.length;
  DateTime? get sessionStart => _sessionStart;

  /// Start a new test session
  void startSession() {
    _logs.clear();
    _sessionStart = DateTime.now();
    logAction(
      screen: 'App',
      actionType: 'session_start',
      actionDetails: 'Test session started',
    );
  }

  /// Enable/disable logging
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Log a user action
  void logAction({
    required String screen,
    required String actionType,
    required String actionDetails,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return;

    final entry = TestLogEntry.create(
      screen: screen,
      actionType: actionType,
      actionDetails: actionDetails,
      metadata: metadata,
    );
    _logs.add(entry);
  }

  /// Log tap action
  void logTap(String screen, String widgetName, {String? buttonText}) {
    logAction(
      screen: screen,
      actionType: 'tap',
      actionDetails: buttonText ?? widgetName,
      metadata: {'widget': widgetName, if (buttonText != null) 'text': buttonText},
    );
  }

  /// Log swipe action
  void logSwipe(String screen, String direction, {String? from, String? to}) {
    logAction(
      screen: screen,
      actionType: 'swipe',
      actionDetails: '$direction: ${from ?? 'unknown'} → ${to ?? 'unknown'}',
      metadata: {'direction': direction, 'from': from, 'to': to},
    );
  }

  /// Log navigation
  void logNavigation(String fromScreen, String toScreen, {String? route}) {
    logAction(
      screen: fromScreen,
      actionType: 'navigation',
      actionDetails: '$fromScreen → $toScreen',
      metadata: {'toScreen': toScreen, 'route': route},
    );
  }

  /// Log input
  void logInput(String screen, String field, String value) {
    logAction(
      screen: screen,
      actionType: 'input',
      actionDetails: '$field: $value',
      metadata: {'field': field, 'value': value},
    );
  }

  /// Log scroll
  void logScroll(String screen, double position, {String? direction}) {
    logAction(
      screen: screen,
      actionType: 'scroll',
      actionDetails: direction ?? 'scroll',
      metadata: {'position': position, 'direction': direction},
    );
  }

  /// Log long press
  void logLongPress(String screen, String widgetName) {
    logAction(
      screen: screen,
      actionType: 'long_press',
      actionDetails: widgetName,
      metadata: {'widget': widgetName},
    );
  }

  /// Get all logs as JSON string
  String exportToJson() {
    final data = {
      'sessionStart': _sessionStart?.toIso8601String(),
      'sessionEnd': DateTime.now().toIso8601String(),
      'totalActions': _logs.length,
      'logs': _logs.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Get all logs as CSV string
  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('timestamp,screen,actionType,actionDetails');
    for (final log in _logs) {
      buffer.writeln(log.toCsvRow());
    }
    return buffer.toString();
  }

  /// Save logs to file and return path
  Future<String> saveLogsToFile({bool asJson = true}) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final extension = asJson ? 'json' : 'csv';
    final file = File('${directory.path}/poolos_test_logs_$timestamp.$extension');

    final content = asJson ? exportToJson() : exportToCsv();
    await file.writeAsString(content);

    return file.path;
  }

  /// Share logs using native share
  Future<void> shareLogs({bool asJson = true}) async {
    final filePath = await saveLogsToFile(asJson: asJson);
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'PoolOS Test Logs - ${DateTime.now().toString().substring(0, 10)}',
    );
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
    _sessionStart = null;
  }

  /// Get recent logs (last n entries)
  List<TestLogEntry> getRecentLogs(int count) {
    if (count >= _logs.length) return List.from(_logs);
    return _logs.sublist(_logs.length - count);
  }
}

/// Global instance
final testLogger = TestLoggingService();
