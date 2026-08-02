import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class QuickMatchScreen extends StatefulWidget {
  const QuickMatchScreen({super.key});

  @override
  State<QuickMatchScreen> createState() => _QuickMatchScreenState();
}

class _QuickMatchScreenState extends State<QuickMatchScreen> {
  String _selectedGameType = '8-ball';
  String _selectedRaceTo = 'first-to-5';
  String _selectedTable = 'any';

  final List<Map<String, dynamic>> _gameTypes = [
    {'id': '8-ball', 'name': '8-Ball', 'icon': Icons.sports_cricket},
    {'id': '9-ball', 'name': '9-Ball', 'icon': Icons.circle_outlined},
    {'id': 'straight', 'name': 'Straight Pool', 'icon': Icons.linear_scale},
  ];

  final List<Map<String, dynamic>> _raceOptions = [
    {'id': 'first-to-3', 'name': 'First to 3', 'value': 3},
    {'id': 'first-to-5', 'name': 'First to 5', 'value': 5},
    {'id': 'first-to-7', 'name': 'First to 7', 'value': 7},
    {'id': 'unlimited', 'name': 'Unlimited', 'value': -1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đấu nhanh'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Type Selection
            Text(
              'Loại game',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            Row(
              children: _gameTypes.map((type) {
                final isSelected = _selectedGameType == type['id'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _GameTypeCard(
                      icon: type['icon'] as IconData,
                      name: type['name'] as String,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedGameType = type['id'] as String),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // Race Selection
            Text(
              'Đấu đến',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _raceOptions.map((option) {
                final isSelected = _selectedRaceTo == option['id'];
                return ChoiceChip(
                  label: Text(option['name'] as String),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedRaceTo = option['id'] as String),
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                );
              }).toList(),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 24),

            // Table Selection
            Text(
              'Bàn chơi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TableOptionCard(
                    title: 'Bất kỳ',
                    subtitle: 'Ghép nhanh',
                    icon: Icons.shuffle,
                    isSelected: _selectedTable == 'any',
                    onTap: () => setState(() => _selectedTable = 'any'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TableOptionCard(
                    title: 'Chỉ định',
                    subtitle: 'Chọn bàn',
                    icon: Icons.table_restaurant,
                    isSelected: _selectedTable == 'specific',
                    onTap: () => setState(() => _selectedTable = 'specific'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 32),

            // Rules Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rule, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Luật thi đấu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _RuleItem(text: 'Đánh bi cái trước'),
                  _RuleItem(text: 'Không đánh bi đối thủ trước'),
                  _RuleItem(text: 'Không đánh bi vào lỗ sai'),
                  _RuleItem(text: 'Không đánh bi cái ra khỏi bàn'),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _startMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'BẮT ĐẦU TRẬN ĐẤU',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startMatch() {
    final raceValue = _raceOptions
        .firstWhere((o) => o['id'] == _selectedRaceTo)['value'] as int;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange),
            SizedBox(width: 8),
            Text('Đang tìm đối thủ...'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '$_selectedGameType • ${_selectedRaceTo.replaceAll('first-to-', 'FT')}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );

    // Simulate finding opponent
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tính năng đang phát triển'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}

class _GameTypeCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameTypeCard({
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TableOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;

  const _RuleItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
