import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Dấu hiệu bi-a của PoolOS: một bi đặc và cây cơ chéo chạm vào nó.
///
/// Tồn tại vì Material **không có glyph bi-a nào**. Trước đây tám chỗ mượn
/// icon BỂ BƠI của Material — glyph vẽ một người đang bơi — nên app bi-a lại
/// mang hình người bơi ở cả màn đăng nhập lẫn bong bóng chat coach.
///
/// (Không viết tên icon đó ra đây: luật chặn trong
/// `test/widgets/pool_cue_mark_test.dart` quét cả chú thích.)
///
/// Vẽ theo hai ràng buộc, cái sau là cái khó:
///
///  1. Bóng dáng cây cơ là thứ không môn nào khác có, nên nó gánh phần lớn
///     việc "đọc ra bi-a". Bi một mình chỉ là một chấm tròn.
///  2. Phải sống được ở **18px** — cỡ nhỏ nhất trong app, ở
///     `coach_chat_bubble`. Vì vậy mark chỉ có HAI hình (một tròn đặc, một nét
///     chéo) và chỗ mảnh nhất vẫn dày `size * 0.07`; mọi chi tiết khác — số
///     trên bi, vệt sáng, phần ferrule của cơ — đều bị bỏ vì ở 18px chúng biến
///     thành nhiễu.
class PoolCueMark extends StatelessWidget {
  const PoolCueMark({super.key, this.size = 24, this.color});

  final double size;

  /// Bỏ trống thì lấy `AppColors.primary(brightness)` của theme đang chạy.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ?? AppColors.primary(Theme.of(context).brightness);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: PoolCueMarkPainter(color: resolved)),
    );
  }
}

/// Công khai để test đọc được [color]; không dựng trực tiếp ở màn nào.
@visibleForTesting
class PoolCueMarkPainter extends CustomPainter {
  PoolCueMarkPainter({required this.color});

  final Color color;

  /// Mọi hằng số dưới đây là tỉ lệ trên cạnh ô vuông.
  ///
  /// Tỉ lệ bi/cơ là thứ quyết định mark đọc ra cái gì. Bản đầu cho bi bán kính
  /// 0,26 và cơ dài 0,52 — nhìn ra **cái chảo**, vì cán ngắn hơn hai lần đường
  /// kính bi thì mắt đọc nó là tay cầm. Cơ bây giờ dài gấp ~2,3 lần đường kính
  /// bi, đúng khoảng mà bóng dáng cây cơ thắng.
  static const _tamBi = Offset(0.28, 0.74);
  static const _banKinhBi = 0.15;

  /// Cơ chỉ về phía trên-phải, 45°.
  static const _huongCo = Offset(0.7071, -0.7071);

  /// Khe hở giữa đầu cơ và mặt bi: không có khe thì hai hình dính thành một
  /// khối nhoè ở cỡ nhỏ.
  static const _kheHo = 0.05;

  /// Đuôi cơ dừng ở 0,90 chứ không phải mép ô — nửa bề dày cộng đầu bo tròn
  /// còn ăn thêm ra ngoài, và ở [IconTile] phần thừa đó đâm vào góc bo của ô.
  static const _duoiCo = Offset(0.90, 0.12);

  /// Cơ thuôn: đầu chạm bi mảnh, đuôi dày. Ở 18px thành 1,26px và 1,98px —
  /// vẫn là hai bề dày phân biệt được, nên dáng thuôn còn đọc ra.
  static const _nuaDayDauCo = 0.035;
  static const _nuaDayDuoiCo = 0.055;

  @override
  void paint(Canvas canvas, Size size) {
    final canh = size.shortestSide;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final tam = Offset(_tamBi.dx * canh, _tamBi.dy * canh);
    canvas.drawCircle(tam, _banKinhBi * canh, fill);

    final dauCo = tam + _huongCo * ((_banKinhBi + _kheHo) * canh);
    final duoiCo = Offset(_duoiCo.dx * canh, _duoiCo.dy * canh);
    final vuongGoc = Offset(-_huongCo.dy, _huongCo.dx);

    final than = Path()
      ..moveTo(
          (dauCo + vuongGoc * (_nuaDayDauCo * canh)).dx,
          (dauCo + vuongGoc * (_nuaDayDauCo * canh)).dy)
      ..lineTo(
          (dauCo - vuongGoc * (_nuaDayDauCo * canh)).dx,
          (dauCo - vuongGoc * (_nuaDayDauCo * canh)).dy)
      ..lineTo(
          (duoiCo - vuongGoc * (_nuaDayDuoiCo * canh)).dx,
          (duoiCo - vuongGoc * (_nuaDayDuoiCo * canh)).dy)
      ..lineTo(
          (duoiCo + vuongGoc * (_nuaDayDuoiCo * canh)).dx,
          (duoiCo + vuongGoc * (_nuaDayDuoiCo * canh)).dy)
      ..close();
    canvas.drawPath(than, fill);

    // Bo tròn hai đầu: góc nhọn của hình thang trông như mảnh vỡ ở cỡ lớn.
    canvas.drawCircle(dauCo, _nuaDayDauCo * canh, fill);
    canvas.drawCircle(duoiCo, _nuaDayDuoiCo * canh, fill);
  }

  @override
  bool shouldRepaint(covariant PoolCueMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
