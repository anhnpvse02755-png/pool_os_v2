// ============================================================================
// Black Box Provider — Coordinates all Black Box services
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/black_box_manifest.dart';
import '../services/event_recorder_service.dart';
import '../services/replay_builder_service.dart';
import '../services/snapshot_builder_service.dart';
import '../services/package_builder_service.dart';
import '../services/zip_builder_service.dart';
import '../services/share_service.dart';
import '../services/feedback_collector_service.dart';

/// Main provider for Black Box functionality
class BlackBoxProvider extends ChangeNotifier {
  // Services
  late final EventRecorderService eventRecorder;
  late final ReplayBuilderService replayBuilder;
  late final SnapshotBuilderService snapshotBuilder;
  late final PackageBuilderService packageBuilder;
  late final ZipBuilderService zipBuilder;
  late final ShareService shareService;
  late final FeedbackCollectorService feedbackCollector;

  // State
  BlackBoxState _state = BlackBoxState.idle;
  String? _lastExportPath;
  String? _error;
  PackagePreview? _preview;
  bool _isInitialized = false;

  // Getters
  BlackBoxState get state => _state;
  String? get lastExportPath => _lastExportPath;
  String? get error => _error;
  PackagePreview? get preview => _preview;
  bool get isInitialized => _isInitialized;
  EventRecorderService get recorder => eventRecorder;
  FeedbackCollectorService get feedback => feedbackCollector;

  /// Initialize all services
  Future<void> initialize({
    String? testerId,
  }) async {
    if (_isInitialized) return;

    try {
      // Create services
      eventRecorder = EventRecorderService();
      replayBuilder = ReplayBuilderService(eventRecorder);
      snapshotBuilder = SnapshotBuilderService();
      zipBuilder = ZipBuilderService();
      shareService = ShareService();
      feedbackCollector = FeedbackCollectorService();

      packageBuilder = PackageBuilderService(
        eventRecorder: eventRecorder,
        replayBuilder: replayBuilder,
        snapshotBuilder: snapshotBuilder,
      );

      // Load events from storage
      await eventRecorder.loadFromStorage();

      // Start recording session
      eventRecorder.startSession();

      _isInitialized = true;
      _state = BlackBoxState.ready;
      notifyListeners();
    } catch (e) {
      _error = 'Initialization failed: $e';
      _state = BlackBoxState.error;
      notifyListeners();
    }
  }

  /// Start a new recording session
  void startSession() {
    eventRecorder.startSession();
    _state = BlackBoxState.ready;
    notifyListeners();
  }

  /// End current session
  void endSession() {
    eventRecorder.endSession();
    notifyListeners();
  }

  /// Record a recommendation shown
  void recordRecommendation({
    required String recommendationId,
    required String drillCode,
    required String drillName,
    required int priority,
    required String reason,
    Map<String, dynamic>? previousPriority,
  }) {
    eventRecorder.recordRecommendationShown(
      recommendationId: recommendationId,
      drillCode: drillCode,
      drillName: drillName,
      priority: priority,
      reason: reason,
      previousPriority: previousPriority,
    );
    notifyListeners();
  }

  /// Record drill start
  void recordDrillStart({
    required String drillCode,
    required String drillName,
    String? source,
    String? recommendationId,
  }) {
    eventRecorder.recordDrillStart(
      drillCode: drillCode,
      drillName: drillName,
      source: source,
      recommendationId: recommendationId,
    );
    notifyListeners();
  }

  /// Record drill completion
  void recordDrillCompleted({
    required String drillCode,
    required String drillName,
    required int score,
    required int shotsAttempted,
    required int shotsMade,
    required int durationSeconds,
    String? recommendationId,
    int? previousSkillScore,
    int? newSkillScore,
  }) {
    eventRecorder.recordDrillCompleted(
      drillCode: drillCode,
      drillName: drillName,
      score: score,
      shotsAttempted: shotsAttempted,
      shotsMade: shotsMade,
      durationSeconds: durationSeconds,
      recommendationId: recommendationId,
      previousSkillScore: previousSkillScore,
      newSkillScore: newSkillScore,
    );
    notifyListeners();
  }

  /// Record drill abandoned
  void recordDrillAbandoned({
    required String drillCode,
    required String drillName,
    required int progress,
    String? recommendationId,
  }) {
    eventRecorder.recordDrillAbandoned(
      drillCode: drillCode,
      drillName: drillName,
      progress: progress,
      recommendationId: recommendationId,
    );
    notifyListeners();
  }

  /// Record Coach Chat opened
  void recordCoachChatOpen({String? conversationId}) {
    eventRecorder.recordCoachChatOpen(conversationId: conversationId);
    notifyListeners();
  }

  /// Record Coach Chat closed
  void recordCoachChatClose({
    required String conversationId,
    required int messagesCount,
    required int durationSeconds,
  }) {
    eventRecorder.recordCoachChatClose(
      conversationId: conversationId,
      messagesCount: messagesCount,
      durationSeconds: durationSeconds,
    );
    notifyListeners();
  }

  /// Record Coach message sent
  void recordCoachMessageSent({
    required String conversationId,
    required String message,
    required String intent,
  }) {
    eventRecorder.recordCoachMessageSent(
      conversationId: conversationId,
      message: message,
      intent: intent,
    );
    notifyListeners();
  }

  /// Record Coach response received
  void recordCoachResponseReceived({
    required String conversationId,
    required String response,
    required String intent,
    String? recommendationId,
  }) {
    eventRecorder.recordCoachResponseReceived(
      conversationId: conversationId,
      response: response,
      intent: intent,
      recommendationId: recommendationId,
    );
    notifyListeners();
  }

  /// Record match started
  void recordMatchStarted({
    required String matchId,
    required String opponentType,
    String? rackType,
  }) {
    eventRecorder.recordMatchStarted(
      matchId: matchId,
      opponentType: opponentType,
      rackType: rackType,
    );
    notifyListeners();
  }

  /// Record match completed
  void recordMatchCompleted({
    required String matchId,
    required String result,
    required int playerScore,
    required int opponentScore,
    required int durationSeconds,
  }) {
    eventRecorder.recordMatchCompleted(
      matchId: matchId,
      result: result,
      playerScore: playerScore,
      opponentScore: opponentScore,
      durationSeconds: durationSeconds,
    );
    notifyListeners();
  }

  /// Record error
  void recordError({
    required String errorType,
    required String message,
    String? screen,
    String? stackTrace,
  }) {
    eventRecorder.recordError(
      errorType: errorType,
      message: message,
      screen: screen,
      stackTrace: stackTrace,
    );
    notifyListeners();
  }

  /// Generate preview
  PackagePreview generatePreview({required String testerId}) {
    _preview = packageBuilder.getPreview(testerId: testerId);
    notifyListeners();
    return _preview!;
  }

  /// Export Black Box package
  Future<String?> exportPackage({
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
  }) async {
    _state = BlackBoxState.exporting;
    _error = null;
    notifyListeners();

    try {
      // End current session
      eventRecorder.endSession();

      // Save events to storage
      await eventRecorder.saveToStorage();

      // Build package
      final files = await packageBuilder.buildPackage(
        testerId: testerId,
        packageId: packageId,
        playerIdentity: playerIdentity,
        playerSkillProfile: playerSkillProfile,
        playerProgress: playerProgress,
        playerMental: playerMental,
        coachState: coachState,
        recommendations: recommendations,
        conversations: conversations,
        sessionSnapshot: sessionSnapshot,
        systemInfo: systemInfo,
        feedback: feedbackCollector.getFeedbackJson(),
      );

      // Build ZIP
      _state = BlackBoxState.compressing;
      notifyListeners();

      _lastExportPath = await zipBuilder.buildZip(
        files: files,
        testerId: testerId,
      );

      _state = BlackBoxState.exported;
      notifyListeners();

      return _lastExportPath;
    } catch (e) {
      _error = 'Export failed: $e';
      _state = BlackBoxState.error;
      notifyListeners();
      return null;
    }
  }

  /// Share the exported package
  Future<bool> sharePackage({String? subject, String? text}) async {
    if (_lastExportPath == null) return false;

    return await shareService.shareZip(
      zipPath: _lastExportPath!,
      subject: subject ?? 'PoolOS Coach Package',
      text: text ?? 'Coach AI Debug Package',
    );
  }

  /// Save to Downloads
  Future<String?> saveToDownloads() async {
    if (_lastExportPath == null) return null;

    return await shareService.saveToDownloads(zipPath: _lastExportPath!);
  }

  /// Get replay summary
  ReplaySummary getReplaySummary() {
    return replayBuilder.getSummary();
  }

  /// Validate replay
  ReplayValidation validateReplay() {
    return replayBuilder.validate();
  }

  /// Start feedback collection
  void startFeedbackCollection() {
    feedbackCollector.startFeedbackCollection();
    notifyListeners();
  }

  /// Clear all data
  Future<void> clearAll() async {
    eventRecorder.clear();
    feedbackCollector.clear();
    _lastExportPath = null;
    _error = null;
    _preview = null;
    _state = BlackBoxState.ready;
    notifyListeners();
  }
}

/// Black Box state
enum BlackBoxState {
  idle,
  initializing,
  ready,
  exporting,
  compressing,
  exported,
  error,
}

// ReplaySummary and ReplayValidation are exported from replay_builder_service.dart
