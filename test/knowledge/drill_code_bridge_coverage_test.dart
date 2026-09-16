import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/utils/drills_library.dart';
import 'package:pool_os_v2/knowledge/drill_code_bridge.dart';
import 'package:pool_os_v2/knowledge/knowledge_graph_service.dart';

/// Buổi tập hôm nay đề xuất bài lấy từ knowledge graph (mã `STUN_SHOT`,
/// `BANK_SHOT`…), nhưng màn tập đọc bài từ `DrillLibrary` (mã `BT01`–`BT26`).
/// Cầu nối giữa hai hệ là `drill_code_bridge`.
///
/// Trước khi có test này, cầu nối chỉ phủ 2/13 bài — 11 bài còn lại đưa người
/// dùng tới màn lỗi "Bài tập với mã ... không tồn tại". Lỗi chỉ lộ ra khi bấm
/// đúng bài không map được, nên nó sống sót qua cả vòng kiểm thủ công.
void main() {
  group('drill_code_bridge phủ hết knowledge graph', () {
    test('MỌI DrillNode đều mở được một bài tập có thật', () {
      final kg = KnowledgeGraphService.instance;
      final unmapped = <String>[];
      final danglingTarget = <String>[];

      for (final node in kg.getAllDrills()) {
        final resolved = resolveDrillCode(node.code);
        if (resolved == null) {
          unmapped.add(node.code);
        } else if (DrillLibrary.getDrill(resolved) == null) {
          // Map ra mã không tồn tại còn tệ hơn không map: UI tưởng đi được.
          danglingTarget.add('${node.code} -> $resolved');
        }
      }

      expect(unmapped, isEmpty,
          reason: 'Các bài này không map được sang DrillLibrary, bấm vào sẽ '
              'ra màn lỗi: ${unmapped.join(", ")}');
      expect(danglingTarget, isEmpty,
          reason: 'Map trỏ tới mã không có trong DrillLibrary: '
              '${danglingTarget.join(", ")}');
    });

    test('bảng map giữ đúng các cặp đã chốt', () {
      const expected = {
        'STUN_SHOT': 'BT07', // bi cái dừng — Stop/Follow/Draw
        'THIN_CUT': 'BT05', // cắt mỏng <30° — ngắm bi sát băng & góc lệch
        'THICK_CUT': 'BT03', // cắt dày >45° — ngắm bi ảo theo góc tăng dần
        'BANK_SHOT': 'BT16',
        'KICK_SHOT': 'BT15',
        'SAFETY_PLAY': 'BT12',
        'BREAK_SHOT': 'BT06',
        'POSITION_CONTROL': 'BT11',
        'RUN_OUT': 'BT13',
        'SPEED_CONTROL': 'BT19',
        'ESCAPING': 'BT15', // thoát kẹt đi bằng kick shot
      };

      expected.forEach((from, to) {
        expect(resolveDrillCode(from), to, reason: '$from phải mở $to');
      });
    });

    test('mã V2 có thật thì đi thẳng, mã lạ thì trả null', () {
      expect(resolveDrillCode('BT26'), 'BT26');
      expect(resolveDrillCode('KHONG_TON_TAI'), isNull);
    });

    test('hậu tố _LV vẫn được gỡ', () {
      expect(resolveDrillCode('STOP_LV2'), 'BT07');
      expect(resolveDrillCode('BANK_SHOT_LV3'), 'BT16');
    });
  });
}
