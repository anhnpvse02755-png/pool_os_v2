import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Edit / Add Screen with Minimalist Luxury design.
class EquipmentEditScreen extends ConsumerStatefulWidget {
  final String? equipmentId;
  const EquipmentEditScreen({super.key, this.equipmentId});

  @override
  ConsumerState<EquipmentEditScreen> createState() =>
      _EquipmentEditScreenState();
}

class _EquipmentEditScreenState extends ConsumerState<EquipmentEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _shaftDiameterCtrl = TextEditingController();
  final _tipDiameterCtrl = TextEditingController();
  final _extensionCtrl = TextEditingController();
  final _caseCtrl = TextEditingController();
  final _chalkCtrl = TextEditingController();
  final _gloveCtrl = TextEditingController();
  final _ferruleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _usageCtrl = TextEditingController();

  String? _category = 'cue';
  String? _cueType = 'playing';
  String? _brand;
  String? _shaftMaterial;
  String? _tipBrand;
  String? _tipHardness;
  String? _balance;
  String? _joint;
  String? _wrap;
  String? _condition;
  DateTime? _purchaseDate;
  DateTime? _lastTipChange;
  bool _isActive = false;
  bool _isBreakCue = false;
  bool _isJumpCue = false;
  bool _isArchived = false;

  Equipment? _existing;

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    if (widget.equipmentId == null) return;
    final repo = ref.read(equipmentRepositoryProvider);
    final existing = await repo.getEquipmentById(widget.equipmentId!);
    if (existing == null) return;
    setState(() {
      _existing = existing;
      _nameCtrl.text = existing.name;
      _modelCtrl.text = existing.modelLabel;
      _weightCtrl.text = existing.weight?.toString() ?? '';
      _shaftDiameterCtrl.text = existing.shaftDiameter?.toString() ?? '';
      _tipDiameterCtrl.text = existing.tipDiameter?.toString() ?? '';
      _extensionCtrl.text = existing.extension ?? '';
      _caseCtrl.text = existing.cueCase ?? '';
      _chalkCtrl.text = existing.chalk ?? '';
      _gloveCtrl.text = existing.glove ?? '';
      _ferruleCtrl.text = existing.ferrule ?? '';
      _notesCtrl.text = existing.notes ?? '';
      _priceCtrl.text = existing.purchasePrice?.toString() ?? '';
      _valueCtrl.text = existing.currentValue?.toString() ?? '';
      _usageCtrl.text = existing.usageHours?.toString() ?? '';
      _category = existing.category;
      _cueType = existing.cueType;
      _brand = existing.brand;
      _shaftMaterial = existing.shaftMaterial;
      _tipBrand = existing.tipBrand;
      _tipHardness = existing.tipHardness;
      _balance = existing.balance;
      _joint = existing.joint;
      _wrap = existing.wrap;
      _condition = existing.condition;
      _purchaseDate = existing.purchaseDate;
      _lastTipChange = existing.lastTipChange;
      _isActive = existing.isActive;
      _isBreakCue = existing.isBreakCue;
      _isJumpCue = existing.isJumpCue;
      _isArchived = existing.isArchived;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _modelCtrl.dispose();
    _weightCtrl.dispose();
    _shaftDiameterCtrl.dispose();
    _tipDiameterCtrl.dispose();
    _extensionCtrl.dispose();
    _caseCtrl.dispose();
    _chalkCtrl.dispose();
    _gloveCtrl.dispose();
    _ferruleCtrl.dispose();
    _notesCtrl.dispose();
    _priceCtrl.dispose();
    _valueCtrl.dispose();
    _usageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tên.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
      return;
    }

    final repo = ref.read(equipmentRepositoryProvider);
    final now = DateTime.now();

    final equipment = (_existing ??
            Equipment(
              id: '',
              name: '',
              category: 'cue',
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
      name: _nameCtrl.text.trim(),
      category: _category ?? 'cue',
      cueType: _category == 'cue' ? _cueType : null,
      brand: _brand,
      model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
      shaftMaterial: _shaftMaterial,
      shaftDiameter: double.tryParse(_shaftDiameterCtrl.text),
      tipBrand: _tipBrand,
      tipDiameter: double.tryParse(_tipDiameterCtrl.text),
      tipHardness: _tipHardness,
      weight: double.tryParse(_weightCtrl.text),
      balance: _balance,
      joint: _joint,
      wrap: _wrap,
      ferrule: _ferruleCtrl.text.trim().isEmpty
          ? null
          : _ferruleCtrl.text.trim(),
      extension: _extensionCtrl.text.trim().isEmpty
          ? null
          : _extensionCtrl.text.trim(),
      cueCase: _caseCtrl.text.trim().isEmpty ? null : _caseCtrl.text.trim(),
      chalk: _chalkCtrl.text.trim().isEmpty ? null : _chalkCtrl.text.trim(),
      glove: _gloveCtrl.text.trim().isEmpty ? null : _gloveCtrl.text.trim(),
      purchaseDate: _purchaseDate,
      purchasePrice: double.tryParse(_priceCtrl.text),
      currentValue: double.tryParse(_valueCtrl.text),
      condition: _condition,
      usageHours: double.tryParse(_usageCtrl.text),
      lastTipChange: _lastTipChange,
      isActive: _category == 'cue' && _isActive,
      isBreakCue: _category == 'cue' && _isBreakCue,
      isJumpCue: _category == 'cue' && _isJumpCue,
      isArchived: _isArchived,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      updatedAt: now,
    );

    if (_existing == null) {
      await repo.createEquipment(equipment);
    } else {
      await repo.updateEquipment(equipment);
    }
    ref.invalidate(allEquipmentProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final isEdit = widget.equipmentId != null;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          isEdit ? 'Chỉnh sửa dụng cụ' : 'Thêm dụng cụ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary(brightness)),
          onPressed: () => context.pop(),
        ),
        actions: [
          _SaveButton(onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildCategorySection(),
            const SizedBox(height: AppSpacing.md),
            _buildIdentitySection(),
            if (_category == 'cue') ...[
              const SizedBox(height: AppSpacing.md),
              _buildCueSection(),
            ],
            const SizedBox(height: AppSpacing.md),
            _buildPriceSection(),
            const SizedBox(height: AppSpacing.md),
            _buildNotesSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section: Category
  // ===========================================================================

  Widget _buildCategorySection() {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: _cardDecoration(brightness),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Category'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: EquipmentConstants.equipmentCategories.map((c) {
              final selected = c == _category;
              return ChoiceChip(
                label: Text(EquipmentConstants.categoryLabels[c]!),
                selected: selected,
                selectedColor: AppColors.primary(brightness),
                backgroundColor: AppColors.background(brightness),
                labelStyle: TextStyle(
                  color: selected ? AppColors.onPrimary(brightness) : AppColors.textSecondary(brightness),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  side: BorderSide(
                    color: selected ? AppColors.primary(brightness) : AppColors.border(brightness),
                  ),
                ),
                onSelected: (_) => setState(() => _category = c),
              );
            }).toList(),
          ),
          if (_category == 'cue') ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cue Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: EquipmentConstants.cueTypes.map((t) {
                final selected = t == _cueType;
                return ChoiceChip(
                  label: Text(EquipmentConstants.cueTypeLabels[t]!),
                  selected: selected,
                  selectedColor: AppColors.warning,
                  backgroundColor: AppColors.background(brightness),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.onPrimary(brightness) : AppColors.textSecondary(brightness),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    side: BorderSide(
                      color: selected ? AppColors.warning : AppColors.border(brightness),
                    ),
                  ),
                  onSelected: (_) => setState(() => _cueType = t),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // Section: Identity
  // ===========================================================================

  Widget _buildIdentitySection() {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: _cardDecoration(brightness),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Identity'),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nameCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Tên dụng cụ *'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _brand,
            value: _brand,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Brand'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.cueBrands.map((b) =>
                  DropdownMenuItem(value: b, child: Text(b))),
            ],
            onChanged: (v) => setState(() => _brand = v),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _modelCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Model'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section: Cue specs
  // ===========================================================================

  Widget _buildCueSection() {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: _cardDecoration(brightness),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Specifications'),
          const SizedBox(height: AppSpacing.md),

          // Shaft
          DropdownButtonFormField<String>(
            initialValue: _shaftMaterial,
            value: _shaftMaterial,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Shaft material'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.shaftMaterials.map((m) =>
                  DropdownMenuItem(value: m, child: Text(m))),
            ],
            onChanged: (v) => setState(() => _shaftMaterial = v),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<double>(
            initialValue: _shaftDiameterCtrl.text.isEmpty
                ? null
                : double.tryParse(_shaftDiameterCtrl.text),
            value: _shaftDiameterCtrl.text.isEmpty
                ? null
                : double.tryParse(_shaftDiameterCtrl.text),
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Shaft diameter (mm)'),
            items: EquipmentConstants.shaftDiameters
                .map((d) => DropdownMenuItem(
                      value: d,
                      child: Text('${d.toStringAsFixed(2)} mm'),
                    ))
                .toList(),
            onChanged: (v) =>
                setState(() => _shaftDiameterCtrl.text = v?.toString() ?? ''),
          ),
          const SizedBox(height: AppSpacing.md),

          // Tip
          DropdownButtonFormField<String>(
            initialValue: _tipBrand,
            value: _tipBrand,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Tip brand'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.tipBrands.map((b) =>
                  DropdownMenuItem(value: b, child: Text(b))),
            ],
            onChanged: (v) => setState(() => _tipBrand = v),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<double>(
            initialValue: _tipDiameterCtrl.text.isEmpty
                ? null
                : double.tryParse(_tipDiameterCtrl.text),
            value: _tipDiameterCtrl.text.isEmpty
                ? null
                : double.tryParse(_tipDiameterCtrl.text),
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Tip diameter (mm)'),
            items: EquipmentConstants.tipDiameters
                .map((d) => DropdownMenuItem(
                      value: d,
                      child: Text('${d.toStringAsFixed(2)} mm'),
                    ))
                .toList(),
            onChanged: (v) =>
                setState(() => _tipDiameterCtrl.text = v?.toString() ?? ''),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _tipHardness,
            value: _tipHardness,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Tip hardness'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.tipHardnesses.map((h) =>
                  DropdownMenuItem(value: h, child: Text(h))),
            ],
            onChanged: (v) => setState(() => _tipHardness = v),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Last tip change',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
            ),
            subtitle: Text(
              _lastTipChange == null
                  ? 'Not set'
                  : _formatDate(_lastTipChange!),
              style: TextStyle(
                color: AppColors.textPrimary(brightness),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.pastelFor(0, brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(Icons.calendar_today, color: AppColors.primary(brightness), size: 18),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _lastTipChange ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _lastTipChange = picked);
            },
          ),

          Divider(color: AppColors.border(brightness)),
          const SizedBox(height: AppSpacing.md),

          // Butt
          TextFormField(
            controller: _weightCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Weight (oz)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _balance,
            value: _balance,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Balance'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.balances.map((b) =>
                  DropdownMenuItem(value: b, child: Text(b))),
            ],
            onChanged: (v) => setState(() => _balance = v),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _joint,
            value: _joint,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Joint'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.joints.map((j) =>
                  DropdownMenuItem(value: j, child: Text(j))),
            ],
            onChanged: (v) => setState(() => _joint = v),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _wrap,
            value: _wrap,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Wrap'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.wraps.map((w) =>
                  DropdownMenuItem(value: w, child: Text(w))),
            ],
            onChanged: (v) => setState(() => _wrap = v),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _ferruleCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Ferrule'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _extensionCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Extension'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _caseCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Cue case'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _chalkCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Chalk brand'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _gloveCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Glove'),
          ),

          Divider(color: AppColors.border(brightness)),
          const SizedBox(height: AppSpacing.md),

          // Roles
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Active playing cue',
              style: TextStyle(color: AppColors.textPrimary(brightness)),
            ),
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeColor: AppColors.primary(brightness),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Active break cue',
              style: TextStyle(color: AppColors.textPrimary(brightness)),
            ),
            value: _isBreakCue,
            onChanged: (v) => setState(() => _isBreakCue = v),
            activeColor: AppColors.warning,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Active jump cue',
              style: TextStyle(color: AppColors.textPrimary(brightness)),
            ),
            value: _isJumpCue,
            onChanged: (v) => setState(() => _isJumpCue = v),
            activeColor: AppColors.primary(brightness),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section: Pricing
  // ===========================================================================

  Widget _buildPriceSection() {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: _cardDecoration(brightness),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Purchase & Condition'),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Purchase date',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
            ),
            subtitle: Text(
              _purchaseDate == null
                  ? 'Not set'
                  : _formatDate(_purchaseDate!),
              style: TextStyle(
                color: AppColors.textPrimary(brightness),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.pastelFor(0, brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(Icons.calendar_today, color: AppColors.primary(brightness), size: 18),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _purchaseDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _purchaseDate = picked);
            },
          ),
          TextFormField(
            controller: _priceCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Purchase price (USD)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _valueCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Current value (USD)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _condition,
            value: _condition,
            dropdownColor: AppColors.surface(brightness),
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Condition'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              ...EquipmentConstants.conditions.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (v) => setState(() => _condition = v),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _usageCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: _inputDecoration('Usage hours'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Archive',
              style: TextStyle(color: AppColors.textPrimary(brightness)),
            ),
            subtitle: Text(
              'Hide from main list',
              style: TextStyle(color: AppColors.textSecondary(brightness), fontSize: 12),
            ),
            value: _isArchived,
            onChanged: (v) => setState(() => _isArchived = v),
            activeColor: AppColors.textSecondary(brightness),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section: Notes
  // ===========================================================================

  Widget _buildNotesSection() {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: _cardDecoration(brightness),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Notes'),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesCtrl,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: InputDecoration(
              hintText: 'Ghi chú...',
              hintStyle: TextStyle(color: AppColors.textTertiary(brightness)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.primary(brightness), width: 2),
              ),
              filled: true,
              fillColor: AppColors.background(brightness),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  BoxDecoration _cardDecoration(brightness) {
    final brightness = Theme.of(context).brightness;

    return BoxDecoration(
      color: AppColors.surface(brightness),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      border: Border.all(color: AppColors.border(brightness)),
      boxShadow: AppShadows.soft(brightness),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final brightness = Theme.of(context).brightness;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary(brightness)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.border(brightness)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.border(brightness)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: AppColors.primary(brightness), width: 2),
      ),
      filled: true,
      fillColor: AppColors.background(brightness),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}';
}

class _SaveButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const _SaveButton({required this.onPressed});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
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
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.primary(brightness).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            'Lưu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary(brightness),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: AppColors.textPrimary(brightness),
      ),
    );
  }
}
