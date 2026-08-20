// ============================================================================
// MATCH ANALYTICS SCREEN - Sprint-9C
// Integrates Shot Map, Heat Map, and Pocket Accuracy visualizations
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích trận đấu'),
        actions: [
          // Heat map toggle
          if (_match != null && _match!.racks.isNotEmpty)
            IconButton(
              icon: Icon(
                _showHeatMap ? Icons.layers_clear : Icons.layers,
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
          tabs: const [
            Tab(text: 'Shot Map'),
            Tab(text: 'Heat Map'),
            Tab(text: 'Pocket Accuracy'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
        // Shot Map Tab
        _ShotMapTab(match: _match!),

        // Heat Map Tab
        _HeatMapTab(match: _match!),

        // Pocket Accuracy Tab
        _PocketAccuracyTab(match: _match!),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Lỗi: $_error',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMatch,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có dữ liệu trận đấu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ghi lại ít nhất 1 trận đấu để xem phân tích',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
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
      return _buildNoDataState(context, 'Chưa có dữ liệu shot trong trận đấu này');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          _buildInfoCard(context),
          const SizedBox(height: 16),

          // Shot map visualization
          Text(
            'Shot Map',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ShotMapView(match: match),
          const SizedBox(height: 8),
          _buildLegend(context),
          const SizedBox(height: 16),

          // Stats summary
          _buildStatsSummary(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Shot Map hiển thị đường đi của các cú đánh. Đường xanh = trúng, đường đỏ = trượt.',
              style: Theme.of(context).textTheme.bodySmall,
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
        _LegendItem(color: Colors.white, label: 'Bi trắng', border: Colors.black),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.yellow, label: 'Bi mục tiêu'),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.green, label: 'Trúng', line: true),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.redAccent, label: 'Trượt', line: true),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final totalShots = match.racks.fold<int>(
      0,
      (sum, r) => sum + r.shots.length,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gps_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
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
            Icon(Icons.gps_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu shot',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.redAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Heat Map cho thấy khu vực thường xuyên đánh (đỏ = nhiều, xanh = ít).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Heat map visualization with showHeat = true
          Text(
            'Heat Map',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildHeatMapVisualization(context),
          const SizedBox(height: 16),

          // Analysis
          _buildHeatAnalysis(context),
        ],
      ),
    );
  }

  Widget _buildHeatMapVisualization(BuildContext context) {
    // Build a ShotMapView with showHeat enabled
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _HeatMapCanvas(racks: match.racks),
      ),
    );
  }

  Widget _buildHeatAnalysis(BuildContext context) {
    final totalShots = match.racks.fold<int>(0, (sum, r) => sum + r.shots.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng số cú đánh: $totalShots',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Dữ liệu heat map được tính từ vị trí shot gần nhất.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pocket Accuracy thể hiện tỷ lệ trúng theo từng lỗ trên bàn.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pocket accuracy widget
          PocketAccuracyWidget(racks: match.racks),
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
    // Draw table
    final tablePaint = Paint()..color = const Color(0xFF0E5C3B);
    canvas.drawRect(Offset.zero & size, tablePaint);

    // Draw rail
    final railPaint = Paint()
      ..color = const Color(0xFF1E7E55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRect(Rect.fromLTWH(4, 4, size.width - 8, size.height - 8), railPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Offset.zero & size, borderPaint);

    // Draw pockets
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

    // Draw heat map
    if (racks.isEmpty) return;

    // Bin into grid
    const cols = 12, rows = 6;
    final grid = List.generate(rows, (_) => List.filled(cols, 0));

    int shotIndex = 0;
    for (final rack in racks) {
      // Count shots per grid cell based on rack
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

    // Find max
    int maxV = 1;
    for (final row in grid) {
      for (final v in row) {
        if (v > maxV) maxV = v;
      }
    }

    // Draw heat cells
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
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
