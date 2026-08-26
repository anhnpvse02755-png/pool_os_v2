import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
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
        SnackBar(
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
        backgroundColor: AppColors.accent,
      ),
    );

    // Navigate to tournament management
    context.pushReplacement('/play/tournament/$tournamentId');
  }

  void _cancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Huỷ tạo giải?'),
        content: Text('Dữ liệu đã nhập sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text('Có, huỷ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo giải đấu'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _cancel,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Name
              _buildSectionTitle('Tên giải *'),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'VD: Giải PoolOS Mùa 1',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên giải';
                  }
                  return null;
                },
              ).animate().fadeIn(),

              SizedBox(height: AppSpacing.xxl),

              // Tournament Type
              _buildSectionTitle('Loại giải *'),
              SizedBox(height: AppSpacing.sm),
              _buildTournamentTypeSelector().animate().fadeIn(delay: 100.ms),

              SizedBox(height: AppSpacing.xxl),

              // Participant Count
              _buildSectionTitle('Số người chơi'),
              SizedBox(height: AppSpacing.sm),
              _buildParticipantSelector().animate().fadeIn(delay: 200.ms),

              SizedBox(height: AppSpacing.xxl),

              // Race To
              _buildSectionTitle('Race to (số bi thắng mỗi trận)'),
              SizedBox(height: AppSpacing.sm),
              _buildRaceToSelector().animate().fadeIn(delay: 300.ms),

              SizedBox(height: AppSpacing.xxl),

              // Date Selection
              _buildSectionTitle('Thời gian'),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Ngày bắt đầu',
                      date: _startDate,
                      onTap: _selectStartDate,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
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

              SizedBox(height: AppSpacing.xxl),

              // venue (optional)
              _buildSectionTitle('Địa điểm (tùy chọn)'),
              SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(
                  hintText: 'VD: CLB Pool Hà Nội',
                ),
              ).animate().fadeIn(delay: 500.ms),

              SizedBox(height: AppSpacing.xxl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      onPressed: _cancel,
                      label: 'Huỷ',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: _PrimaryButton(
                      onPressed: _createTournament,
                      label: 'Tạo giải',
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),

              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildTournamentTypeSelector() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.3,
      children: TournamentFormatType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.lightBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  size: 28,
                  color: isSelected ? AppColors.accent : AppColors.lightTextSecondary,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.accent : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  type.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.lightTextSecondary,
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
              right: count != _participantOptions.last ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _participantCount = count),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.lightTextPrimary,
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
              right: value != _raceToOptions.last ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _raceTo = value),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.lightTextPrimary,
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: enabled ? AppColors.accent : AppColors.lightTextTertiary,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                date != null ? _formatDate(date!) : label,
                style: TextStyle(
                  color: date != null
                      ? AppColors.lightTextPrimary
                      : enabled
                          ? AppColors.lightTextSecondary
                          : AppColors.lightTextTertiary,
                ),
              ),
            ),
            if (date != null && enabled)
              Icon(Icons.edit, size: 18, color: AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _PrimaryButton({required this.onPressed, required this.label});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _SecondaryButton({required this.onPressed, required this.label});

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
