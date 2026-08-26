import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
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
    final isEdit = widget.equipmentId != null;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Text(
          isEdit ? 'Chỉnh sửa dụng cụ' : 'Thêm dụng cụ',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightTextPrimary),
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
    return Container(
      decoration: _cardDecoration(),
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
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.lightBackground,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.lightTextSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  side: BorderSide(
                    color: selected ? AppColors.accent : AppColors.lightBorder,
                  ),
                ),
                onSelected: (_) => setState(() => _category = c),
              );
            }).toList(),
          ),
          if (_category == 'cue') ...[
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Cue Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.lightTextPrimary,
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
                  backgroundColor: AppColors.lightBackground,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.lightTextSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    side: BorderSide(
                      color: selected ? AppColors.warning : AppColors.lightBorder,
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
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Identity'),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Tên dụng cụ *'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _brand,
            value: _brand,
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
    return Container(
      decoration: _cardDecoration(),
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
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            title: const Text(
              'Last tip change',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            subtitle: Text(
              _lastTipChange == null
                  ? 'Not set'
                  : _formatDate(_lastTipChange!),
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentSubtleLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.calendar_today, color: AppColors.accent, size: 18),
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

          const Divider(color: AppColors.lightBorder),
          const SizedBox(height: AppSpacing.md),

          // Butt
          TextFormField(
            controller: _weightCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Weight (oz)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _balance,
            value: _balance,
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Ferrule'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _extensionCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Extension'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _caseCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Cue case'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _chalkCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Chalk brand'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _gloveCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Glove'),
          ),

          const Divider(color: AppColors.lightBorder),
          const SizedBox(height: AppSpacing.md),

          // Roles
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Active playing cue',
              style: TextStyle(color: AppColors.lightTextPrimary),
            ),
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeColor: AppColors.accent,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Active break cue',
              style: TextStyle(color: AppColors.lightTextPrimary),
            ),
            value: _isBreakCue,
            onChanged: (v) => setState(() => _isBreakCue = v),
            activeColor: AppColors.warning,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Active jump cue',
              style: TextStyle(color: AppColors.lightTextPrimary),
            ),
            value: _isJumpCue,
            onChanged: (v) => setState(() => _isJumpCue = v),
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section: Pricing
  // ===========================================================================

  Widget _buildPriceSection() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Purchase & Condition'),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Purchase date',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            subtitle: Text(
              _purchaseDate == null
                  ? 'Not set'
                  : _formatDate(_purchaseDate!),
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentSubtleLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.calendar_today, color: AppColors.accent, size: 18),
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
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Purchase price (USD)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _valueCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Current value (USD)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _condition,
            value: _condition,
            dropdownColor: AppColors.lightSurface,
            style: const TextStyle(color: AppColors.lightTextPrimary),
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
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: _inputDecoration('Usage hours'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Archive',
              style: TextStyle(color: AppColors.lightTextPrimary),
            ),
            subtitle: const Text(
              'Hide from main list',
              style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
            ),
            value: _isArchived,
            onChanged: (v) => setState(() => _isArchived = v),
            activeColor: AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section: Notes
  // ===========================================================================

  Widget _buildNotesSection() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Notes'),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesCtrl,
            style: const TextStyle(color: AppColors.lightTextPrimary),
            decoration: InputDecoration(
              hintText: 'Ghi chú...',
              hintStyle: const TextStyle(color: AppColors.lightTextTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
              filled: true,
              fillColor: AppColors.lightBackground,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      border: Border.all(color: AppColors.lightBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      filled: true,
      fillColor: AppColors.lightBackground,
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
    return GestureDetector(
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
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: const Text(
            'Lưu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: AppColors.lightTextPrimary,
      ),
    );
  }
}
