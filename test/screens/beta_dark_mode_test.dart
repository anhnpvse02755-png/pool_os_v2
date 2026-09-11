import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

// ============================================================================
// Man trong lib/beta/ — LO HONG cua tam lo redesign.
//
// Tam lo chi quet `lib/presentation/screens/` (68 man) va hygiene cung chi phu
// dung 68 man do. Hai man beta nay nam ngoai, nen chung khong doc `brightness`
// lan nao va van dung `AppTheme.primaryGreen` — alias tro toi `AppColors.accent`
// tuc XANH DIEN #3B82F6, du ten la "green".
//
// Ket qua: bat ThemeMode.system xong, man Black Box ve thanh tieu de xanh dien
// va the TRANG giua nen toi. Khong bai test nao bat duoc; chi lo ra khi dung
// app that va nhin (tests/90-dark-mode-visual.spec.ts).
// ============================================================================
void main() {
  expectTokenHygiene('beta — black box', const [
    'lib/beta/presentation/screens/black_box_export_screen.dart',
    'lib/beta/presentation/screens/black_box_settings_tile.dart',
  ]);
}
