// ============================================================================
// Black Box Export Screen — Phase C
// Settings → PoolOS Black Box → Export
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../beta/providers/providers.dart';
import '../../../beta/providers/black_box_provider.dart';
import '../../../beta/services/feedback_collector_service.dart';
import '../../../beta/services/replay_builder_service.dart';
import '../../../beta/services/package_builder_service.dart';

/// Black Box Export Screen
class BlackBoxExportScreen extends ConsumerStatefulWidget {
  const BlackBoxExportScreen({super.key});

  @override
  ConsumerState<BlackBoxExportScreen> createState() => _BlackBoxExportScreenState();
}

class _BlackBoxExportScreenState extends ConsumerState<BlackBoxExportScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize Black Box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blackBoxProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final blackBox = ref.watch(blackBoxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PoolOS Black Box'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(context, blackBox),
    );
  }

  Widget _buildBody(BuildContext context, BlackBoxProvider blackBox) {
    switch (blackBox.state) {
      case BlackBoxState.idle:
      case BlackBoxState.initializing:
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        );

      case BlackBoxState.ready:
        return _buildReadyState(context);

      case BlackBoxState.exporting:
        return _buildExportingState(context, blackBox);

      case BlackBoxState.compressing:
        return _buildCompressingState(context, blackBox);

      case BlackBoxState.exported:
        return _buildExportedState(context, blackBox);

      case BlackBoxState.error:
        return _buildErrorState(context, blackBox);
    }
  }

  Widget _buildReadyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Info Card
          _buildInfoCard(),
          const SizedBox(height: 24),

          // Preview
          _buildPreviewCard(),
          const SizedBox(height: 24),

          // Export Button
          _buildExportButton(context),
          const SizedBox(height: 16),

          // Skip button
          TextButton(
            onPressed: () => _startExport(skipFeedback: true),
            child: const Text('Skip feedback, export now'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.1),
            AppTheme.accentGold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PoolOS Black Box',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete snapshot of Coach AI state',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'What is this?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(Icons.person_outline, 'Your profile & skills'),
          _buildInfoItem(Icons.psychology_outlined, 'Coach recommendations & reasoning'),
          _buildInfoItem(Icons.chat_outlined, 'All conversations'),
          _buildInfoItem(Icons.timeline_outlined, 'Complete event timeline'),
          _buildInfoItem(Icons.feedback_outlined, 'Your feedback'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No account required. No internet required. Anonymous.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade900,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final blackBox = ref.watch(blackBoxProvider);
    final preview = blackBox.preview ?? _generatePreview();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_outlined, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewRow('Sessions', '${preview.totalSessions}'),
          _buildPreviewRow('Matches', '${preview.totalMatches}'),
          _buildPreviewRow('Recommendations', '${preview.totalRecommendations}'),
          _buildPreviewRow('Conversations', '${preview.totalConversations}'),
          _buildPreviewRow('Events', '${preview.totalEvents}'),
          const Divider(height: 24),
          _buildPreviewRow('Package Size', preview.sizeEstimate, highlight: true),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                  color: highlight ? AppTheme.primaryGreen : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _startExport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.upload_outlined),
            SizedBox(width: 8),
            Text(
              'Export Coach Package',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _startExport({bool skipFeedback = false}) async {
    // Generate preview first
    final preview = ref.read(blackBoxProvider.notifier).generatePreview(
      testerId: 'A01', // TODO: Get from settings
    );

    if (!skipFeedback && mounted) {
      // Show feedback dialog first
      final feedback = await _showFeedbackDialog();
      if (feedback == null) return; // User cancelled
    }

    // Start export
    final path = await ref.read(blackBoxProvider.notifier).exportPackage(
      testerId: 'A01', // TODO: Get from settings
    );

    if (path == null && mounted) {
      // Error handled by state
    }
  }

  Future<BlackBoxFeedback?> _showFeedbackDialog() async {
    return await showModalBottomSheet<BlackBoxFeedback>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FeedbackBottomSheet(),
    );
  }

  Widget _buildExportingState(BuildContext context, BlackBoxProvider blackBox) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryGreen),
            const SizedBox(height: 32),
            Text(
              'Building Black Box...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildProgressStep('Recording events', true),
            _buildProgressStep('Building replay', true),
            _buildProgressStep('Creating snapshots', false, active: true),
            _buildProgressStep('Packaging', false),
            _buildProgressStep('Compressing ZIP', false),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressingState(BuildContext context, BlackBoxProvider blackBox) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryGreen),
            const SizedBox(height: 32),
            Text(
              'Compressing...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildProgressStep('Recording events', true),
            _buildProgressStep('Building replay', true),
            _buildProgressStep('Creating snapshots', true),
            _buildProgressStep('Packaging', true),
            _buildProgressStep('Compressing ZIP', false, active: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label, bool completed, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (completed)
            const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20)
          else if (active)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryGreen,
              ),
            )
          else
            Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: completed || active ? null : Colors.grey,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportedState(BuildContext context, BlackBoxProvider blackBox) {
    final path = blackBox.lastExportPath ?? '';
    final fileName = path.split('/').last;
    final size = blackBox.preview?.sizeEstimate ?? '~2 MB';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Black Box Ready!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),

            // Package Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Package', fileName),
                  const Divider(height: 24),
                  _buildInfoRow('Version', '2.0'),
                  const Divider(height: 24),
                  _buildInfoRow('Size', size),
                  const Divider(height: 24),
                  _buildInfoRow('Generated', _formatTime(DateTime.now())),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Share Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _sharePackage(),
                icon: const Icon(Icons.share),
                label: const Text('Share via...'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _savePackage(),
                icon: const Icon(Icons.save_alt),
                label: const Text('Save to Downloads'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () {
                ref.read(blackBoxProvider.notifier).clearAll();
              },
              child: const Text('Export Another'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, BlackBoxProvider blackBox) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Export Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Failed at',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                  Text(
                    blackBox.state.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (blackBox.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Reason',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                    Text(blackBox.error!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Retry Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(blackBoxProvider.notifier).clearAll(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePackage() async {
    final success = await ref.read(blackBoxProvider.notifier).sharePackage();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share failed. Please try again.')),
      );
    }
  }

  void _savePackage() async {
    final path = await ref.read(blackBoxProvider.notifier).saveToDownloads();
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save failed. Please try again.')),
        );
      }
    }
  }

  PackagePreview _generatePreview() {
    return PackagePreview(
      testerId: 'A01',
      totalEvents: 0,
      totalSessions: 0,
      totalMatches: 0,
      totalRecommendations: 0,
      totalConversations: 0,
      totalErrors: 0,
      validation: ReplayValidation(isValid: true, issues: [], totalEvents: 0),
      replaySummary: ReplaySummary(
        totalEvents: 0,
        drillStarts: 0,
        drillCompletions: 0,
        drillAbandons: 0,
        matchesStarted: 0,
        matchesCompleted: 0,
        coachChats: 0,
        recommendations: 0,
        errors: 0,
        sessionStart: null,
        sessionEnd: DateTime.now(),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Feedback Bottom Sheet
class _FeedbackBottomSheet extends StatefulWidget {
  const _FeedbackBottomSheet();

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  int _coachHelpful = 0;
  int _coachUnderstandable = 0;
  int _coachAccurate = 0;
  int _coachRemembering = 0;
  int _coachNatural = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Feedback',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Help us improve Coach AI',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Rating Questions
            _buildRatingQuestion('Coach hữu ích?', _coachHelpful, (v) => setState(() => _coachHelpful = v)),
            _buildRatingQuestion('Coach dễ hiểu?', _coachUnderstandable, (v) => setState(() => _coachUnderstandable = v)),
            _buildRatingQuestion('Coach đúng đắn?', _coachAccurate, (v) => setState(() => _coachAccurate = v)),
            _buildRatingQuestion('Coach nhớ được?', _coachRemembering, (v) => setState(() => _coachRemembering = v)),
            _buildRatingQuestion('Coach tự nhiên?', _coachNatural, (v) => setState(() => _coachNatural = v)),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit & Export'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingQuestion(String question, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < value ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => onChanged(index + 1),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _submitFeedback() {
    // TODO: Save feedback to BlackBoxProvider
    Navigator.pop(context);
  }
}
