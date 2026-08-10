// ============================================================================
// Package Builder Service — Phase B.4
// Builds the complete Black Box ZIP package
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/black_box_manifest.dart';
import 'event_recorder_service.dart';
import 'replay_builder_service.dart';
import 'snapshot_builder_service.dart';

/// Builds the complete Black Box package
class PackageBuilderService {
  final EventRecorderService _eventRecorder;
  final ReplayBuilderService _replayBuilder;
  final SnapshotBuilderService _snapshotBuilder;

  PackageBuilderService({
    required EventRecorderService eventRecorder,
    required ReplayBuilderService replayBuilder,
    required SnapshotBuilderService snapshotBuilder,
  })  : _eventRecorder = eventRecorder,
        _replayBuilder = replayBuilder,
        _snapshotBuilder = snapshotBuilder;

  /// Build complete package and return map of files
  Future<Map<String, String>> buildPackage({
    required String testerId,
    String? packageId,
    Map<String, dynamic>? playerIdentity,
    Map<String, dynamic>? playerSkillProfile,
    Map<String, dynamic>? playerProgress,
    Map<String, dynamic>? playerMental,
    Map<String, dynamic>? coachState,
    List<Map<String, dynamic>>? recommendations,
    List<Map<String, dynamic>>? conversations,
    Map<String, dynamic>? sessionSnapshot,
    Map<String, dynamic>? systemInfo,
    Map<String, dynamic>? feedback,
    List<Map<String, dynamic>>? errors,
  }) async {
    packageId ??= 'pkg_${DateTime.now().millisecondsSinceEpoch}';

    // Build manifest
    final manifest = _buildManifest(
      testerId: testerId,
      packageId: packageId,
      recommendations: recommendations,
      conversations: conversations,
      errors: errors,
    );

    // Build replay
    final replay = _replayBuilder.buildReplayJson(
      testerId: testerId,
      packageId: packageId,
    );

    final files = <String, String>{};

    // manifest.json
    files['manifest.json'] = const JsonEncoder.withIndent('  ').convert(manifest);

    // replay.json
    files['replay.json'] = const JsonEncoder.withIndent('  ').convert(replay);

    // player/
    if (playerIdentity != null) {
      files['player/identity.json'] = const JsonEncoder.withIndent('  ').convert(playerIdentity);
    }
    if (playerSkillProfile != null) {
      files['player/skill_profile.json'] = const JsonEncoder.withIndent('  ').convert(playerSkillProfile);
    }
    if (playerProgress != null) {
      files['player/progress.json'] = const JsonEncoder.withIndent('  ').convert(playerProgress);
    }
    if (playerMental != null) {
      files['player/mental.json'] = const JsonEncoder.withIndent('  ').convert(playerMental);
    }

    // coach/
    if (coachState != null) {
      files['coach/current_state.json'] = const JsonEncoder.withIndent('  ').convert(coachState);
    }

    // coach/recommendations/
    if (recommendations != null) {
      for (int i = 0; i < recommendations.length; i++) {
        final rec = recommendations[i];
        final id = rec['id'] ?? 'rec_$i';
        files['coach/recommendations/$id.json'] = const JsonEncoder.withIndent('  ').convert(rec);
      }
    }

    // coach/conversations/
    if (conversations != null) {
      for (int i = 0; i < conversations.length; i++) {
        final conv = conversations[i];
        final id = conv['id'] ?? 'conv_$i';
        files['coach/conversations/$id.json'] = const JsonEncoder.withIndent('  ').convert(conv);
      }
    }

    // session/
    if (sessionSnapshot != null) {
      files['session/current.json'] = const JsonEncoder.withIndent('  ').convert(sessionSnapshot);
    }

    // feedback/
    if (feedback != null) {
      files['feedback/responses.json'] = const JsonEncoder.withIndent('  ').convert(feedback);
    }

    // system/
    if (systemInfo != null) {
      files['system/device.json'] = const JsonEncoder.withIndent('  ').convert(systemInfo);
    }
    if (errors != null && errors.isNotEmpty) {
      files['system/errors.json'] = const JsonEncoder.withIndent('  ').convert({
        'schemaVersion': '2.0',
        'crashes': errors.where((e) => e['severity'] == 'crash').toList(),
        'warnings': errors.where((e) => e['severity'] != 'crash').toList(),
      });
    }

    // versions.json
    files['system/versions.json'] = const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': '2.0',
      'app': {
        'name': 'PoolOS',
        'version': systemInfo?['app']?['version'] ?? '1.0.0',
        'build': systemInfo?['app']?['build'] ?? '1',
        'channel': 'beta',
      },
      'components': {
        'schema': '2.0',
        'knowledgeGraph': {'version': '18'},
        'coachBrain': {
          'priorityEngine': '7',
          'coachService': '7',
          'conversationEngine': '7',
        },
      },
    });

    return files;
  }

  /// Build manifest
  BlackBoxManifest _buildManifest({
    required String testerId,
    required String packageId,
    List<Map<String, dynamic>>? recommendations,
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? errors,
  }) {
    final replaySummary = _replayBuilder.getSummary();

    return BlackBoxManifest(
      packageCreated: DateTime.now(),
      testerId: testerId,
      versions: VersionInfo(
        app: AppVersion(
          version: '1.0.0',
          build: '42',
          channel: 'beta',
        ),
        schema: '2.0',
        knowledgeGraph: KnowledgeGraphVersion(
          version: '18',
          totalNodes: 156,
        ),
        coachBrain: CoachBrainVersion(
          priorityEngine: '7',
          coachService: '7',
          conversationEngine: '7',
        ),
      ),
      stats: PackageStats(
        sessionsTotal: replaySummary.drillStarts + replaySummary.drillCompletions,
        sessionsCompleted: replaySummary.drillCompletions,
        sessionsInterrupted: replaySummary.drillAbandons,
        matchesTotal: replaySummary.matchesCompleted,
        recommendationsTotal: recommendations?.length ?? replaySummary.recommendations,
        conversationsTotal: conversations?.length ?? replaySummary.coachChats,
        eventsTotal: replaySummary.totalEvents,
        packageSize: 'calculating...',
      ),
    );
  }

  /// Get package preview (for UI)
  PackagePreview getPreview({
    required String testerId,
    List<Map<String, dynamic>>? recommendations,
    List<Map<String, dynamic>>? conversations,
  }) {
    final summary = _replayBuilder.getSummary();
    final validation = _replayBuilder.validate();

    return PackagePreview(
      testerId: testerId,
      totalEvents: summary.totalEvents,
      totalSessions: summary.drillCompletions,
      totalMatches: summary.matchesCompleted,
      totalRecommendations: recommendations?.length ?? summary.recommendations,
      totalConversations: conversations?.length ?? summary.coachChats,
      totalErrors: summary.errors,
      validation: validation,
      replaySummary: summary,
    );
  }

  /// Estimate package size
  int estimateSize(Map<String, String> files) {
    int total = 0;
    for (final content in files.values) {
      total += content.length;
    }
    return total;
  }

  /// Format size for display
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Package preview for UI
class PackagePreview {
  final String testerId;
  final int totalEvents;
  final int totalSessions;
  final int totalMatches;
  final int totalRecommendations;
  final int totalConversations;
  final int totalErrors;
  final ReplayValidation validation;
  final ReplaySummary replaySummary;

  PackagePreview({
    required this.testerId,
    required this.totalEvents,
    required this.totalSessions,
    required this.totalMatches,
    required this.totalRecommendations,
    required this.totalConversations,
    required this.totalErrors,
    required this.validation,
    required this.replaySummary,
  });

  String get sizeEstimate {
    // Rough estimate: ~500 bytes per event
    final estimated = totalEvents * 500;
    if (estimated < 1024) return '$estimated B';
    if (estimated < 1024 * 1024) return '${(estimated / 1024).toStringAsFixed(1)} KB';
    return '${(estimated / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isValid => validation.isValid;

  List<String> get issues => validation.issues;
}
