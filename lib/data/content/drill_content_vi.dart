/// Nội dung tiếng Việt cho toàn bộ drills.
///
/// Nguồn tham khảo chính:
/// - Dr. Dave Alciatore — "The Illustrated Principles of Pool and Billiards" (2017)
/// - BCA (Billiard Congress of America) — chuẩn kỹ thuật quốc tế
/// - APA (American Poolplayers Association) — mẹo thi đấu thực tế
///
/// Nguyên tắc dịch:
/// - Giữ thuật ngữ quốc tế khi phổ biến (stance, bridge, follow through, draw, follow)
/// - Giải thích tiếng Việt dễ hiểu cho người mới
/// - Dùng từ ngữ quen thuộc trong cộng đồng billiards Việt Nam
library;

import '../models/drill_content.dart';

/// Mapping từ drill code → Vietnamese DrillContent.
///
/// Drills được nhóm theo category aiming (đầu tiên, là nền tảng).
final Map<String, DrillContent> drillContentVi = {
  // ==========================================================================
  // AIMING — Ngắm bắn
  // ==========================================================================

  'STRAIGHT_NEAR': DrillContent(
    drillCode: 'STRAIGHT_NEAR',
    equipment: [
      'Cơ billiards tiêu chuẩn (58-59 inch)',
      'Phấn (chalk) chất lượng tốt',
      'Bi trắng (cue ball) + 1 bi mục tiêu',
      'Lỗ góc gần nhất (khoảng cách 20cm)',
    ],
    stance:
        'Đứng thẳng lưng, hai chân rộng bằng vai. Chân trước (chân trái với người thuận tay phải) '
        'chỉ thẳng về phía bi mục tiêu, cách bi trắng khoảng 50-60cm. Trọng lượng cơ thể dồn đều '
        'hai chân, hơi nghiêng về phía trước. Đầu gối chân trước hơi cong tự nhiên.',
    bridge:
        'Dùng cầu tay mở (open bridge) — tay trước đặt trên bàn, các ngón tay xếp thành hình chữ V, '
        'cơ nằm trong rãnh V. Cầu tay dài khoảng 15-20cm tính từ bi trắng. Tay cầu cơ thẳng và '
        'ổn định. Ngón cái của tay sau chạm nhẹ vào cơ.',
    stroke:
        'Tay sau kéo cơ thẳng 3-4 lần (pendulum) trước khi đánh. Khi đánh, kéo cơ ra sau 10-15cm, '
        'rồi đẩy tới với tốc độ đều. Follow through (vung cơ hết) dài gấp 3-4 lần đoạn kéo về. '
        'Giữ tay cố định, chỉ khuỷu tay di chuyển như con lắc.',
    aiming:
        'Nhìn thẳng từ bi trắng đi qua tâm bi mục tiêu đến điểm chuẩn trên viền lỗ. '
        'Gọi đây là đường ngắm (aim line). Giữ mắt trên đường ngắm càng lâu càng tốt '
        'trước khi ra cơ. Luyện tập bằng cách nhìn 3-5 giây rồi mới đánh.',
    keyPoints: [
      'Mắt phải (đối với người thuận phải) nằm trên đường ngắm',
      'Cơ đi qua tâm bi trắng và điểm chuẩn',
      'Follow through dài = cơ đi thẳng',
      'Giữ cằm chạm cơ khi đánh',
    ],
    commonMistakes: [
      'Nâng đầu cơ lên quá sớm — khiến cơ chệch hướng',
      'Đánh quá mạnh hoặc quá nhẹ so với khoảng cách',
      'Cầu tay bị xê dịch khi ra cơ — làm cơ lệch',
      'Không giữ mắt trên bi mục tiêu khi đánh',
      'Hít thở không đều — gây rung tay',
    ],
    proTips: [
      'Trước khi tập, đặt cơ lên đường ngắm 3-5 lần không đánh — gọi là "ghost stroke"',
      'Nếu trượt hết lỗ bên phải, đánh chếch sang phải 1 chút — đây là lỗi ngắm quá dày',
      'Nếu dừng bi trước lỗ, tăng tốc độ cơ hoặc đánh vào tâm bi',
    ],
  ),

  'STRAIGHT_MID': DrillContent(
    drillCode: 'STRAIGHT_MID',
    equipment: [
      'Cơ billiards tiêu chuẩn',
      'Phấn',
      'Bi trắng + bi mục tiêu',
      'Lỗ cách bi trắng khoảng 50-70cm',
    ],
    stance:
        'Giống STRAIGHT_NEAR nhưng đứng xa bi hơn (60-80cm). Thân người vẫn thẳng và vuông góc '
        'với đường đánh. Chân sau có thể hơi nhón nhẹ để tăng độ ổn định khi đánh xa.',
    bridge:
        'Cầu tay mở dài 20-25cm. Ngón trỏ và ngón giữa tạo chữ V sâu hơn để giữ cơ chắc hơn. '
        'Tay cầu cơ (tay sau) nắm chắc nhưng không siết — cổ tay thả lỏng.',
    stroke:
        'Kéo cơ ra sau 15-20cm (tăng theo khoảng cách). Đẩy tới với tốc độ vừa phải, không quá mạnh. '
        'Follow through dài gấp 3-5 lần kéo về. Giữ cơ thẳng cả đoạn đi.',
    aiming:
        'Tương tự STRAIGHT_NEAR — nhìn qua tâm bi mục tiêu ra điểm chuẩn trên viền lỗ. '
        'Với khoảng cách xa hơn, sai số 1mm ở điểm ngắm sẽ làm bi lệch nhiều hơn.',
    keyPoints: [
      'Khoảng cách xa = kéo cơ dài hơn',
      'Tốc độ cơ ổn định, không giật',
      'Đảm bảo cơ đi thẳng từ đầu đến cuối',
    ],
    commonMistakes: [
      'Đánh quá mạnh vì sợ không tới — thực tế chỉ cần đánh vào tâm bi đúng lực',
      'Thay đổi điểm ngắm giữa chừng (do thiếu tự tin)',
      'Cơ bị lệch sang trái/phải do grip không ổn định',
    ],
    proTips: [
      'Đếm nhịp kéo-ra-đẩy-vào: "1-2-3-đẩy-1-2-3-follow"',
      'Nếu trượt đều cùng một hướng, hiệu chỉnh điểm ngắm ngược lại 1mm',
    ],
  ),

  'STRAIGHT_FAR': DrillContent(
    drillCode: 'STRAIGHT_FAR',
    equipment: [
      'Cơ billiards tiêu chuẩn',
      'Phấn',
      'Bi trắng + bi mục tiêu',
      'Lỗ cách bi trắng từ 1m trở lên',
    ],
    stance:
        'Đứng xa bi từ 1-1.2m. Thân người nghiêng về phía trước nhiều hơn để giữ cân bằng. '
        'Chân sau có thể đặt xa hơn vai để chống đỡ khi đánh mạnh.',
    bridge:
        'Cầu tay mở dài 25-30cm, ngón tay khóa chặt với bàn để chịu lực. '
        'Có thể dùng mechanical bridge (cầu tay cơ học) nếu bi trắng quá xa tầm tay.',
    stroke:
        'Kéo cơ ra sau 20-25cm. Đẩy tới với tốc độ cao nhưng vẫn mượt. '
        'Follow through rất dài (4-5 lần đoạn kéo về) để đảm bảo lực ổn định.',
    aiming:
        'Đường ngắm quan trọng gấp đôi khoảng cách xa. Một sai số 1mm sẽ làm bi lệch 5-10mm ở lỗ. '
        'Tập trung cao độ. Nhìn điểm chuẩn thật kỹ trước khi đánh.',
    keyPoints: [
      'Sai số điểm ngắm = sai số bị nhân đôi ở khoảng cách xa',
      'Follow through cực dài để giữ đường cơ thẳng',
      'Tốc độ cơ phải đều — không có chỗ cho sai sót',
    ],
    commonMistakes: [
      'Đánh không đủ lực — bi dừng giữa đường',
      'Điểm ngắm lệch 2-3mm vì khoảng cách xa khó đánh giá',
      'Run trước khi đánh — mất focus',
    ],
    proTips: [
      'Chơi trên bàn 9 feet chuẩn sẽ tập khoảng cách tốt hơn bàn 7 feet',
      'Hít thở sâu 1 lần trước khi đánh để giữ tay ổn định',
    ],
  ),

  'THIN_CUT_30': DrillContent(
    drillCode: 'THIN_CUT_30',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu đặt ở góc 30 độ so với lỗ',
    ],
    stance:
        'Đứng thẳng với đường đánh tạo góc 30 độ. Thân người xoay nhẹ để phù hợp với hướng '
        'đánh. Chân trước đặt trên đường đánh qua tâm bi trắng và bi mục tiêu.',
    bridge:
        'Cầu tay mở tiêu chuẩn 20cm. Tay cầu cơ vững, không rung. Khi đánh cắt mỏng, cần '
        'đặt cơ chính xác vào điểm tiếp xúc rất mỏng trên bi trắng.',
    stroke:
        'Đánh nhẹ và chính xác. Không cần lực nhiều khi cắt mỏng vì bi sẽ cuộn nhiều sau khi '
        'chạm bi mục tiêu. Kéo cơ ra sau 10-15cm. Follow through vừa đủ.',
    aiming:
        'Hệ thống ngắm cắt mỏng: nhìn đường bi đi vào lỗ, đặt đường đi của bi mục tiêu từ tâm '
        'bi trở ra. Đánh vào phần mỏng của bi trắng phía gần lỗ (theo hướng đánh). '
        'Điểm tiếp xúc rất quan trọng — lệch 1mm = trượt lỗ.',
    keyPoints: [
      'Điểm tiếp xúc trên bi trắng là yếu tố quyết định',
      'Lực đánh không quan trọng bằng điểm tiếp xúc',
      'Cut shot (cắt) = hướng bi mục tiêu thay đổi so với hướng bi trắng đi',
    ],
    commonMistakes: [
      'Đánh vào bi trắng quá dày (full ball) khi cần cắt mỏng',
      'Đánh quá mạnh khiến bi nhảy khỏi lỗ',
      'Đứng không vuông góc với đường đánh — làm lệch hướng',
    ],
    proTips: [
      'Hệ thống "ghost ball": hình dung bi ảo ở vị trí bi trắng sẽ chạm vào để đẩy bi mục tiêu vào lỗ',
      'Tập đầu tiên với bóng bằng cách đặt bi mục tiêu dính vào viền lỗ, sau đó đánh từ từ xa ra',
    ],
  ),

  'THIN_CUT_45': DrillContent(
    drillCode: 'THIN_CUT_45',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu đặt ở góc 45 độ',
    ],
    stance:
        'Tương tự THIN_CUT_30 nhưng đứng xoay thân nhiều hơn (45 độ). Chân sau (chân phải với '
        'người thuận phải) có thể lui xa hơn để giữ cân bằng khi xoay người.',
    bridge:
        'Cầu tay mở. Đặc biệt chú ý vị trí tay trước — với góc 45 độ, tay có thể bị che bởi thân '
        'người. Điều chỉnh tay để luôn nhìn thấy đường ngắm rõ ràng.',
    stroke:
        'Đánh nhẹ và chính xác. Cắt 45 độ tạo hiệu ứng "kick" — bi mục tiêu đi gần như vuông góc '
        'với bi trắng. Kéo cơ ra sau 10-15cm, đẩy tới mượt.',
    aiming:
        'Hệ thống cắt 45 độ: đánh vào rìa bi trắng (½ ball). Bi mục tiêu sẽ đi theo góc 90 độ so '
        'với đường đánh ban đầu. Dùng ngón tay trỏ đặt trên bàn để xác định đường tâm bi.',
    keyPoints: [
      'Đánh ½ ball = bi mục tiêu đi vuông góc',
      'Cần lực vừa đủ để bi chạm thành lỗ đúng góc',
      'Không cần thiết phải chính xác cực kỳ — 1mm sai số vẫn có thể vào lỗ',
    ],
    commonMistakes: [
      'Đánh quá mạnh khiến bi nhảy khỏi lỗ',
      'Đánh không đủ mỏng — bi mục tiêu đi ngược hướng mong muốn',
      'Đứng quá xa — khó đánh giá góc',
    ],
    proTips: [
      'Nhớ quy tắc 90 độ: khi đánh ½ ball, bi mục tiêu luôn đi vuông góc',
      'Tập bằng cách đặt 2 bi cách nhau 1 bán kính, mục tiêu xác nhận góc 90 độ',
    ],
  ),

  'THICK_CUT_30': DrillContent(
    drillCode: 'THICK_CUT_30',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh qua tâm bi (full ball) hoặc gần full. Đường đánh thẳng với đường '
        'kết nối tâm 2 bi. Thân người vuông góc với đường này.',
    bridge:
        'Cầu tay mở tiêu chuẩn. Vì đánh dày nên cơ chạm vào phần lớn bi trắng, không cần '
        'chính xác cao ở điểm tiếp xúc — chỉ cần đúng hướng.',
    stroke:
        'Đánh vừa phải, tốc độ vừa. Bi sẽ đi theo hướng gần thẳng. Follow through vừa đủ.',
    aiming:
        'Ngắm qua tâm bi mục tiêu ra điểm chuẩn. Dễ hơn cắt mỏng vì sai số điểm ngắm ít ảnh hưởng. '
        'Bi mục tiêu đi theo đường nối tâm 2 bi.',
    keyPoints: [
      'Đánh dày = dễ kiểm soát hướng bi mục tiêu',
      'Không cần điểm tiếp xúc chính xác như cắt mỏng',
      'Lực vừa đủ để bi lăn đến lỗ',
    ],
    commonMistakes: [
      'Đánh quá mạnh — bi bật ra khỏi lỗ',
      'Đứng lệch khiến đường đánh không qua tâm 2 bi',
    ],
    proTips: [
      'Khi tập cắt dày trước, sẽ tự tin hơn cho cắt mỏng',
      'Dùng để tập trung vào kỹ thuật ra cơ thay vì ngắm',
    ],
  ),

  'THICK_CUT_45': DrillContent(
    drillCode: 'THICK_CUT_45',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng vuông góc với đường đánh. Thân người ổn định, hai chân rộng bằng vai.',
    bridge:
        'Cầu tay mở. Tay vững để giữ đường cơ chính xác vì lực đánh sẽ truyền trực tiếp qua bi mục tiêu.',
    stroke:
        'Đánh vừa phải. Với cắt dày 45 độ, bi mục tiêu vẫn giữ gần như hướng ban đầu nhưng lệch '
        'nhẹ. Follow through vừa đủ.',
    aiming:
        'Ngắm qua tâm bi mục tiêu ra điểm chuẩn. Sai số 1mm ở điểm ngắm khiến bi đi lệch 5-7mm ở lỗ. '
        'Tập trung cao.',
    keyPoints: [
      'Cắt dày 45 độ = đường đi của bi mục tiêu lệch ít so với đường đánh',
      'Lực vừa đủ là chìa khóa',
    ],
    commonMistakes: [
      'Đánh quá nhẹ — bi dừng giữa đường',
      'Đánh quá mạnh — bi nhảy khỏi lỗ',
    ],
    proTips: [
      'Chú ý viền lỗ — bi mục tiêu sẽ chạm viền lỗ trước khi vào',
    ],
  ),

  'HALF_BALL_LEFT': DrillContent(
    drillCode: 'HALF_BALL_LEFT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng hướng muốn bi trắng đi (đã xác định trước). Thân người vuông góc với '
        'đường đánh. Chân trước trên đường đánh.',
    bridge:
        'Cầu tay mở tiêu chuẩn. Tay giữ chắc để truyền lực chính xác.',
    stroke:
        'Đánh vừa phải, đều. Half ball sẽ tạo góc vuông 90 độ giữa hướng bi trắng và bi mục tiêu. '
        'Follow through vừa đủ.',
    aiming:
        'Quy tắc nửa bi: khi đánh vào nửa trái của bi trắng (relative với hướng đánh và tâm bi mục tiêu), '
        'bi mục tiêu sẽ đi vuông góc. Hình dung tâm bi mục tiêu ở "3 giờ" của bi trắng, đánh vào "9 giờ".',
    keyPoints: [
      'Hệ thống nửa bi rất quan trọng cho nhiều tình huống',
      'Đánh đúng nửa = bi mục tiêu đi đúng hướng dự đoán',
      'Lỗi 1/4 bi sẽ làm bi mục tiêu đi sai góc',
    ],
    commonMistakes: [
      'Nhầm nửa trái với nửa phải',
      'Không xác định rõ hướng bi mục tiêu trước khi đánh',
    ],
    proTips: [
      'Dùng ngón tay để đo nửa bi khi mới tập',
      'Tập với khoảng cách gần trước khi xa',
    ],
  ),

  'HALF_BALL_RIGHT': DrillContent(
    drillCode: 'HALF_BALL_RIGHT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Tương tự HALF_BALL_LEFT nhưng đứng sao cho bi mục tiêu ở bên phải đường đánh. '
        'Thân người vẫn vuông góc với đường đánh.',
    bridge:
        'Cầu tay mở. Cầu tay dài vừa đủ để không che khuất đường ngắm.',
    stroke:
        'Đánh vừa phải. Lực không quan trọng bằng điểm tiếp xúc trên bi trắng.',
    aiming:
        'Tương tự HALF_BALL_LEFT: bi mục tiêu ở "9 giờ" của bi trắng, đánh vào "3 giờ". '
        'Bi mục tiêu sẽ đi vuông góc.',
    keyPoints: [
      'Đánh đúng nửa phải = kết quả tương tự HALF_BALL_LEFT nhưng đối xứng',
      'Cần đứng đúng hướng để tránh nhầm lẫn',
    ],
    commonMistakes: [
      'Đánh vào bi trắng quá mỏng hoặc quá dày',
    ],
    proTips: [
      'Sau khi thành thạo cả trái và phải, bạn có thể áp dụng cho hầu hết các cú cut shot',
    ],
  ),

  'LONG_POT_1M': DrillContent(
    drillCode: 'LONG_POT_1M',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu đặt cách lỗ khoảng 1m',
    ],
    stance:
        'Đứng xa bi, thân người nghiêng về phía trước. Chân sau có thể lui xa hơn để chống đỡ. '
        'Giữ trọng lượng cơ thể cân bằng.',
    bridge:
        'Cầu tay mở dài 25-30cm. Ngón tay khóa chặt với bàn. Đảm bảo cơ nằm trong rãnh V '
        'chắc chắn, không bị xê dịch khi ra cơ mạnh.',
    stroke:
        'Kéo cơ ra sau 20-25cm. Đẩy tới với tốc độ cao. Follow through cực dài (5-6 lần đoạn kéo về) '
        'để đảm bảo đường cơ thẳng và lực ổn định đến cuối.',
    aiming:
        'Sai số 1mm ở điểm ngắm = sai số 2-3mm ở lỗ. Phải cực kỳ chính xác. Nhìn đường ngắm '
        'từ bi trắng qua bi mục tiêu đến viền lỗ rất kỹ trước khi đánh.',
    keyPoints: [
      'Khoảng cách xa = sai số được nhân lên',
      'Follow through dài = đường cơ thẳng',
      'Tốc độ cơ đều = lực đều',
    ],
    commonMistakes: [
      'Đánh không đủ mạnh — bi dừng giữa đường',
      'Run trước khi đánh — mất focus',
      'Cơ bị lệch hướng do grip không chặt',
    ],
    proTips: [
      'Chơi trên bàn 9 feet sẽ tập tốt hơn',
      'Hít thở đều trước và trong khi đánh',
    ],
  ),

  'LONG_POT_1_5M': DrillContent(
    drillCode: 'LONG_POT_1_5M',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu đặt cách lỗ khoảng 1.5m',
    ],
    stance:
        'Đứng rất xa bi, có thể dùng cầu tay cơ học nếu cần. Thân người nghiêng về phía trước. '
        'Chân rộng và ổn định.',
    bridge:
        'Cầu tay dài 30-35cm hoặc dùng mechanical bridge. Tay cố định tuyệt đối khi đánh mạnh.',
    stroke:
        'Kéo cơ ra sau 25-30cm. Đẩy tới với tốc độ cao nhất có thể kiểm soát. Follow through dài '
        'tối đa. Cần lực rất mạnh để bi đến lỗ.',
    aiming:
        'Cực kỳ chính xác. Sai số 1mm nghĩa là lệch 5mm ở lỗ — có thể trượt. Tập trung 100% vào '
        'điểm ngắm trước khi đánh. Cân nhắc dùng kính ngắm nếu cần.',
    keyPoints: [
      '1.5m = khoảng cách rất xa, cần tập luyện',
      'Đánh full ball (vào tâm bi) để lực tối đa',
      'Follow through cực kỳ quan trọng',
    ],
    commonMistakes: [
      'Đánh quá mạnh — mất kiểm soát',
      'Đánh không đủ mạnh — bi dừng giữa đường',
      'Không đứng yên khi đánh — cơ thể bị xô ngang',
    ],
    proTips: [
      'Tập 1m trước khi lên 1.5m',
      'Khi thi đấu thật, 1.5m chỉ nên đánh khi cần thiết',
    ],
  ),

  'COMBO_SHORT': DrillContent(
    drillCode: 'COMBO_SHORT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 2 bi mục tiêu (1 trung gian, 1 vào lỗ)',
    ],
    stance:
        'Đứng vuông góc với đường đi qua 2 bi trung gian và bi mục tiêu. Đường này rất quan trọng. '
        'Thân người thẳng.',
    bridge:
        'Cầu tay mở tiêu chuẩn. Cầu tay chắc chắn để đảm bảo đường cơ thẳng — combo shot rất nhạy '
        'với sai số.',
    stroke:
        'Đánh vừa phải nhưng chính xác. Combo shot cần lực đủ để bi thứ 1 truyền động năng tốt đến '
        'bi thứ 2 nhưng không quá mạnh để bi nhảy.',
    aiming:
        'Nhìn thẳng hàng 3 bi: bi trắng → bi trung gian → bi mục tiêu → lỗ. Đường đi phải thẳng. '
        'Điểm tiếp xúc trên bi trung gian rất quan trọng — sai 1mm sẽ làm bi mục tiêu đi lệch 5-10mm.',
    keyPoints: [
      'Combo shot = 2 bi chạm nhau',
      'Lực đánh phải đủ để bi 2 chuyển động nhưng không quá mạnh',
      'Thường dùng khi bi mục tiêu không ngắm trực tiếp được',
    ],
    commonMistakes: [
      'Đánh quá nhẹ — bi 2 không chuyển động đủ',
      'Đánh quá mạnh — bi nhảy khỏi lỗ hoặc xuyên qua nhau',
      'Sai vị trí bi trung gian (không thẳng hàng)',
    ],
    proTips: [
      'Trước khi đánh, kiểm tra đường thẳng bằng cách đặt ngón tay trỏ dọc theo 3 bi',
      'Trong game, combo thường dùng khi có cơ hội rõ ràng',
    ],
  ),

  'COMBO_LONG': DrillContent(
    drillCode: 'COMBO_LONG',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 3 bi (2 trung gian + 1 mục tiêu)',
    ],
    stance:
        'Tương tự COMBO_SHORT nhưng đứng xa hơn vì có 2 bi trung gian. Đường đánh qua 4 bi phải thẳng.',
    bridge:
        'Cầu tay mở dài 25cm để tăng độ chính xác. Tay cố định.',
    stroke:
        'Đánh mạnh vừa đủ để 2 bi trung gian truyền lực đến bi mục tiêu. Lực không được quá lớn.',
    aiming:
        'Kiểm tra đường thẳng qua 4 bi. Sai 1mm ở bi đầu = sai lệch lớn ở bi cuối. Dùng tay '
        'đặt dọc đường để xác nhận.',
    keyPoints: [
      'Combo dài rất khó và hiếm khi dùng trong game',
      'Chỉ nên thử khi rất tự tin hoặc không có lựa chọn nào khác',
    ],
    commonMistakes: [
      'Lực không phù hợp',
      'Sai đường thẳng',
    ],
    proTips: [
      'Trong game thật, combo 3 bi cực hiếm — chỉ thử nếu hoàn toàn tự tin',
    ],
  ),

  'OBTAINED_COLOR': DrillContent(
    drillCode: 'OBTAINED_COLOR',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 2-3 bi (1 mục tiêu vào lỗ + 1-2 bi cản)',
    ],
    stance:
        'Đứng sao cho nhìn được đường bi đi vào lỗ mà không bị bi cản che. Có thể cần xoay người '
        'nhiều để có góc nhìn tốt nhất.',
    bridge:
        'Cầu tay mở chắc chắn. Có thể cần dùng mechanical bridge nếu vị trí khó.',
    stroke:
        'Lực vừa phải. Cú này không cần lực lớn, nhưng cần chính xác cao về điểm tiếp xúc trên '
        'bi trắng để đường đi của bi mục tiêu là đường vòng qua bi cản.',
    aiming:
        'Hệ thống ngắm quan trọng nhất: bi mục tiêu sẽ đi theo đường vòng. Hình dung "ghost ball" '
        '(bi ảo) ở vị trí sẽ chạm vào bi mục tiêu để đẩy nó qua đường vòng vào lỗ. Sai số 1mm '
        'trên bi trắng có thể khiến bi chạm bi cản.',
    keyPoints: [
      'Obtained color = đường đi vòng qua bi cản',
      'Cần điểm tiếp xúc chính xác trên bi trắng',
      'Rủi ro cao, thưởng cao',
    ],
    commonMistakes: [
      'Đánh vào bi cản thay vì bi mục tiêu',
      'Sai hướng — bi không vào lỗ',
    ],
    proTips: [
      'Chỉ thử khi đã tính toán kỹ và quá tự tin',
      'Trong game thật, thường có lựa chọn an toàn hơn',
    ],
  ),

  'INSIDE_ENGLISH': DrillContent(
    drillCode: 'INSIDE_ENGLISH',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường muốn bi trắng đi. Inside english = xoáy về phía bi mục tiêu (xoắn vào trong).',
    bridge:
        'Cầu tay mở. Đánh xoáy bên trái = đánh vào phần trái của bi trắng (xa bi mục tiêu).',
    stroke:
        'Đánh vừa phải nhưng điểm tiếp xúc lệch khỏi tâm. Bi trắng sẽ xoay khi cuộn về.',
    aiming:
        'Inside english (xoáy trong) = bi trắng xoắn về phía tâm đường đi. Dùng khi cần bi trắng '
        'đi thẳng nhưng tự xoay để về vị trí tốt.',
    keyPoints: [
      'Inside english: xoáy về phía mục tiêu',
      'Bi trắng sẽ đi thẳng hơn nhưng xoay',
      'Dùng để position play',
    ],
    commonMistakes: [
      'Đánh xoáy quá mạnh — bi trắng đi lệch hướng',
      'Đánh xoáy nhầm hướng',
    ],
    proTips: [
      'Tập riêng cảm giác xoáy trước khi dùng trong game',
    ],
  ),

  // ==========================================================================
  // CUE BALL CONTROL — Kiểm soát bi trắng
  // ==========================================================================

  'STOP_BALL': DrillContent(
    drillCode: 'STOP_BALL',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh vào tâm bi mục tiêu (full ball). Đường bi trắng đi và đường bi mục '
        'tiêu đi phải là đường kéo dài của nhau.',
    bridge:
        'Cầu tay mở chắc chắn. Đánh stop ball = đánh vào chính tâm bi trắng (không xoáy).',
    stroke:
        'Đánh vừa phải, đều. Khi đánh stop ball, bi trắng đi thẳng tới rồi dừng ngay sau khi chạm '
        'bi mục tiêu. Không có xoáy nào.',
    aiming:
        'Ngắm full ball vào tâm bi mục tiêu. Follow through vừa đủ. Bi trắng sẽ mất hoàn toàn '
        'năng lượng vào bi mục tiêu và dừng lại.',
    keyPoints: [
      'Stop ball = không có xoáy',
      'Bi trắng dừng ngay sau khi chạm bi mục tiêu',
      'Dùng khi muốn bi trắng ở nguyên tại chỗ',
    ],
    commonMistakes: [
      'Vô tình đánh top spin hoặc draw — bi trắng không dừng',
      'Đánh quá mạnh — bi trắng vẫn đi xa sau khi chạm bi mục tiêu',
    ],
    proTips: [
      'Dùng cho các tình huống cần bi trắng ở nguyên chỗ sau khi đánh',
      'Tập nhiều lần để cảm nhận lực vừa đủ',
    ],
  ),

  'FOLLOW_SHOT': DrillContent(
    drillCode: 'FOLLOW_SHOT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh vào tâm bi mục tiêu hoặc hơi lệch. Đường bi trắng đi sau khi '
        'chạm bi mục tiêu sẽ tiếp tục tiến về phía trước.',
    bridge:
        'Cầu tay mở. Đánh follow = đánh vào phần trên của bi trắng (xa tay cầm cơ nhất, gần đầu cơ). '
        'Khoảng 1-2mm trên tâm bi.',
    stroke:
        'Đánh vừa phải nhưng có follow through DÀI để truyền xoáy. Cơ đi từ dưới lên trên — '
        'gọi là top spin (tiến xoáy).',
    aiming:
        'Ngắm vào tâm bi mục tiêu hoặc lệch nhẹ. Sau khi chạm bi mục tiêu, bi trắng sẽ tiếp tục '
        'cuộn về phía trước nhờ top spin. Có thể dùng để đẩy bi trắng về vị trí thuận lợi.',
    keyPoints: [
      'Follow shot = top spin (xoáy tiến)',
      'Bi trắng đi tiếp sau khi chạm bi mục tiêu',
      'Cần follow through DÀI',
    ],
    commonMistakes: [
      'Đánh quá nhẹ — top spin không đủ, bi trắng không đi tiếp',
      'Follow through ngắn — không truyền được xoáy',
      'Đánh quá cao trên bi — kết quả thành miscue (cơ trượt khỏi bi)',
    ],
    proTips: [
      'Tập cảm giác top spin bằng cách đánh bi trắng đi xa mà không xoáy ngược',
      'Trong game, dùng để position bi trắng cho cú tiếp theo',
    ],
  ),

  'DRAW_SHOT': DrillContent(
    drillCode: 'DRAW_SHOT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh. Draw shot = bi trắng quay lùi (backspin) sau khi chạm bi mục tiêu.',
    bridge:
        'Cầu tay mở. Đánh draw = đánh vào phần dưới của bi trắng (gần bàn, xa đầu cơ). Khoảng '
        '2-5mm dưới tâm bi, phụ thuộc vào khoảng cách.',
    stroke:
        'Đánh MẠNH và NHANH với follow through DÀI. Cần nhiều lực hơn follow shot vì ma sát '
        'ngược hướng. Tập trung đánh vào phần dưới bi nhưng không quá thấp kẻo miscues.',
    aiming:
        'Ngắm vào bi mục tiêu như bình thường. Bi trắng sẽ quay lùi sau khi chạm bi mục tiêu, '
        'đặc biệt nếu đánh full ball.',
    keyPoints: [
      'Draw shot = backspin (xoáy lùi)',
      'Cần lực lớn và follow through dài',
      'Bi trắng quay lùi sau khi chạm bi mục tiêu',
    ],
    commonMistakes: [
      'Đánh quá nhẹ — không có đủ backspin, bi chỉ dừng',
      'Đánh quá thấp trên bi — miscue (cơ trượt)',
      'Đánh không full ball — backspin mất tác dụng',
    ],
    proTips: [
      'Miscue = cơ trượt khỏi bi vì đánh quá lệch tâm. Tránh bằng cách phấn kỹ đầu cơ',
      'Tập với khoảng cách tăng dần từ gần đến xa',
    ],
  ),

  'STUN_SHOT': DrillContent(
    drillCode: 'STUN_SHOT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh vào tâm bi mục tiêu (full ball) nhưng với một góc. Bi trắng sẽ đi '
        'theo đường vuông góc ngay sau khi chạm bi mục tiêu.',
    bridge:
        'Cầu tay mở. Đánh stun = đánh vào tâm bi nhưng góc đánh không trực tiếp với bi mục tiêu.',
    stroke:
        'Đánh vừa phải, đều. Không cần lực mạnh. Stun shot yêu cầu bi trắng không có xoáy nào '
        'khi chạm bi mục tiêu.',
    aiming:
        'Ngắm vào tâm bi mục tiêu. Sau khi chạm, bi trắng sẽ đi vuông góc với đường nối tâm 2 bi '
        '(theo quy luật vật lý). Dùng để điều khiển vị trí bi trắng chính xác.',
    keyPoints: [
      'Stun shot = không có xoáy khi chạm bi mục tiêu',
      'Bi trắng đi vuông góc',
      'Dùng để position play chính xác',
    ],
    commonMistakes: [
      'Vô tình đánh top/draw — stun mất tác dụng',
      'Không tính trước đường đi của bi trắng',
    ],
    proTips: [
      'Dùng trong game để kiểm soát vị trí bi trắng chính xác',
    ],
  ),

  'POSITION_BASIC': DrillContent(
    drillCode: 'POSITION_BASIC',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 1 bi mục tiêu',
    ],
    stance:
        'Đứng thẳng hướng muốn bi trắng đi tới sau khi chạm bi mục tiêu. Đây là yếu tố cốt lõi — '
        'phải biết mình muốn bi trắng đi đâu trước khi đánh.',
    bridge:
        'Cầu tay mở. Điểm tiếp xúc trên bi trắng quyết định đường đi sau va chạm: tâm = stun/no spin, '
        'trên = follow, dưới = draw.',
    stroke:
        'Lực đánh quyết định khoảng cách bi trắng đi được. Lực nhẹ = position gần, lực mạnh = position xa. '
        'Theo tỉ lệ 30 độ với hướng bi mục tiêu đi để tính đường bi trắng đi.',
    aiming:
        'Tính trước: bi mục tiêu sẽ đi đâu, bi trắng sẽ đi đâu, mình muốn vị trí nào. Sau đó '
        'chọn điểm tiếp xúc và lực cho phù hợp.',
    keyPoints: [
      'Position play = kiểm soát vị trí bi trắng sau khi đánh',
      'Yếu tố: điểm tiếp xúc, lực đánh, góc đánh',
      'Luôn nghĩ trước cú tiếp theo',
    ],
    commonMistakes: [
      'Đánh xong không biết bi trắng sẽ đi đâu',
      'Dùng lực sai — bi trắng đi quá xa hoặc quá gần',
    ],
    proTips: [
      'Tập "1 bi 1 lỗ" trước — chỉ nghĩ về 1 cú đánh',
      'Khi thành thạo, bắt đầu nghĩ 2-3 cú trước',
    ],
  ),

  'POSITION_3BALL': DrillContent(
    drillCode: 'POSITION_3BALL',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 3 bi mục tiêu',
    ],
    stance:
        'Thay đổi stance theo từng cú đánh. Sau cú đầu, bi trắng sẽ ở vị trí mới — đứng sao cho '
        'thuận lợi cho cú tiếp theo.',
    bridge:
        'Cầu tay thay đổi theo từng cú. Đôi khi cần cầu tay cơ học nếu bi ở vị trí khó.',
    stroke:
        'Lực đánh thay đổi theo từng cú để bi trắng di chuyển về vị trí thuận lợi cho cú kế tiếp. '
        'Đây là chuỗi các cú position play liên hoàn.',
    aiming:
        'Phải nghĩ trước toàn bộ chuỗi 3 cú. Cú 1 → vị trí bi trắng → cú 2 → vị trí bi trắng → cú 3. '
        'Lập kế hoạch từ đầu.',
    keyPoints: [
      'Chuỗi 3 cú = 3 lần kiểm soát vị trí bi trắng',
      'Cần tư duy chiến thuật nhiều',
      'Nếu cú 1 sai → cú 2 và 3 khó thực hiện',
    ],
    commonMistakes: [
      'Chỉ nghĩ 1 cú trước, quên cú kế tiếp',
      'Đánh quá mạnh ở cú đầu',
    ],
    proTips: [
      'Tập với 3 bi ở các vị trí khác nhau',
      'Khi thi đấu, luôn nghĩ trước ít nhất 2 cú',
    ],
  ),

  // ==========================================================================
  // SAFETY & STRATEGY
  // ==========================================================================

  'SAFETY_BASIC': DrillContent(
    drillCode: 'SAFETY_BASIC',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 1 bi mục tiêu',
    ],
    stance:
        'Đứng thẳng hướng muốn bi trắng đi đến vị trí an toàn — không phải đến lỗ. Mục tiêu là '
        'để đối thủ không có cú đánh dễ.',
    bridge:
        'Cầu tay mở chắc chắn. Đôi khi cầu tay cao (elevated bridge) để tránh bi cản.',
    stroke:
        'Lực vừa phải hoặc mạnh tùy vị trí an toàn. Mục tiêu: bi trắng ở vị trí khó, đối thủ không '
        'thể đánh thẳng.',
    aiming:
        'Hai chiến thuật chính: 1) Bi trắng chạy đến vị trí khó (vd: dính thành bàn, hoặc sau bi khác). '
        '2) Đẩy bi mục tiêu đến vị trí khó cho đối thủ.',
    keyPoints: [
      'Safety = đánh để đối thủ không dễ — KHÔNG phải để mình vào lỗ',
      'Chiến thuật quan trọng hơn đánh trúng',
      'Trong game 8-ball, safety là 40-50% thời gian',
    ],
    commonMistakes: [
      'Cố đánh trúng lỗ khi không nên',
      'Để bi trắng ở giữa bàn cho đối thủ',
    ],
    proTips: [
      'Đánh bi mục tiêu vào thành để nó quay trở lại khó đánh',
      'Đẩy bi trắng về phía đối thủ xa khỏi bi mục tiêu',
    ],
  ),

  'SAFETY_FORCE': DrillContent(
    drillCode: 'SAFETY_FORCE',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu + thành bàn',
    ],
    stance:
        'Đứng sao cho bi trắng sẽ chạm thành bàn (cushion) nhiều lần trước khi dừng. Đây là safety '
        'thường dùng.',
    bridge:
        'Cầu tay mở chắc chắn. Lực cao = cơ có thể bị rung, cần tay vững.',
    stroke:
        'Đánh mạnh. Bi trắng sẽ chạm thành 2-3 lần và quay trở lại vị trí bất ngờ cho đối thủ.',
    aiming:
        'Tính toán đường đi của bi trắng sau khi chạm thành. Mỗi lần chạm cushion, bi đổi hướng '
        'theo góc phản xạ. Cần luyện tập cảm giác này.',
    keyPoints: [
      'Force safety = bi trắng chạm thành nhiều lần',
      'Tính toán đường đi sau cushion',
      'Đối thủ thường bất ngờ vì nghĩ bi đi đường khác',
    ],
    commonMistakes: [
      'Không tính được đường đi sau cushion',
      'Đánh quá mạnh — bi trắng chạy về vị trí dễ',
    ],
    proTips: [
      'Tính toán góc cushion trước khi đánh',
      'Trong game, dùng khi cần thay đổi vị trí bi trắng nhiều',
    ],
  ),

  // ==========================================================================
  // BANK / KICK — Cú băng
  // ==========================================================================

  'BANK_SHOT': DrillContent(
    drillCode: 'BANK_SHOT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu + thành bàn',
    ],
    stance:
        'Đứng thẳng đường đánh sao cho bi mục tiêu sẽ chạm thành 1 lần rồi vào lỗ. Đây là cú khó — '
        'cần tính toán đường chéo ảo.',
    bridge:
        'Cầu tay mở vững. Đôi khi cần đánh cắt nhẹ để bi mục tiêu đi theo góc chính xác.',
    stroke:
        'Đánh vừa phải đến hơi mạnh. Lực quyết định khoảng cách bi sau khi chạm thành.',
    aiming:
        'Hệ thống "phantom ball" (bi ma): hình dung bi ảo ở vị trí sau khi chạm cushion nhưng '
        'chưa vào lỗ. Đánh vào bi ảo này như đánh trực tiếp. Hoặc dùng hệ thống đo góc từ '
        'bi mục tiêu đến cushion đến lỗ.',
    keyPoints: [
      'Bank shot = bi mục tiêu chạm 1 cushion trước khi vào lỗ',
      'Hệ thống phantom ball hoặc đo góc',
      'Khó — chỉ dùng khi không có lựa chọn trực tiếp',
    ],
    commonMistakes: [
      'Sai đường tính toán — bi không vào lỗ',
      'Đánh quá mạnh hoặc quá nhẹ',
    ],
    proTips: [
      'Tập với bi mục tiêu gần cushion trước',
      'Trong game chỉ dùng khi cần thiết, vì rủi ro cao',
    ],
  ),

  'KICK_SHOT': DrillContent(
    drillCode: 'KICK_SHOT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu + thành bàn (1 hoặc nhiều)',
    ],
    stance:
        'Đứng sao cho bi trắng sẽ chạm 1 hoặc nhiều cushion trước khi chạm bi mục tiêu. Đây là cú '
        'khó nhất trong billiards.',
    bridge:
        'Cầu tay mở vững, cơ chắc chắn. Đánh với lực chính xác.',
    stroke:
        'Lực vừa đến mạnh. Kick shot cần lực đủ để bi vượt qua khoảng cách và đến bi mục tiêu.',
    aiming:
        'Hệ thống đo góc: từ bi trắng, đo đường qua cushion đến bi mục tiêu. Thường dùng phương '
        'pháp "parallel lines" (đường song song) hoặc "diamond system" (hệ thống kim cương trên '
        'thành bàn).',
    keyPoints: [
      'Kick shot = bi trắng chạm cushion trước khi chạm bi mục tiêu',
      'Khó — cần kinh nghiệm và cảm giác tốt',
      'Thường dùng khi bị chắn trực tiếp',
    ],
    commonMistakes: [
      'Sai góc — bi không chạm bi mục tiêu',
      'Lực không đủ — bi dừng giữa đường',
    ],
    proTips: [
      'Học hệ thống kim cương trên thành bàn (dấu chấm)',
      'Trong game, kick shot là kỹ thuật cao cấp',
    ],
  ),

  // ==========================================================================
  // ADVANCED
  // ==========================================================================

  'JUMP_SHOT': DrillContent(
    drillCode: 'JUMP_SHOT',
    equipment: [
      'Cơ jump (đầu cơ cứng/skin mỏng)',
      'Phấn',
      'Bi trắng + bi mục tiêu + bi cản (gần)',
    ],
    stance:
        'Đứng ở góc dốc 30-45 độ với bi trắng. Cơ gần như thẳng đứng khi đánh.',
    bridge:
        'Cầu tay cao (elevated bridge) — tay nâng cao trên bàn, đầu cơ hướng xuống bi trắng. '
        'Đầu cơ chỉ chạm phần trên-bi trắng.',
    stroke:
        'Đánh DỨT KHOÁT và MẠNH xuống dưới với một cú giật. Cơ sẽ làm bi trắng nảy lên khỏi bàn, '
        'vượt qua bi cản, rồi rơi xuống đánh bi mục tiêu.',
    aiming:
        'Đánh vào phần trên-của-bi trắng để tạo đà nảy lên. Cần luyện nhiều vì cú này dễ hỏng.',
    keyPoints: [
      'Jump shot = bi trắng vượt qua bi cản',
      'Cần cơ jump chuyên dụng hoặc kỹ thuật đặc biệt',
      'Bị cấm trong nhiều giải đấu — kiểm tra luật trước',
    ],
    commonMistakes: [
      'Đánh quá nhẹ — bi không nảy đủ',
      'Đánh quá mạnh — bi trắng văng khỏi bàn',
      'Không có cơ jump — cơ thường miscues',
    ],
    proTips: [
      'Kiểm tra luật giải đấu trước khi dùng',
      'Luyện nhiều vì cú này đòi hỏi cảm giác tốt',
    ],
  ),

  'MASSE': DrillContent(
    drillCode: 'MASSE',
    equipment: [
      'Cơ masse (đầu cơ dày) hoặc cơ jump',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng ở góc rất dốc (45-90 độ) với bi trắng. Cơ gần như thẳng đứng.',
    bridge:
        'Cầu tay rất cao, gần bi trắng nhất có thể. Cơ nắm chặt.',
    stroke:
        'Đánh MẠNH VÀ DỨT KHOÁT với cú giật nhỏ. Bi trắng sẽ cuộn vòng cung (curved path) thay '
        'vì đi thẳng.',
    aiming:
        'Đánh vào phần rất lệch tâm bi trắng (thường là 1/4 hoặc 3/4 bi). Cú này cực kỳ khó và '
        'chỉ pro mới dùng thành thạo.',
    keyPoints: [
      'Masse = bi trắng đi đường cong (curved)',
      'Cực kỳ khó — kỹ thuật pro',
      'Cần cơ chuyên dụng và lực chính xác',
    ],
    commonMistakes: [
      'Lực sai — không tạo đường cong',
      'Miscue cơ',
      'Bi trắng nhảy khỏi bàn',
    ],
    proTips: [
      'Chỉ thử khi đã là pro. Người mới KHÔNG nên dùng.',
      'Đây là kỹ thuật "show off" trong bi-a',
    ],
  ),

  'BREAK_POWER': DrillContent(
    drillCode: 'BREAK_POWER',
    equipment: [
      'Cơ break (đầu cơ phenolic hoặc cứng)',
      'Phấn',
      'Bi trắng + 15 bi rack (đặt hình tam giác)',
    ],
    stance:
        'Đứng xa rack (cách khoảng 1-1.5m). Thân người nghiêng về phía trước, chân rộng và cố định.',
    bridge:
        'Cầu tay mở dài 30cm, cố định chắc. Cầu tay phải chịu được lực rất lớn từ cú đánh mạnh.',
    stroke:
        'Kéo cơ ra sau 30-40cm. Đánh MẠNH NHẤT CÓ THỂ vào bi rack. Follow through dài tối đa. '
        'Mục tiêu: làm rack vỡ ra và bi chạm thành, phân tán đều.',
    aiming:
        'Đánh vào bi đầu (áp biên) của rack, hơi lệch lên trên (1-2 bi). Tránh đánh full — sẽ dễ '
        'scratch (bi trắng rơi xuống lỗ).',
    keyPoints: [
      'Break = đánh mạnh để rack vỡ',
      'Cần lực cực lớn và cơ break chuyên dụng',
      'Mục tiêu: rack vỡ + bi chạm thành nhiều + không scratch',
    ],
    commonMistakes: [
      'Đánh full vào tâm — dễ scratch',
      'Đánh quá cao — bi nhảy khỏi bàn',
      'Đánh quá nhẹ — rack không vỡ đủ',
    ],
    proTips: [
      'Tập break riêng nhiều lần trước khi thi đấu',
      'Mỗi giải có luật break khác nhau (kiểm tra)',
    ],
  ),

  'BREAK_CONTROL': DrillContent(
    drillCode: 'BREAK_CONTROL',
    equipment: [
      'Cơ break',
      'Phấn',
      'Bi trắng + 15 bi rack',
    ],
    stance:
        'Đứng thẳng, gần rack hơn break thường. Mục tiêu: kiểm soát, không phải lực tối đa.',
    bridge:
        'Cầu tay chắc chắn. Cầu tay đặt vững để kiểm soát hướng bi trắng.',
    stroke:
        'Đánh vừa đủ mạnh để rack vỡ mà bi trắng dừng gần giữa bàn. Follow through vừa đủ.',
    aiming:
        'Đánh vào bi thứ 2 (1 bi lệch lên trên) để bi trắng cuộn về giữa bàn. Tránh scratch vì '
        'mục tiêu là an toàn cho cú tiếp theo.',
    keyPoints: [
      'Control break = rack vỡ + bi trắng ở giữa',
      'Tốt hơn cho vị trí đánh sau break',
      'Trong 9-ball, control break quan trọng',
    ],
    commonMistakes: [
      'Cố đánh quá mạnh — bi trắng chạy xa',
      'Đánh vào tâm — dễ scratch',
    ],
    proTips: [
      'Trong 9-ball, control break thường tốt hơn power break',
      'Tập break nhiều để cảm nhận lực phù hợp',
    ],
  ),

  // ==========================================================================
  // ENGLISH / SIDE SPIN — Xoáy bên
  // ==========================================================================

  'LEFT_ENGLISH_NEAR': DrillContent(
    drillCode: 'LEFT_ENGLISH_NEAR',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh. Left english = xoáy bên trái (khi nhìn từ phía sau cơ).',
    bridge:
        'Cầu tay mở. Đánh xoáy trái = đánh vào phần bên trái của bi trắng (xa tay cầm cơ nhất '
        'nếu thuận phải). Khoảng 3-5mm lệch tâm.',
    stroke:
        'Đánh vừa phải nhưng vuông góc. Cơ phải đi thẳng, không lệch. Follow through đủ dài.',
    aiming:
        'Khi đánh xoáy trái, bi trắng sẽ xoáy ngược chiều kim đồng hồ (khi nhìn từ trên xuống). '
        'Sau khi chạm bi mục tiêu, bi trắng sẽ đi lệch sang phải so với đường full ball. '
        'Dùng để kiểm soát vị trí bi trắng chính xác.',
    keyPoints: [
      'Left english = xoáy bên trái',
      'Bi trắng xoáy ngược chiều kim đồng hồ',
      'Cơ phải đi thẳng để tạo xoáy',
      'Cần phấn kỹ để tránh miscue',
    ],
    commonMistakes: [
      'Đánh lệch cơ — không tạo được xoáy mà còn khiến bi trắng đi lệch',
      'Đánh quá nhẹ — xoáy không đủ',
      'Đánh quá gần rìa bi — miscue',
    ],
    proTips: [
      'Tập cảm giác xoáy với khoảng cách ngắn trước',
      'Tăng dần khoảng cách khi đã thành thạo',
    ],
  ),

  'RIGHT_ENGLISH_NEAR': DrillContent(
    drillCode: 'RIGHT_ENGLISH_NEAR',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh. Right english = xoáy bên phải (khi nhìn từ phía sau cơ).',
    bridge:
        'Cầu tay mở. Đánh xoáy phải = đánh vào phần bên phải của bi trắng (gần tay cầm cơ). '
        'Khoảng 3-5mm lệch tâm.',
    stroke:
        'Đánh vừa phải nhưng vuông góc. Cơ phải đi thẳng, không lệch. Follow through đủ dài.',
    aiming:
        'Khi đánh xoáy phải, bi trắng sẽ xoáy theo chiều kim đồng hồ. Sau khi chạm bi mục tiêu, '
        'bi trắng sẽ đi lệch sang trái so với đường full ball.',
    keyPoints: [
      'Right english = xoáy bên phải',
      'Bi trắng xoáy theo chiều kim đồng hồ',
      'Cơ phải đi thẳng để tạo xoáy',
    ],
    commonMistakes: [
      'Đánh lệch cơ — không tạo được xoáy',
      'Đánh quá gần rìa bi — miscue',
    ],
    proTips: [
      'Tập riêng cảm giác trước khi kết hợp với follow/draw',
    ],
  ),

  'TOP_SPIN_CONTROL': DrillContent(
    drillCode: 'TOP_SPIN_CONTROL',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh. Top spin = xoáy tiến (follow). Bi trắng xoáy cùng chiều đi.',
    bridge:
        'Cầu tay mở. Đánh top spin = đánh vào phần trên bi trắng (cao hơn tâm). Khoảng 1-3mm.',
    stroke:
        'Đánh vừa phải với follow through DÀI. Cơ đi theo đường "dưới lên" qua tâm bi trắng.',
    aiming:
        'Sau khi chạm bi mục tiêu, bi trắng tiếp tục cuộn về phía trước. Khoảng cách cuộn thêm '
        'phụ thuộc vào lực đánh. Top spin tốt nhất khi đánh nhẹ vừa.',
    keyPoints: [
      'Top spin = follow = xoáy tiến',
      'Follow through dài để truyền xoáy',
      'Đánh xa quá dễ mất xoáy',
    ],
    commonMistakes: [
      'Đánh quá nhẹ — không có xoáy',
      'Đánh quá mạnh — bi trắng nhảy sau khi chạm thành',
      'Đánh quá cao trên bi — miscue',
    ],
    proTips: [
      'Tập với bi mục tiêu gần trước',
      'Dùng để position bi trắng sau khi đánh',
    ],
  ),

  'BACK_SPIN_CONTROL': DrillContent(
    drillCode: 'BACK_SPIN_CONTROL',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh. Back spin = xoáy lùi (draw). Bi trắng xoáy ngược chiều đi.',
    bridge:
        'Cầu tay mở. Đánh back spin = đánh vào phần dưới bi trắng (dưới tâm). Khoảng 2-5mm, '
        'xa hơn top spin vì ma sát lớn hơn.',
    stroke:
        'Đánh MẠNH với follow through DÀI. Cần nhiều lực để thắng ma sát. Đánh quá nhẹ = stop ball.',
    aiming:
        'Sau khi chạm bi mục tiêu, bi trắng quay lùi (backspin). Khoảng cách lùi tùy lực và '
        'độ sâu đánh. Đánh càng thấp trên bi = càng nhiều backspin.',
    keyPoints: [
      'Back spin = draw = xoáy lùi',
      'Cần lực MẠNH + follow through DÀI',
      'Đánh full ball = backspin tối đa',
    ],
    commonMistakes: [
      'Đánh quá nhẹ — không đủ lực cho backspin',
      'Đánh quá thấp — miscue',
      'Đánh không full ball — backspin mất',
    ],
    proTips: [
      'Phấn kỹ đầu cơ trước để tránh miscue',
      'Dùng khi cần bi trắng lùi về vị trí thuận lợi',
    ],
  ),

  'FOLLOW_FAR': DrillContent(
    drillCode: 'FOLLOW_FAR',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu ở khoảng cách xa',
    ],
    stance:
        'Đứng xa bi, thân người nghiêng về phía trước. Chân rộng, cố định.',
    bridge:
        'Cầu tay dài 25-30cm để có follow through dài truyền xoáy. Tay cố định.',
    stroke:
        'Kéo cơ ra sau 20-25cm. Đánh với lực MẠNH và follow through RẤT DÀI. '
        'Cơ phải đi qua tâm bi trắng và tiếp tục đi lên cao.',
    aiming:
        'Ngắm vào tâm bi mục tiêu. Sau khi chạm, bi trắng sẽ cuộn về phía trước một khoảng '
        'lớn nhờ follow shot mạnh.',
    keyPoints: [
      'Follow shot ở khoảng cách xa = cần lực lớn',
      'Follow through cực dài là chìa khóa',
      'Phấn kỹ đầu cơ để tránh miscue',
    ],
    commonMistakes: [
      'Đánh không đủ lực — không có xoáy',
      'Follow through ngắn — không truyền xoáy',
    ],
    proTips: [
      'Tập ở khoảng cách gần trước khi xa',
      'Trong game, dùng khi cần bi trắng đi xa sau khi chạm bi mục tiêu',
    ],
  ),

  'DRAW_BACK_FAR': DrillContent(
    drillCode: 'DRAW_BACK_FAR',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu ở khoảng cách xa',
    ],
    stance:
        'Đứng xa bi, thân người nghiêng về phía trước. Chân rộng và cố định.',
    bridge:
        'Cầu tay dài 25-30cm. Tay cố định chắc chắn.',
    stroke:
        'Kéo cơ ra sau 25-30cm. Đánh MẠNH NHẤT CÓ THỂ. Follow through DÀI. Đây là cú đòi hỏi '
        'lực lớn nhất trong billiards.',
    aiming:
        'Cú này cần lực cực lớn để bi trắng vừa chạm bi mục tiêu vừa giữ đủ backspin để quay lùi. '
        'Cần lực lớn hơn 50% so với draw shot thường.',
    keyPoints: [
      'Draw shot ở khoảng cách xa = cần lực CỰC LỚN',
      'Follow through dài là yếu tố sống còn',
      'Phấn kỹ để tránh miscue',
    ],
    commonMistakes: [
      'Đánh không đủ mạnh — bi không backspin',
      'Đánh quá thấp trên bi — miscue',
      'Không đủ follow through',
    ],
    proTips: [
      'Cú này chỉ nên dùng khi thực sự cần thiết',
      'Trong game, nếu có lựa chọn khác thì dùng lựa chọn đó',
    ],
  ),

  'THICK_CUT_60': DrillContent(
    drillCode: 'THICK_CUT_60',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Đứng thẳng đường đánh. Cắt dày 60 độ = gần full ball, bi mục tiêu đi theo hướng gần '
        'thẳng với đường đánh.',
    bridge:
        'Cầu tay mở tiêu chuẩn. Đánh full ball nên không cần điểm tiếp xúc chính xác.',
    stroke:
        'Đánh vừa phải. Lực không quan trọng bằng hướng đánh.',
    aiming:
        'Ngắm qua tâm bi mục tiêu. Bi mục tiêu đi theo đường kéo dài của đường đánh. Dễ hơn các '
        'cắt khác vì sai số nhỏ.',
    keyPoints: [
      'Cắt dày 60 độ = gần full ball',
      'Bi mục tiêu đi theo hướng gần thẳng',
      'Lực vừa đủ là chìa khóa',
    ],
    commonMistakes: [
      'Đánh quá mạnh — bi nhảy khỏi lỗ',
    ],
    proTips: [
      'Cú dễ nhất trong các cú cắt — phù hợp người mới',
    ],
  ),

  'LONG_POT_2M': DrillContent(
    drillCode: 'LONG_POT_2M',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu cách lỗ 2m',
    ],
    stance:
        'Đứng rất xa bi, dùng cầu tay cơ học nếu cần. Thân người nghiêng về phía trước.',
    bridge:
        'Cầu tay cơ học hoặc cầu tay dài 35cm. Tay cố định tuyệt đối.',
    stroke:
        'Kéo cơ ra sau 30cm. Đánh MẠNH NHẤT. Follow through DÀI TỐI ĐA.',
    aiming:
        'Khoảng cách cực xa — sai số 1mm = sai số 5mm ở lỗ. Cần chính xác cực cao. Cân nhắc dùng '
        'kính ngắm hoặc đồng đội xác nhận.',
    keyPoints: [
      '2m = cực kỳ xa, chỉ dùng khi cần',
      'Phải chính xác cao',
      'Lực cực mạnh',
    ],
    commonMistakes: [
      'Đánh không đủ mạnh',
      'Sai hướng do khoảng cách xa',
    ],
    proTips: [
      'Trong game thật, 2m là cú rủi ro cao — chỉ thử khi tự tin',
    ],
  ),

  // ==========================================================================
  // PATTERN PLAY — Kế hoạch đánh nhiều bi
  // ==========================================================================

  'PATTERN_3_BALLS': DrillContent(
    drillCode: 'PATTERN_3_BALLS',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 3 bi mục tiêu',
    ],
    stance:
        'Thay đổi stance theo từng cú. Trước mỗi cú, đứng sao cho thuận lợi nhất.',
    bridge:
        'Cầu tay thay đổi theo từng cú. Đôi khi cần cầu tay cơ học.',
    stroke:
        'Lực thay đổi theo từng cú. Mỗi cú phải nhắm vào cú tiếp theo.',
    aiming:
        'Phải lập kế hoạch trước cả 3 cú. Bi nào đánh trước, bi trắng sẽ ở đâu, bi nào đánh tiếp. '
        'Tính toán đường đi của bi trắng sau mỗi cú.',
    keyPoints: [
      'Pattern play = lập kế hoạch nhiều cú',
      'Mỗi cú phải chuẩn bị cho cú tiếp theo',
      'Tư duy chiến thuật quan trọng',
    ],
    commonMistakes: [
      'Chỉ nghĩ 1 cú trước',
      'Đánh quá mạnh ở cú đầu',
      'Không tính được đường bi trắng',
    ],
    proTips: [
      'Trong game thật, luôn nghĩ trước ít nhất 2 cú',
      'Nếu không thấy đường đi rõ ràng, đừng đánh',
    ],
  ),

  'PATTERN_5_BALLS': DrillContent(
    drillCode: 'PATTERN_5_BALLS',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + 5 bi mục tiêu',
    ],
    stance:
        'Thay đổi stance mỗi cú. Phải luôn kiểm soát vị trí bi trắng.',
    bridge:
        'Cầu tay thay đổi theo vị trí bi. Sẵn sàng dùng cầu tay cơ học.',
    stroke:
        '5 cú liên tiếp. Lực phải chính xác cho từng cú. Đây là bài tập sức chịu đựng và tư duy.',
    aiming:
        'Lập kế hoạch trước toàn bộ 5 cú. Đánh xong thì đánh tiếp. Tính sai 1 cú = phải làm lại.',
    keyPoints: [
      'Pattern 5 bi = bài tập lâu dài',
      'Tư duy chiến thuật và sức chịu đựng',
      'Áp dụng vào game 8-ball/9-ball',
    ],
    commonMistakes: [
      'Mệt mỏi về tinh thần ở cú 3-4',
      'Tính toán sai',
    ],
    proTips: [
      'Tập 3 bi trước khi lên 5',
      'Trong game, đây là kỹ năng cốt lõi',
    ],
  ),

  'PATTERN_MULTI_RAIL': DrillContent(
    drillCode: 'PATTERN_MULTI_RAIL',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + nhiều bi mục tiêu',
    ],
    stance:
        'Thay đổi stance mỗi cú. Đặc biệt chú ý các cú có bi trắng chạm thành nhiều lần.',
    bridge:
        'Cầu tay thay đổi theo vị trí. Cú có multi-rail cần cầu tay vững để đánh chính xác.',
    stroke:
        'Lực vừa đến mạnh. Multi-rail shot cần lực chính xác.',
    aiming:
        'Multi-rail = bi chạm thành nhiều lần trước khi dừng. Cần tính toán đường đi phức tạp. '
        'Dùng hệ thống kim cương trên thành bàn.',
    keyPoints: [
      'Multi-rail = 2-3 lần chạm thành',
      'Kỹ thuật pro',
      'Cần tính toán nhiều',
    ],
    commonMistakes: [
      'Sai góc phản xạ',
      'Lực không đủ',
    ],
    proTips: [
      'Học hệ thống kim cương trên thành bàn',
      'Trong game, multi-rail giúp bi trắng về vị trí tốt',
    ],
  ),

  // ==========================================================================
  // KỸ THUẬT NỀN TẢNG — Form drills
  // ==========================================================================

  'BRIDGE_FORM': DrillContent(
    drillCode: 'BRIDGE_FORM',
    equipment: [
      'Cơ billiards',
      'Phấn',
    ],
    stance:
        'Đứng thẳng, thả lỏng. Mục tiêu bài tập này là tay (cầu tay), không phải kỹ thuật đánh.',
    bridge:
        'Tập cả 2 loại cầu tay: 1) Open bridge (cầu tay mở) — các ngón tay xếp thành chữ V, cơ nằm '
        'trong rãnh. 2) Closed bridge (cầu tay đóng) — ngón trỏ vòng qua tạo thành vòng khép kín. '
        'Cầu tay mở thích hợp cho người mới, cầu tay đóng chắc chắn hơn nhưng khó hơn.',
    stroke:
        'Không cần đánh bi — chỉ tập đặt cầu tay và đẩy cơ qua lại 10-15 lần. Đảm bảo cầu tay '
        'thoải mái, không bị mỏi sau 5 phút.',
    aiming:
        'Tập cầu tay ở các vị trí khác nhau: gần bi, xa bi, cao (elevated bridge), thấp. Mỗi vị trí '
        'cần cầu tay khác nhau.',
    keyPoints: [
      'Cầu tay là yếu tố quan trọng nhất — 80% kỹ thuật đánh phụ thuộc cầu tay',
      'Cầu tay mở: dễ học, linh hoạt',
      'Cầu tay đóng: chắc chắn hơn, ổn định hơn',
      'Cầu tay thấp = đánh thường; cầu tay cao = tránh bi cản',
    ],
    commonMistakes: [
      'Cầu tay cao quá — cơ dễ rung',
      'Ngón tay siết quá chặt — cơ không di chuyển mượt',
      'Cầu tay xa bi quá — mất kiểm soát',
      'Không tập cầu tay đóng — giới hạn kỹ thuật',
    ],
    proTips: [
      'Tập cầu tay 5-10 phút mỗi ngày trước khi đánh bi',
      'Cầu tay đóng nên dùng khi cần lực mạnh',
      'Cầu tay mở linh hoạt hơn cho nhiều tình huống',
    ],
  ),

  'STANCE_FORM': DrillContent(
    drillCode: 'STANCE_FORM',
    equipment: [
      'Cơ billiards',
      'Phấn',
    ],
    stance:
        'Tập đứng ở tư thế chuẩn: chân rộng bằng vai, chân trước chỉ thẳng về phía bi mục tiêu, '
        'thân người thẳng + hơi nghiêng về phía trước, trọng lượng dồn đều 2 chân. '
        'Đầu gối chân trước hơi cong. Vai không được xoay quá nhiều.',
    bridge:
        'Khi stance đúng, cầu tay tự nhiên vào vị trí. Tay cầu cơ (tay sau) buông thõng tự nhiên, '
        'cằm chạm cơ hoặc gần cơ.',
    stroke:
        'Không cần đánh bi — chỉ tập đứng và đặt cơ vào vị trí. Đứng 30 giây - 1 phút mỗi lần để '
        'cảm nhận sự thoải mái.',
    aiming:
        'Tập ở nhiều góc đánh khác nhau: thẳng, cắt trái, cắt phải. Stance phải ổn định ở mọi góc.',
    keyPoints: [
      'Stance = nền tảng của mọi cú đánh',
      'Chân trước chỉ thẳng mục tiêu',
      'Thân người thẳng và cân bằng',
      'Trọng lượng dồn đều',
    ],
    commonMistakes: [
      'Chân quá hẹp — mất cân bằng',
      'Chân quá rộng — khó xoay',
      'Thân người xoay quá — mất lực đánh',
      'Đầu cúi quá thấp — khó theo dõi đường bi',
    ],
    proTips: [
      'Tập stance 5 phút mỗi ngày trước khi đánh',
      'Chụp ảnh stance để tự kiểm tra',
      'Tập trước gương nếu có thể',
    ],
  ),

  'STROKE_STRAIGHT': DrillContent(
    drillCode: 'STROKE_STRAIGHT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng (tập đánh thẳng vào thành bàn)',
    ],
    stance:
        'Stance chuẩn. Đặt bi trắng thẳng hướng với 1 điểm trên thành đối diện.',
    bridge:
        'Cầu tay mở hoặc đóng tùy thói quen. Tay cầu cơ (tay sau) nắm nhẹ vừa đủ.',
    stroke:
        'Đánh bi trắng đi thẳng và dừng ở điểm đã định trên thành đối diện. Lặp lại 20-30 lần. '
        'Đánh chậm để cảm nhận đường cơ, sau đó tăng tốc.',
    aiming:
        'Mục tiêu: bi trắng đi thẳng. Nếu lệch sang trái/phải, hiệu chỉnh hướng stance hoặc cầu tay. '
        'Stroke thẳng là nền tảng cho mọi cú đánh khác.',
    keyPoints: [
      'Stroke thẳng = đường cơ thẳng',
      'Tay cố định, chỉ khuỷu tay di chuyển',
      'Follow through tự nhiên',
      'Đánh nhiều lần để cơ thể nhớ',
    ],
    commonMistakes: [
      'Tay lắc sang trái/phải',
      'Cổ tay cong khi đánh',
      'Khuỷu tay di chuyển không cố định',
      'Follow through không đều',
    ],
    proTips: [
      'Tập đánh vào thành và quay lại — bi đập thành và quay về gần vị trí ban đầu',
      'Đặt 1 vật nhỏ sau bi trắng làm mục tiêu',
      'Tập 10-15 phút mỗi ngày',
    ],
  ),

  'BREAK_DRY': DrillContent(
    drillCode: 'BREAK_DRY',
    equipment: [
      'Cơ break',
      'Phấn',
      'Bi trắng + 15 bi rack',
    ],
    stance:
        'Đứng xa rack, stance chuẩn. Break dry = tập break mà không có kết quả (không đếm điểm).',
    bridge:
        'Cầu tay chắc chắn, cố định. Chịu được lực mạnh.',
    stroke:
        'Đánh mạnh để rack vỡ. Lặp lại 10-20 lần để cảm nhận lực phù hợp. Không quan tâm kết quả '
        'mà chỉ tập cảm giác.',
    aiming:
        'Tập các điểm đánh khác nhau: full ball, lệch 1 bi, lệch 2 bi. Mỗi điểm tạo kết quả khác. '
        'Tìm điểm tối ưu của mình.',
    keyPoints: [
      'Break dry = tập kỹ thuật break',
      'Không quan tâm kết quả',
      'Tìm điểm đánh tối ưu',
    ],
    commonMistakes: [
      'Quá tập trung vào kết quả',
      'Không thay đổi điểm đánh',
    ],
    proTips: [
      'Tập break dry 5-10 phút trước khi thi đấu',
      'Ghi chép lại điểm đánh nào cho kết quả tốt nhất',
    ],
  ),

  // ==========================================================================
  // PRACTICE / MENTAL — Tập luyện tâm lý
  // ==========================================================================

  'PRESSURE_SHOT': DrillContent(
    drillCode: 'PRESSURE_SHOT',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Stance chuẩn. Tập đứng vững dù tâm lý căng thẳng.',
    bridge:
        'Cầu tay chắc. Tay có thể run nếu stress — tập cầu tay để quen.',
    stroke:
        'Đánh bình thường. Mục tiêu là tâm lý, không phải kỹ thuật. Lặp lại nhiều lần để giảm stress.',
    aiming:
        'Tập đánh dưới áp lực: đặt giới hạn thời gian (đếm 5 giây phải đánh), hoặc có người xem. '
        'Mục tiêu: đánh chính xác khi bị áp lực.',
    keyPoints: [
      'Pressure shot = tập đánh khi căng thẳng',
      'Yếu tố tâm lý quan trọng',
      'Luyện dưới áp lực giúp giảm stress khi thi đấu',
    ],
    commonMistakes: [
      'Run vì áp lực',
      'Đánh quá nhanh — sai kỹ thuật',
    ],
    proTips: [
      'Trong game, hít thở sâu 1 lần trước cú quan trọng',
      'Tập với bạn bè để có áp lực thật',
    ],
  ),

  'COMEBACK_PRACTICE': DrillContent(
    drillCode: 'COMEBACK_PRACTICE',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bàn billiards',
    ],
    stance:
        'Stance chuẩn. Tập duy trì form dù kết quả không tốt.',
    bridge:
        'Cầu tay chắc. Không để cú đánh tệ ảnh hưởng cú tiếp theo.',
    stroke:
        'Đánh đều đặn. Mục tiêu là duy trì kỹ thuật qua nhiều cú, kể cả cú tệ.',
    aiming:
        'Tập scenarios: đối thủ dẫn 5-0, mình phải comeback. Hoặc tự đặt mình thua 5-0 và tập tâm lý.',
    keyPoints: [
      'Comeback = tâm lý khi đang thua',
      'Không bỏ cuộc',
      'Duy trì kỹ thuật',
    ],
    commonMistakes: [
      'Bỏ cuộc khi thua',
      'Đánh liều để gỡ',
    ],
    proTips: [
      'Trong game, mỗi cú đánh là độc lập — cú trước không ảnh hưởng cú sau',
      'Pro vẫn thua 50% game — quan trọng là phản ứng thế nào',
    ],
  ),

  'FOCUS_DRILL': DrillContent(
    drillCode: 'FOCUS_DRILL',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Stance chuẩn. Tập tập trung 100% vào cú đánh hiện tại.',
    bridge:
        'Cầu tay chắc. Tay cố định, không có suy nghĩ nào khác.',
    stroke:
        'Đánh từ từ, chú ý từng chi tiết. Đếm nhịp: 1-2-3-stroke.',
    aiming:
        'Trước mỗi cú, tạm dừng 3-5 giây. Quan sát bi, lỗ, đường đi. Sau đó đánh. Lặp lại 20 lần.',
    keyPoints: [
      'Focus = tập trung hoàn toàn',
      'Mỗi cú đánh là một sự kiện độc lập',
      'Quan sát trước, đánh sau',
    ],
    commonMistakes: [
      'Nghĩ về cú trước hoặc cú sau',
      'Bị phân tâm bởi tiếng ồn',
    ],
    proTips: [
      'Trong game, tạo "bubble" tập trung quanh mình',
      'Đếm nhịp trước khi đánh giúp tập trung',
    ],
  ),

  'TIE_BREAKER': DrillContent(
    drillCode: 'TIE_BREAKER',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Stance vững nhưng thoải mái. Đừng quá căng thẳng.',
    bridge:
        'Cầu tay chắc. Đừng run vì sợ thua.',
    stroke:
        'Đánh bình thường. Cú tie-breaker giống mọi cú khác về kỹ thuật.',
    aiming:
        'Tập cú đánh khi tỉ số hòa. Có thể tự tạo tình huống với bạn bè.',
    keyPoints: [
      'Tie-breaker = quyết định thắng thua',
      'Tâm lý quan trọng nhất',
      'Kỹ thuật đã có — chỉ cần tập trung',
    ],
    commonMistakes: [
      'Run và đánh vội',
      'Quá tự tin — đánh cú khó khi không cần',
    ],
    proTips: [
      'Hít thở sâu trước cú quyết định',
      'Đánh cú đơn giản nếu có thể — đừng overthink',
    ],
  ),

  'SCRATCH_RECOVERY': DrillContent(
    drillCode: 'SCRATCH_RECOVERY',
    equipment: [
      'Cơ billiards',
      'Phấn',
      'Bi trắng + bi mục tiêu',
    ],
    stance:
        'Stance vững. Sau khi scratch, tâm lý có thể bị ảnh hưởng — phải giữ bình tĩnh.',
    bridge:
        'Cầu tay chắc. Đừng để cú scratch ảnh hưởng cú tiếp theo.',
    stroke:
        'Sau scratch, bi trắng đặt ở "kitchen" (vùng đầu bàn). Đánh từ vị trí này có thể khó hơn. '
        'Tập đánh từ kitchen thường xuyên.',
    aiming:
        'Tập các tình huống đặt bi trắng ở kitchen. Đây là cú bắt buộc sau scratch. Cần biết cú nào '
        'khả thi từ vị trí này.',
    keyPoints: [
      'Scratch = bi trắng rơi xuống lỗ',
      'Sau scratch, bi trắng đặt ở kitchen',
      'Có thể đánh ra thành để bi trắng chạy vào vị trí tốt',
    ],
    commonMistakes: [
      'Cố đánh cú khó khi bi ở kitchen',
      'Mất tập trung sau khi scratch',
    ],
    proTips: [
      'Đánh bi mục tiêu nhẹ vào thành để bi trắng chạm thành 2 lần và quay lại giữa bàn',
      'Tập "push out" sau scratch — cú đặt bi trắng ở vị trí thuận lợi',
    ],
  ),
};
