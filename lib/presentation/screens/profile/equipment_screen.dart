import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

/// Equipment Model
class Equipment {
  final String id;
  final String name;
  final String type; // cue, shaft, tip, accessory
  final String? brand;
  final String? imageUrl;
  final DateTime? purchaseDate;
  final String? notes;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    this.brand,
    this.imageUrl,
    this.purchaseDate,
    this.notes,
  });
}

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo data
    final equipment = [
      Equipment(
        id: '1',
        name: 'My Main Cue',
        type: 'cue',
        brand: 'Predator',
        purchaseDate: DateTime(2024, 1, 15),
        notes: 'Cue chính dùng để thi đấu',
      ),
      Equipment(
        id: '2',
        name: 'Jump Cue',
        type: 'cue',
        brand: 'Predator',
        purchaseDate: DateTime(2024, 3, 20),
      ),
      Equipment(
        id: '3',
        name: 'Kamui Clear',
        type: 'tip',
        brand: 'Kamui',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dụng cụ của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEquipmentDialog(context),
          ),
        ],
      ),
      body: equipment.isEmpty
          ? _buildEmptyState(context)
          : _buildEquipmentList(context, equipment),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEquipmentDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm dụng cụ'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có dụng cụ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm dụng cụ billiards của bạn để theo dõi',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentList(BuildContext context, List<Equipment> equipment) {
    // Group by type
    final grouped = <String, List<Equipment>>{};
    for (final item in equipment) {
      grouped.putIfAbsent(item.type, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(entry.key),
                      size: 18,
                      color: _getTypeColor(entry.key),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTypeName(entry.key),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${entry.value.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.asMap().entries.map((e) {
                final index = e.key;
                final item = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EquipmentCard(
                    equipment: item,
                    onTap: () => _showEquipmentDetail(context, item),
                  ).animate().fadeIn(delay: (index * 100).ms),
                );
              }),
              const SizedBox(height: 8),
            ],
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'cue':
        return Icons.straighten;
      case 'shaft':
        return Icons.linear_scale;
      case 'tip':
        return Icons.circle_outlined;
      case 'accessory':
        return Icons.handyman_outlined;
      default:
        return Icons.inventory_2;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'cue':
        return 'Cue';
      case 'shaft':
        return 'Shaft';
      case 'tip':
        return 'Tip';
      case 'accessory':
        return 'Phụ kiện';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'cue':
        return AppTheme.primaryGreen;
      case 'shaft':
        return Colors.blue;
      case 'tip':
        return Colors.orange;
      case 'accessory':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAddEquipmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddEquipmentSheet(),
    );
  }

  void _showEquipmentDetail(BuildContext context, Equipment equipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EquipmentDetailSheet(equipment: equipment),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onTap;

  const _EquipmentCard({
    required this.equipment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.straighten,
                color: AppTheme.primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (equipment.brand != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      equipment.brand!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (equipment.purchaseDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mua ${_formatDate(equipment.purchaseDate!)}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddEquipmentSheet extends StatefulWidget {
  const _AddEquipmentSheet();

  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
  String _selectedType = 'cue';
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Thêm dụng cụ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Type selector
          const Text('Loại dụng cụ', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _TypeChip(label: 'Cue', value: 'cue', selected: _selectedType == 'cue', onTap: () => setState(() => _selectedType = 'cue')),
              _TypeChip(label: 'Shaft', value: 'shaft', selected: _selectedType == 'shaft', onTap: () => setState(() => _selectedType = 'shaft')),
              _TypeChip(label: 'Tip', value: 'tip', selected: _selectedType == 'tip', onTap: () => setState(() => _selectedType = 'tip')),
              _TypeChip(label: 'Phụ kiện', value: 'accessory', selected: _selectedType == 'accessory', onTap: () => setState(() => _selectedType = 'accessory')),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên dụng cụ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _brandController,
            decoration: InputDecoration(
              labelText: 'Thương hiệu',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã thêm dụng cụ!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EquipmentDetailSheet extends StatelessWidget {
  final Equipment equipment;

  const _EquipmentDetailSheet({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.straighten,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    if (equipment.brand != null)
                      Text(
                        equipment.brand!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (equipment.purchaseDate != null)
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Ngày mua',
              value: '${equipment.purchaseDate!.day}/${equipment.purchaseDate!.month}/${equipment.purchaseDate!.year}',
            ),

          if (equipment.notes != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.note,
              label: 'Ghi chú',
              value: equipment.notes!,
            ),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa dụng cụ'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            Text(value),
          ],
        ),
      ],
    );
  }
}
