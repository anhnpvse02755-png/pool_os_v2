// ============================================================================
// MATCH ANALYTICS SCREEN - Sprint-19 Redesign
// Minimalist Luxury Design System
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/match.dart';
import '../../widgets/shot_map_view.dart';
import '../../widgets/pocket_accuracy_widget.dart';

/// Match Analytics Screen - Shows shot map, heat map, and pocket accuracy
class MatchAnalyticsScreen extends ConsumerStatefulWidget {
  const MatchAnalyticsScreen({
    super.key,
    this.matchId,
  });

  final String? matchId;

  @override
  ConsumerState<MatchAnalyticsScreen> createState() => _MatchAnalyticsScreenState();
}

class _MatchAnalyticsScreenState extends ConsumerState<MatchAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Match? _match;
  bool _isLoading = true;
  String? _error;
  bool _showHeatMap = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMatch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatch() async {
    if (widget.matchId == null) {
      setState(() {
        _isLoading = false;
        _error = null;
      });
      return;
    }

    try {
      final repo = ref.read(matchRepositoryProvider);
      final match = await repo.getMatchById(widget.matchId!);

      setState(() {
        _match = match;
        _isLoading = false;
        _error = match == null ? 'Không tìm thấy trận đấu' : null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surface(brightness),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Phân tích trận đấu',
          style: TextStyle(
            color: AppColors.textPrimary(brightness),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_match != null && _match!.racks.isNotEmpty)
            IconButton(
              icon: Icon(
                _showHeatMap ? Icons.layers_clear : Icons.layers,
                color: AppColors.textPrimary(brightness),
              ),
              onPressed: () {
                setState(() {
                  _showHeatMap = !_showHeatMap;
                });
              },
              tooltip: _showHeatMap ? 'Tắt Heat Map' : 'Bật Heat Map',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary(brightness),
          labelColor: AppColors.primary(brightness),
          unselectedLabelColor: AppColors.textSecondary(brightness),
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'Shot Map'),
            Tab(text: 'Heat Map'),
            Tab(text: 'Pocket'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final brightness = Theme.of(context).brightness;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary(brightness),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_match == null) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _ShotMapTab(match: _match!),
        _HeatMapTab(match: _match!),
        _PocketAccuracyTab(match: _match!),
      ],
    );
  }

  Widget _buildErrorState() {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Lỗi: $_error',
              style: TextStyle(
                color: AppColors.textPrimary(brightness),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            _RetryButton(onPressed: _loadMatch),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary(brightness).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 48,
                color: AppColors.primary(brightness).withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chưa có dữ liệu trận đấu',
              style: TextStyle(
                color: AppColors.textPrimary(brightness),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Ghi lại ít nhất 1 trận đấu để xem phân tích',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Retry Button with _PrimaryButton pattern
class _RetryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const _RetryButton({required this.onPressed});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: 140,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Text('Thử lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness)), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// Shot Map Tab Content
class _ShotMapTab extends StatelessWidget {
  const _ShotMapTab({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (match.racks.isEmpty) {
      return _buildNoDataState(context, 'Chưa có dữ liệu shot trong trận đấu này');
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(context),
          SizedBox(height: AppSpacing.lg),

          Text(
            'Shot Map',
            style: TextStyle(
              color: AppColors.textPrimary(brightness),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppShadows.soft(brightness),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: ShotMapView(match: match),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildLegend(context),
          SizedBox(height: AppSpacing.lg),

          _buildStatsSummary(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary(brightness).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary(brightness).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary(brightness), size: 20),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Shot Map hien thi duong di cua cac cu danh. Duong xanh = trung, duong do = truot.',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.ballCue, label: 'Bi trắng', border: AppColors.tableLine),
        SizedBox(width: AppSpacing.md),
        _LegendItem(color: AppColors.ballObject, label: 'Bi mục tiêu'),
        SizedBox(width: AppSpacing.md),
        _LegendItem(color: AppColors.success, label: 'Trúng', line: true),
        SizedBox(width: AppSpacing.md),
        _LegendItem(color: AppColors.shotMiss, label: 'Trượt', line: true),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final totalShots = match.racks.fold<int>(
      0,
      (sum, r) => sum + r.shots.length,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Racks', value: '${match.racks.length}'),
          _StatItem(label: 'Tổng shots', value: '$totalShots'),
          _StatItem(
            label: 'Win Rate',
            value: '${match.winner == 'player' ? 100 : 0}%',
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context, String message) {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gps_off, size: 48, color: AppColors.textTertiary(brightness)),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Heat Map Tab Content
class _HeatMapTab extends StatelessWidget {
  const _HeatMapTab({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (match.racks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gps_off, size: 48, color: AppColors.textTertiary(brightness)),
            SizedBox(height: AppSpacing.md),
            Text(
              'Chưa có dữ liệu shot',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.shotMiss.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.shotMiss.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: AppColors.shotMiss, size: 20),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Heat Map cho thay khu vuc thuong xuyen danh (do = nhieu, xanh = it).',
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          Text(
            'Heat Map',
            style: TextStyle(
              color: AppColors.textPrimary(brightness),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildHeatMapVisualization(context),
          SizedBox(height: AppSpacing.lg),

          _buildHeatAnalysis(context),
        ],
      ),
    );
  }

  Widget _buildHeatMapVisualization(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: _HeatMapCanvas(racks: match.racks),
      ),
    );
  }

  Widget _buildHeatAnalysis(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final totalShots = match.racks.fold<int>(0, (sum, r) => sum + r.shots.length);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích',
            style: TextStyle(
              color: AppColors.textPrimary(brightness),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Tổng số cú đánh: $totalShots',
            style: TextStyle(
              color: AppColors.textPrimary(brightness),
              fontSize: 14,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Dữ liệu heat map được tính từ vị trí shot gần nhất.',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pocket Accuracy Tab Content
class _PocketAccuracyTab extends StatelessWidget {
  const _PocketAccuracyTab({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary(brightness).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primary(brightness).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, color: AppColors.primary(brightness), size: 20),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Pocket Accuracy thể hiện tỉ lệ trúng theo từng lỗ trên bàn.',
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppShadows.soft(brightness),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: PocketAccuracyWidget(racks: match.racks),
            ),
          ),
        ],
      ),
    );
  }
}

/// Heat map canvas widget
class _HeatMapCanvas extends StatelessWidget {
  const _HeatMapCanvas({required this.racks});

  final List<Rack> racks;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: CustomPaint(
        painter: _HeatMapPainter(racks: racks),
        size: Size.infinite,
      ),
    );
  }
}

class _HeatMapPainter extends CustomPainter {
  _HeatMapPainter({required this.racks});

  final List<Rack> racks;

  @override
  void paint(Canvas canvas, Size size) {
    final tablePaint = Paint()..color = AppColors.tableFelt;
    canvas.drawRect(Offset.zero & size, tablePaint);

    final railPaint = Paint()
      ..color = AppColors.tableRail
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRect(Rect.fromLTWH(4, 4, size.width - 8, size.height - 8), railPaint);

    final borderPaint = Paint()
      ..color = AppColors.tableLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Offset.zero & size, borderPaint);

    final pocketPaint = Paint()..color = AppColors.tableLine;
    final pockets = [
      Offset.zero,
      Offset(size.width / 2, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width / 2, size.height),
      Offset(size.width, size.height),
    ];
    for (final p in pockets) {
      canvas.drawCircle(p, 12, pocketPaint);
    }

    if (racks.isEmpty) return;

    const cols = 12, rows = 6;
    final grid = List.generate(rows, (_) => List.filled(cols, 0));

    int shotIndex = 0;
    for (final rack in racks) {
      final shotCount = rack.shots.length;
      if (shotCount == 0) {
        shotIndex++;
        continue;
      }
      final x = (shotIndex % cols);
      final y = (shotIndex ~/ cols) % rows;
      grid[y][x] += shotCount;
      shotIndex++;
    }

    int maxV = 1;
    for (final row in grid) {
      for (final v in row) {
        if (v > maxV) maxV = v;
      }
    }

    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final v = grid[y][x];
        if (v == 0) continue;

        final intensity = (v / maxV).clamp(0.1, 1.0);
        final heatPaint = Paint()
          ..color = AppColors.shotMiss.withValues(alpha: intensity * 0.5);

        canvas.drawRect(
          Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
          heatPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatMapPainter old) => false;
}

/// Legend item widget
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.border,
    this.line = false,
  });

  final Color color;
  final String label;
  final Color? border;
  final bool line;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (line)
          Container(
            width: 20,
            height: 3,
            color: color,
          )
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: border != null ? Border.all(color: border!) : null,
            ),
          ),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(brightness),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
