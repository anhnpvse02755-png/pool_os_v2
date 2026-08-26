// ============================================================================
// MATCH ANALYTICS SCREEN - Sprint-19 Redesign
// Minimalist Luxury Design System
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
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
        _error = match == null ? 'Khong tim thay tran dau' : null;
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Phan tich tran dau',
          style: TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_match != null && _match!.racks.isNotEmpty)
            IconButton(
              icon: Icon(
                _showHeatMap ? Icons.layers_clear : Icons.layers,
                color: AppColors.lightTextPrimary,
              ),
              onPressed: () {
                setState(() {
                  _showHeatMap = !_showHeatMap;
                });
              },
              tooltip: _showHeatMap ? 'Tat Heat Map' : 'Bat Heat Map',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.lightTextSecondary,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Loi: $_error',
              style: TextStyle(
                color: AppColors.lightTextPrimary,
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 48,
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chua co du lieu tran dau',
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Ghi lai it nhat 1 tran dau de xem phan tich',
              style: TextStyle(
                color: AppColors.lightTextSecondary,
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
    return GestureDetector(
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
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Text('Thu lai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
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
    if (match.racks.isEmpty) {
      return _buildNoDataState(context, 'Chua co du lieu shot trong tran dau nay');
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
              color: AppColors.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
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
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.accent, size: 20),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Shot Map hien thi duong di cua cac cu danh. Duong xanh = trung, duong do = truot.',
              style: TextStyle(
                color: AppColors.lightTextSecondary,
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
        _LegendItem(color: Colors.white, label: 'Bi trang', border: Colors.black),
        SizedBox(width: AppSpacing.md),
        _LegendItem(color: Colors.yellow, label: 'Bi muc tieu'),
        SizedBox(width: AppSpacing.md),
        _LegendItem(color: AppColors.success, label: 'Trung', line: true),
        SizedBox(width: AppSpacing.md),
        _LegendItem(color: Colors.redAccent, label: 'Truot', line: true),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final totalShots = match.racks.fold<int>(
      0,
      (sum, r) => sum + r.shots.length,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Racks', value: '${match.racks.length}'),
          _StatItem(label: 'Tong shots', value: '$totalShots'),
          _StatItem(
            label: 'Win Rate',
            value: '${match.winner == 'player' ? 100 : 0}%',
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gps_off, size: 48, color: AppColors.lightTextTertiary),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: TextStyle(
              color: AppColors.lightTextSecondary,
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
    if (match.racks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gps_off, size: 48, color: AppColors.lightTextTertiary),
            SizedBox(height: AppSpacing.md),
            Text(
              'Chua co du lieu shot',
              style: TextStyle(
                color: AppColors.lightTextSecondary,
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
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.redAccent, size: 20),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Heat Map cho thay khu vuc thuong xuyen danh (do = nhieu, xanh = it).',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
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
              color: AppColors.lightTextPrimary,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: _HeatMapCanvas(racks: match.racks),
      ),
    );
  }

  Widget _buildHeatAnalysis(BuildContext context) {
    final totalShots = match.racks.fold<int>(0, (sum, r) => sum + r.shots.length);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phan tich',
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Tong so cu danh: $totalShots',
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Du lieu heat map duoc tinh tu vi tri shot gan nhat.',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, color: AppColors.accent, size: 20),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Pocket Accuracy the hien ti le trung theo tung lo tren ban.',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
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
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
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
    final tablePaint = Paint()..color = const Color(0xFF0E5C3B);
    canvas.drawRect(Offset.zero & size, tablePaint);

    final railPaint = Paint()
      ..color = const Color(0xFF1E7E55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRect(Rect.fromLTWH(4, 4, size.width - 8, size.height - 8), railPaint);

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Offset.zero & size, borderPaint);

    final pocketPaint = Paint()..color = Colors.black;
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
          ..color = Colors.redAccent.withValues(alpha: intensity * 0.5);

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
            color: AppColors.lightTextSecondary,
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
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
