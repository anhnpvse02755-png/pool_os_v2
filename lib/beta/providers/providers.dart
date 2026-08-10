// ============================================================================
// Black Box Providers — Riverpod Provider
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../beta.dart';

/// Global Black Box Provider
final blackBoxProvider = ChangeNotifierProvider<BlackBoxProvider>((ref) {
  return BlackBoxProvider();
});
