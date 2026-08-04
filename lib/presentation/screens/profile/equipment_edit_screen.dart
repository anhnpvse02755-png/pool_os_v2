import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Edit / Add Screen.
///
/// Restored V1 multi-section form covering every cue/shaft/tip/accessory
/// field, plus V2 extensions for pricing, condition, usage hours.
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
        const SnackBar(content: Text('Vui lòng nhập tên.')),
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
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa dụng cụ' : 'Thêm dụng cụ'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Lưu',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCategorySection(),
            _buildIdentitySection(),
            if (_category == 'cue') _buildCueSection(),
            _buildPriceSection(),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EquipmentConstants.equipmentCategories.map((c) {
                final selected = c == _category;
                return ChoiceChip(
                  label: Text(EquipmentConstants.categoryLabels[c]!),
                  selected: selected,
                  selectedColor: AppTheme.primaryGreen,
                  onSelected: (_) => setState(() => _category = c),
                );
              }).toList(),
            ),
            if (_category == 'cue') ...[
              const SizedBox(height: 16),
              const Text('Cue Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EquipmentConstants.cueTypes.map((t) {
                  final selected = t == _cueType;
                  return ChoiceChip(
                    label: Text(EquipmentConstants.cueTypeLabels[t]!),
                    selected: selected,
                    selectedColor: Colors.orange,
                    onSelected: (_) => setState(() => _cueType = t),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section: Identity
  // ===========================================================================

  Widget _buildIdentitySection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Identity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên dụng cụ *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _brand,
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.cueBrands.map((b) =>
                    DropdownMenuItem(value: b, child: Text(b))),
              ],
              onChanged: (v) => setState(() => _brand = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelCtrl,
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section: Cue specs
  // ===========================================================================

  Widget _buildCueSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Specifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),

            // Shaft
            DropdownButtonFormField<String>(
              initialValue: _shaftMaterial,
              decoration: const InputDecoration(
                labelText: 'Shaft material',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.shaftMaterials.map((m) =>
                    DropdownMenuItem(value: m, child: Text(m))),
              ],
              onChanged: (v) => setState(() => _shaftMaterial = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<double>(
              initialValue: _shaftDiameterCtrl.text.isEmpty
                  ? null
                  : double.tryParse(_shaftDiameterCtrl.text),
              decoration: const InputDecoration(
                labelText: 'Shaft diameter (mm)',
                border: OutlineInputBorder(),
              ),
              items: EquipmentConstants.shaftDiameters
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text('${d.toStringAsFixed(2)} mm'),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _shaftDiameterCtrl.text = v?.toString() ?? ''),
            ),
            const SizedBox(height: 12),

            // Tip
            DropdownButtonFormField<String>(
              initialValue: _tipBrand,
              decoration: const InputDecoration(
                labelText: 'Tip brand',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.tipBrands.map((b) =>
                    DropdownMenuItem(value: b, child: Text(b))),
              ],
              onChanged: (v) => setState(() => _tipBrand = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<double>(
              initialValue: _tipDiameterCtrl.text.isEmpty
                  ? null
                  : double.tryParse(_tipDiameterCtrl.text),
              decoration: const InputDecoration(
                labelText: 'Tip diameter (mm)',
                border: OutlineInputBorder(),
              ),
              items: EquipmentConstants.tipDiameters
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text('${d.toStringAsFixed(2)} mm'),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _tipDiameterCtrl.text = v?.toString() ?? ''),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tipHardness,
              decoration: const InputDecoration(
                labelText: 'Tip hardness',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.tipHardnesses.map((h) =>
                    DropdownMenuItem(value: h, child: Text(h))),
              ],
              onChanged: (v) => setState(() => _tipHardness = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Last tip change'),
              subtitle: Text(_lastTipChange == null
                  ? 'Not set'
                  : _formatDate(_lastTipChange!)),
              trailing: const Icon(Icons.calendar_today),
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

            const Divider(),
            const SizedBox(height: 12),

            // Butt
            TextFormField(
              controller: _weightCtrl,
              decoration: const InputDecoration(
                labelText: 'Weight (oz)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _balance,
              decoration: const InputDecoration(
                labelText: 'Balance',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.balances.map((b) =>
                    DropdownMenuItem(value: b, child: Text(b))),
              ],
              onChanged: (v) => setState(() => _balance = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _joint,
              decoration: const InputDecoration(
                labelText: 'Joint',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.joints.map((j) =>
                    DropdownMenuItem(value: j, child: Text(j))),
              ],
              onChanged: (v) => setState(() => _joint = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _wrap,
              decoration: const InputDecoration(
                labelText: 'Wrap',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.wraps.map((w) =>
                    DropdownMenuItem(value: w, child: Text(w))),
              ],
              onChanged: (v) => setState(() => _wrap = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ferruleCtrl,
              decoration: const InputDecoration(
                labelText: 'Ferrule',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _extensionCtrl,
              decoration: const InputDecoration(
                labelText: 'Extension',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caseCtrl,
              decoration: const InputDecoration(
                labelText: 'Cue case',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _chalkCtrl,
              decoration: const InputDecoration(
                labelText: 'Chalk brand',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gloveCtrl,
              decoration: const InputDecoration(
                labelText: 'Glove',
                border: OutlineInputBorder(),
              ),
            ),

            const Divider(),
            const SizedBox(height: 12),

            // Roles
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active playing cue'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              activeThumbColor: AppTheme.primaryGreen,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active break cue'),
              value: _isBreakCue,
              onChanged: (v) => setState(() => _isBreakCue = v),
              activeThumbColor: Colors.orange,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active jump cue'),
              value: _isJumpCue,
              onChanged: (v) => setState(() => _isJumpCue = v),
              activeThumbColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section: Pricing
  // ===========================================================================

  Widget _buildPriceSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Purchase & Condition',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Purchase date'),
              subtitle: Text(_purchaseDate == null
                  ? 'Not set'
                  : _formatDate(_purchaseDate!)),
              trailing: const Icon(Icons.calendar_today),
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
              decoration: const InputDecoration(
                labelText: 'Purchase price (USD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueCtrl,
              decoration: const InputDecoration(
                labelText: 'Current value (USD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                ...EquipmentConstants.conditions.map((c) =>
                    DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usageCtrl,
              decoration: const InputDecoration(
                labelText: 'Usage hours',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Archive'),
              subtitle: const Text('Hide from main list'),
              value: _isArchived,
              onChanged: (v) => setState(() => _isArchived = v),
              activeThumbColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section: Notes
  // ===========================================================================

  Widget _buildNotesSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                hintText: 'Ghi chú...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}';
}
