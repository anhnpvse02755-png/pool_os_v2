import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
import 'package:pool_os_v2/presentation/screens/profile/equipment_edit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Màn sửa thiết bị dựng được và không ném assertion nào.
///
/// Màn này từng ném assertion của chính Flutter mỗi lần dựng: sáu `ListTile` /
/// `SwitchListTile` nằm thẳng trong `Container` có màu nền, nên nền và hiệu
/// ứng chạm của chúng bị che. Lỗi chỉ hiện ở chế độ debug và không làm app
/// chết, nên nó sống sót — không test nào dựng màn này.
///
/// Không khẳng định nội dung dropdown: màn nạp bất đồng bộ rồi dựng lười theo
/// mục, nên muốn tới được dropdown phải cuộn qua nhiều mục và test sẽ đo cấu
/// trúc cuộn nhiều hơn đo hành vi.
void main() {
  testWidgets('dựng được, không ném assertion nào', (tester) async {
    SharedPreferences.setMockInitialValues({});
    // Kho cục bộ giữ SharedPreferences trong một biến tĩnh; không gọi `init()`
    // thì repository ném "not initialized" ngay trong `initState`.
    await LocalStorageDataSource.init();

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: EquipmentEditScreen(equipmentId: 'cue_main'),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('Shaft'), findsOneWidget);
  });

  testWidgets('màn tạo mới cũng dựng được', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSource.init();

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: EquipmentEditScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
