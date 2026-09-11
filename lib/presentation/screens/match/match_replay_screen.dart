// ============================================================================
// MATCH REPLAY SCREEN - Sprint-19 Redesign
// Minimalist Luxury Design System
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/match.dart';

/// Match replay screen - step through racks/shots with annotations.
class MatchReplayScreen extends StatefulWidget {
  const MatchReplayScreen({super.key, required this.match});
  final Match match;

  @override
  State<MatchReplayScreen> createState() => _MatchReplayScreenState();
}

class _MatchReplayScreenState extends State<MatchReplayScreen> {
  int _rackIndex = 0;
  int _shotIndex = 0;

  Rack get _currentRack =>
      _rackIndex < widget.match.racks.length ? widget.match.racks[_rackIndex] : _rackDummy();

  Rack _rackDummy() => Rack(
        id: 'empty',
        rackNumber: 0,
        result: 'win',
        createdAt: DateTime.now(),
      );

  void _nextShot() {
    final rack = _currentRack;
    if (_shotIndex + 1 < rack.shots.length) {
      setState(() => _shotIndex++);
    } else if (_rackIndex + 1 < widget.match.racks.length) {
      setState(() {
        _rackIndex++;
        _shotIndex = 0;
      });
    }
  }

  void _prevShot() {
    if (_shotIndex > 0) {
      setState(() => _shotIndex--);
    } else if (_rackIndex > 0) {
      setState(() {
        _rackIndex--;
        _shotIndex = widget.match.racks[_rackIndex].shots.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final rack = _currentRack;
    final shot = rack.shots.isNotEmpty && _shotIndex < rack.shots.length
        ? rack.shots[_shotIndex]
        : null;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surface(brightness),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Replay - Rack ${rack.rackNumber}/${widget.match.racks.length}',
          style: TextStyle(
            color: AppColors.textPrimary(brightness),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(brightness)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(AppSpacing.lg),
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppShadows.soft(brightness),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary(brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        'Shot ${_shotIndex + 1}/${rack.shots.length}',
                        style: TextStyle(
                          color: AppColors.primary(brightness),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: rack.shots.isNotEmpty ? (_shotIndex + 1) / rack.shots.length : 0,
                        backgroundColor: AppColors.background(brightness),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary(brightness)),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                if (shot != null) ...[
                  _DetailRow(label: 'Type', value: shot.shotType),
                  _DetailRow(
                    label: 'Made',
                    value: shot.result == 'made' ? 'Co' : 'Khong',
                    valueColor: shot.result == 'made' ? AppColors.success : AppColors.shotMiss,
                  ),
                  _DetailRow(
                    label: 'Foul',
                    value: shot.result == 'foul' || shot.result == 'scratch' ? 'Co' : 'Khong',
                    valueColor: shot.result == 'foul' || shot.result == 'scratch' ? AppColors.shotMiss : AppColors.success,
                  ),
                  if (shot.playerNote != null && shot.playerNote!.isNotEmpty)
                    _DetailRow(label: 'Note', value: shot.playerNote!),
                ] else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Column(
                        children: [
                          Icon(Icons.gps_off, size: 32, color: AppColors.textTertiary(brightness)),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Khong co shot trong rack nay',
                            style: TextStyle(color: AppColors.textSecondary(brightness), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: Container()),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(child: _PrevButton(onPressed: _prevShot)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: _NextButton(onPressed: _nextShot)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary(brightness),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Prev Button with _PrimaryButton pattern
class _PrevButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const _PrevButton({required this.onPressed});

  @override
  State<_PrevButton> createState() => _PrevButtonState();
}

class _PrevButtonState extends State<_PrevButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final isEnabled = widget.onPressed != null;
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: isEnabled ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: isEnabled ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: isEnabled ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.surface(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isEnabled ? AppColors.primary(brightness).withValues(alpha: 0.3) : AppColors.textTertiary(brightness),
              width: 1.5,
            ),
            boxShadow: isEnabled ? [BoxShadow(color: AppColors.tableLine.withValues(alpha: 0.05), blurRadius: 8, offset: Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_left, color: isEnabled ? AppColors.primary(brightness) : AppColors.textSecondary(brightness), size: 24),
              SizedBox(width: AppSpacing.xs),
              Text('Prev', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isEnabled ? AppColors.primary(brightness) : AppColors.textSecondary(brightness))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Next Button with _PrimaryButton pattern
class _NextButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const _NextButton({required this.onPressed});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final isEnabled = widget.onPressed != null;
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: isEnabled ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: isEnabled ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: isEnabled ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: isEnabled ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness))),
              SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right, color: AppColors.onPrimary(brightness), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
