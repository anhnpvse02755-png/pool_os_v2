// ============================================================================
// equipment_list_flow_test.dart
// ----------------------------------------------------------------------------
// Sprint 2A AC-2 widget smoke. Three assertions per Constitution Article 8:
// the screen is reachable, the list renders, search input is reachable.
// No navigation simulation, no detail flow, no back button. Manual QA on
// a real device covers the rest.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/core/providers/repository_providers.dart'
    as repo_providers;
import 'package:pool_os_v2/data/models/equipment.dart';
import 'package:pool_os_v2/presentation/screens/profile/equipment_screen.dart';

import '../helpers/fake_equipment_repository.dart';

Equipment _seed() => Equipment(
      id: 'seed_1',
      name: 'Test Cue',
      category: 'cue',
      cueType: 'playing',
      isActive: true,
      isArchived: false,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

void main() {
  testWidgets('Equipment screen opens, list renders, search field present',
      (tester) async {
    final fake = FakeEquipmentRepository(seeded: [_seed()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repo_providers.equipmentRepositoryProvider.overrideWithValue(fake),
        ],
        child: const MaterialApp(home: EquipmentScreen()),
      ),
    );

    // Allow async provider to resolve. Avoid pumpAndSettle (flutter_animate).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Assertion 1: screen is reachable.
    expect(find.byType(EquipmentScreen), findsOneWidget);

    // Assertion 2: list renders with at least one seeded item visible.
    expect(find.text('Test Cue'), findsOneWidget);

    // Assertion 3: search field is present and accepts input.
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Predator');
    expect(find.text('Predator'), findsOneWidget);
  });
}
