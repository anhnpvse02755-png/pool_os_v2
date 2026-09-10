import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../widgets/soft_background.dart';

/// Sprint 4C Task 19 - Unified Timeline
///
/// Combines training sessions + match history into a single chronological view.
/// Coach AI reads temporal patterns across domains from this data.
class UnifiedTimelineScreen extends ConsumerStatefulWidget {
  const UnifiedTimelineScreen({super.key});

  @override
  ConsumerState<UnifiedTimelineScreen> createState() => _UnifiedTimelineScreenState();
}

class _UnifiedTimelineScreenState extends ConsumerState<UnifiedTimelineScreen> {
  bool _loading = true;
  String? _error;

  List<_TimelineEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trainingHistory = await ref.read(trainingHistoryProvider.future);
      final matchRepo = ref.read(matchRepositoryProvider);
      final matches = await matchRepo.getAllMatches();

      // Combine and sort by date (newest first)
      final entries = <_TimelineEntry>[];

      for (final session in trainingHistory) {
        entries.add(_TimelineEntry(
          id: session.id,
          type: _EntryType.training,
          date: session.completedAt,
          title: session.drillName,
          subtitle: 'Score: ${session.score}% - ${session.duration}m',
          icon: Icons.fitness_center,
          tone: _TimelineTone.training,
          drillCode: session.drillCode,
        ));
      }

      for (final match in matches) {
        entries.add(_TimelineEntry(
          id: match.id,
          type: _EntryType.match,
          date: match.createdAt,
          title: 'vs ${match.opponentName ?? match.opponent ?? 'Unknown'}',
          subtitle: match.resultSummary ?? '${match.playerScore}-${match.opponentScore}',
          icon: match.isWin ? Icons.emoji_events : Icons.sports,
          tone: match.isWin ? _TimelineTone.win : _TimelineTone.loss,
        ));
      }

      // Sort by date descending
      entries.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// Tông của ô avatar mỗi mục.
  ///
  /// BỘ MÀU ANH EM: ba trạng thái đứng cạnh nhau trong CÙNG một danh sách.
  /// Bản cũ là accent (217°) / success (160°) / error (0°). Ánh xạ `accent`
  /// sang `primary` sẽ đưa mục tập luyện về hue 157–158°, cách `success`
  /// của trận THẮNG đúng 2–3° — một buổi tập và một trận thắng nằm sát nhau
  /// sẽ không phân biệt được. Thắng/thua MANG phán quyết nên giữ nguyên hai
  /// tông ngữ nghĩa; "đã tập một buổi" là một SỰ KIỆN TRUNG TÍNH (điểm số
  /// của nó đã nằm ở dòng phụ) nên nó là thành viên bị hạ màu.
  ///
  /// Kênh "lĩnh vực" (tập vs đấu) không mất gì: nó nằm ở huy hiệu
  /// 'Tập'/'Đấu' ngay bên dưới, primary 158° vs difficultyExpert 262°.
  Color _toneColor(_TimelineTone tone, Brightness brightness) {
    return switch (tone) {
      _TimelineTone.training => AppColors.textSecondary(brightness),
      _TimelineTone.win => AppColors.success,
      _TimelineTone.loss => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SoftBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Lỗi: $_error'))
                : _entries.isEmpty
                    ? _buildEmpty()
                    : _buildTimeline(),
      ),
    );
  }

  Widget _buildEmpty() {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: AppColors.textTertiary(brightness)),
          const SizedBox(height: AppSpacing.lg),
          const Text('Chưa có hoạt động nào'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bắt đầu tập luyện hoặc ghi trận đấu để xem timeline.',
            style: TextStyle(color: AppColors.textSecondary(brightness)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final brightness = Theme.of(context).brightness;

    // Group by date
    final grouped = <String, List<_TimelineEntry>>{};
    final fmt = DateFormat('EEEE, dd/MM');

    for (final entry in _entries) {
      final key = fmt.format(entry.date);
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final dayEntries = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary(brightness),
                  fontSize: 13,
                ),
              ),
            ),
            // Entries for this date
            ...dayEntries.map((e) => _buildEntryCard(e)),
            const SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }

  String _formatDateHeader(String formatted) {
    final now = DateTime.now();
    final today = DateFormat('EEEE, dd/MM').format(now);
    final yesterday = DateFormat('EEEE, dd/MM').format(now.subtract(const Duration(days: 1)));

    if (formatted == today) return 'Hôm nay';
    if (formatted == yesterday) return 'Hôm qua';
    return formatted;
  }

  Widget _buildEntryCard(_TimelineEntry entry) {
    final brightness = Theme.of(context).brightness;
    final toneColor = _toneColor(entry.tone, brightness);
    // Kênh "lĩnh vực": tập 158° vs đấu 262°, cách nhau 104° ở cả hai chế độ.
    final domainColor = entry.type == _EntryType.training
        ? AppColors.primary(brightness)
        : AppColors.difficultyExpert(brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: toneColor.withValues(alpha: 0.15),
          child: Icon(entry.icon, color: toneColor, size: 20),
        ),
        title: Text(
          entry.title,
          style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary(brightness)),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: domainColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                entry.type == _EntryType.training ? 'Tập' : 'Đấu',
                style: TextStyle(
                  fontSize: 10,
                  color: domainColor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(entry.subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(brightness))),
          ],
        ),
        trailing: Text(
          DateFormat('HH:mm').format(entry.date),
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary(brightness)),
        ),
        onTap: () {
          if (entry.type == _EntryType.training) {
            context.push('/training/session/${entry.id}');
          } else {
            context.push('/play/match/${entry.id}/summary');
          }
        },
      ),
    );
  }
}

enum _EntryType { training, match }

/// Tông ngữ nghĩa của một mục, giải ra màu tại lúc dựng.
///
/// Mục được tạo trong `_load()` — không có `BuildContext` an toàn ở đó, nên
/// một `Color` cứng gắn vào model sẽ không bao giờ đổi theo chế độ. Lưu tông
/// thay vì màu là cách duy nhất để `_buildEntryCard` chọn được đúng bản.
enum _TimelineTone { training, win, loss }

class _TimelineEntry {
  final String id;
  final _EntryType type;
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final _TimelineTone tone;
  final String? drillCode;

  _TimelineEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    this.drillCode,
  });
}
