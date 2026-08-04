import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'ai_progress_score_card.dart';
import 'coach_profile_panel.dart';
import 'learning_streak_widget.dart';
import 'skill_trend_chart.dart';
import 'streak_widget.dart';

/// Aggregator card — composes multiple Phase A widgets into a single
/// "your progress at a glance" surface.
class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key, this.playerId = ''});
  final String playerId;

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text('Your Progress',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tab,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Score'),
                Tab(text: 'Trend'),
                Tab(text: 'Streaks'),
              ],
            ),
            SizedBox(
              height: 320,
              child: TabBarView(
                controller: _tab,
                children: [
                  SingleChildScrollView(
                    child: AiProgressScoreCard(playerId: widget.playerId),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SkillTrendChart(playerId: widget.playerId),
                        const SizedBox(height: 16),
                        SkillTrendChart(
                          playerId: widget.playerId,
                          skill: 'accuracy',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        StreakWidget(playerId: widget.playerId),
                        const SizedBox(height: 12),
                        const LearningStreakWidget(),
                        const SizedBox(height: 12),
                        CoachProfilePanel(playerId: widget.playerId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}