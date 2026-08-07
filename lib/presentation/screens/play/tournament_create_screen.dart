import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/tournament.dart';

/// Tournament type enum
enum TournamentFormatType {
  roundRobin,
  knockout,
  groupStage,
  combined,
}

/// Extension for tournament format type
extension TournamentFormatTypeExtension on TournamentFormatType {
  String get displayName {
    switch (this) {
      case TournamentFormatType.roundRobin:
        return 'Vòng tròn';
      case TournamentFormatType.knockout:
        return 'Knockout';
      case TournamentFormatType.groupStage:
        return 'Chia bảng';
      case TournamentFormatType.combined:
        return 'Hệ kết hợp';
    }
  }

  String get description {
    switch (this) {
      case TournamentFormatType.roundRobin:
        return 'Mỗi người đấu với tất cả';
      case TournamentFormatType.knockout:
        return 'Thua = Out';
      case TournamentFormatType.groupStage:
        return 'Đấu bảng rồi loại trực tiếp';
      case TournamentFormatType.combined:
        return 'Bảng + Knockout';
    }
  }

  IconData get icon {
    switch (this) {
      case TournamentFormatType.roundRobin:
        return Icons.loop;
      case TournamentFormatType.knockout:
        return Icons.sports_kabaddi;
      case TournamentFormatType.groupStage:
        return Icons.grid_view;
      case TournamentFormatType.combined:
        return Icons.auto_awesome_mosaic;
    }
  }

  String toStorageString() {
    switch (this) {
      case TournamentFormatType.roundRobin:
        return 'round_robin';
      case TournamentFormatType.knockout:
        return 'knockout';
      case TournamentFormatType.groupStage:
        return 'group_stage';
      case TournamentFormatType.combined:
        return 'combined';
    }
  }
}

class TournamentCreateScreen extends StatefulWidget {
  const TournamentCreateScreen({super.key});

  @override
  State<TournamentCreateScreen> createState() => _TournamentCreateScreenState();
}

class _TournamentCreateScreenState extends State<TournamentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Giải PoolOS Mùa 1');
  final _venueController = TextEditingController();

  TournamentFormatType _selectedType = TournamentFormatType.knockout;
  int _participantCount = 8;
  int _raceTo = 3;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<int> _participantOptions = [4, 8, 16, 32];
  final List<int> _raceToOptions = [1, 3, 5, 7];

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày bắt đầu trước'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 7)),
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _createTournament() {
    if (!_formKey.currentState!.validate()) return;

    // Generate tournament ID
    final tournamentId = 'tournament_${DateTime.now().millisecondsSinceEpoch}';

    // Create tournament object
    final tournament = Tournament(
      id: tournamentId,
      name: _nameController.text.trim(),
      type: _selectedType.toStorageString(),
      status: 'upcoming',
      startDate: _startDate,
      endDate: _endDate,
      venue: _venueController.text.trim().isEmpty ? null : _venueController.text.trim(),
      maxParticipants: _participantCount,
      participants: [],
      createdAt: DateTime.now(),
    );

    // Add to library (in real app, this would be saved to database)
    TournamentLibrary.tournaments.insert(0, tournament);

    // Show success and navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tạo giải "${tournament.name}"'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryGreen,
      ),
    );

    // Navigate to tournament management
    context.pushReplacement('/play/tournament/$tournamentId');
  }

  void _cancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huỷ tạo giải?'),
        content: const Text('Dữ liệu đã nhập sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Có, huỷ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo giải đấu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancel,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Name
              _buildSectionTitle('Tên giải *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'VD: Giải PoolOS Mùa 1',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên giải';
                  }
                  return null;
                },
              ).animate().fadeIn(),

              const SizedBox(height: 24),

              // Tournament Type
              _buildSectionTitle('Loại giải *'),
              const SizedBox(height: 12),
              _buildTournamentTypeSelector().animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // Participant Count
              _buildSectionTitle('Số người chơi'),
              const SizedBox(height: 12),
              _buildParticipantSelector().animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Race To
              _buildSectionTitle('Race to (số bi thắng mỗi trận)'),
              const SizedBox(height: 12),
              _buildRaceToSelector().animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Date Selection
              _buildSectionTitle('Thời gian'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Ngày bắt đầu',
                      date: _startDate,
                      onTap: _selectStartDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Ngày kết thúc',
                      date: _endDate,
                      onTap: _selectEndDate,
                      enabled: _startDate != null,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // Venue (optional)
              _buildSectionTitle('Địa điểm (tùy chọn)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  hintText: 'VD: CLB Pool Hà Nội',
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _createTournament,
                      child: const Text('Tạo giải'),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTournamentTypeSelector() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: TournamentFormatType.values.map((type) {
        final isSelected = _selectedType == type;
        return InkWell(
          onTap: () => setState(() => _selectedType = type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  size: 28,
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryGreen : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  type.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParticipantSelector() {
    return Row(
      children: _participantOptions.map((count) {
        final isSelected = _participantCount == count;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: count != _participantOptions.last ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _participantCount = count),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRaceToSelector() {
    return Row(
      children: _raceToOptions.map((value) {
        final isSelected = _raceTo == value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: value != _raceToOptions.last ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _raceTo = value),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool enabled;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
    this.enabled = true,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: enabled ? AppTheme.primaryGreen : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? _formatDate(date!) : label,
                style: TextStyle(
                  color: date != null
                      ? Colors.black87
                      : enabled
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                ),
              ),
            ),
            if (date != null && enabled)
              InkWell(
                onTap: onTap,
                child: const Icon(Icons.edit, size: 18, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
