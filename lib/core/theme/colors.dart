import 'package:flutter/material.dart';

/// PoolOS Design System - Color Tokens
/// Based on Minimalist Luxury design philosophy
class AppColors {
  AppColors._();

  // ========================================================================
  // LIGHT MODE COLORS
  // ========================================================================

  // Background & Surface
  static const Color lightBackground = Color(0xFFF7F4EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceRecessed = Color(0xFFF1EFEA);

  // Text
  static const Color lightTextPrimary = Color(0xFF12352B);
  static const Color lightTextSecondary = Color(0xFF5E6661);
  static const Color lightTextTertiary = Color(0xFF9AA39D);

  // Borders & Dividers
  static const Color lightBorder = Color(0xFFE7E3DA);
  static const Color lightBorderSubtle = Color(0xFFF0EDE5);

  // ========================================================================
  // DARK MODE COLORS
  // ========================================================================

  // Background & Surface
  static const Color darkBackground = Color(0xFF121715);
  static const Color darkSurface = Color(0xFF1B221F);
  static const Color darkSurfaceElevated = Color(0xFF232B27);
  static const Color darkSurfaceRecessed = Color(0xFF171D1A);

  // Text
  static const Color darkTextPrimary = Color(0xFFECF1EE);
  static const Color darkTextSecondary = Color(0xFF9AA6A0);
  static const Color darkTextTertiary = Color(0xFF6F7B75);

  // Borders & Dividers
  static const Color darkBorder = Color(0xFF2C3531);
  static const Color darkBorderSubtle = Color(0xFF242C29);

  // ========================================================================
  // ACCENT COLORS (Both Modes)
  // ========================================================================

  // Primary Accent - Electric Blue (Premium, Trustworthy)
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);
  static const Color accentDark = Color(0xFF1D4ED8);
  static const Color accentSubtleLight = Color(0xFFEFF6FF);
  static const Color accentSubtleDark = Color(0xFF1E3A5F);

  // ========================================================================
  // XANH RÊU — MÀU CHÍNH
  // ========================================================================

  static const Color lightPrimary = Color(0xFF0F4032);
  static const Color lightPrimaryDeep = Color(0xFF08291F);
  static const Color lightPrimaryContainer = Color(0xFF0F4032);
  static const Color lightAccentLabel = Color(0xFF0F7A55);

  static const Color darkPrimary = Color(0xFF34A97C);
  static const Color darkPrimaryDeep = Color(0xFF2A8A65);
  static const Color darkPrimaryContainer = Color(0xFF16382C);
  static const Color darkAccentLabel = Color(0xFF4FC79A);

  // ========================================================================
  // BLOB NỀN — đặt sau lớp nền, opacity thấp
  // ========================================================================

  static const Color lightBlobPeach = Color(0xFFFBE9DC);
  static const Color lightBlobMint = Color(0xFFDFEFE4);
  static const Color lightBlobButter = Color(0xFFFDF6E3);

  static const Color darkBlobPeach = Color(0xFF2A1E18);
  static const Color darkBlobMint = Color(0xFF16241E);
  static const Color darkBlobButter = Color(0xFF262214);

  // ========================================================================
  // Ô PASTEL — gán theo danh mục ỔN ĐỊNH, không ngẫu nhiên.
  // Người dùng học được màu, nên cùng một danh mục phải luôn cùng tông.
  // ========================================================================

  static const List<Color> pastelLight = [
    Color(0xFFDCEFE5), // mint
    Color(0xFFDCE7F7), // blue
    Color(0xFFFBE7DA), // peach
    Color(0xFFEAE3F7), // lilac
    Color(0xFFFBF0D5), // butter
  ];

  static const List<Color> pastelDark = [
    Color(0xFF1C3830),
    Color(0xFF1B2A3C),
    Color(0xFF38281F),
    Color(0xFF2A2438),
    Color(0xFF33301F),
  ];

  // ========================================================================
  // SEMANTIC COLORS (Both Modes)
  // ========================================================================

  // Success - Emerald Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSubtleLight = Color(0xFFECFDF5);
  static const Color successSubtleDark = Color(0xFF064E3B);

  // Warning - Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSubtleLight = Color(0xFFFFFBEB);
  static const Color warningSubtleDark = Color(0xFF78350F);

  // Error - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSubtleLight = Color(0xFFFEF2F2);

  /// Nền lỗi bản tối.
  ///
  /// Trước là #7F1D1D: `error` #EF4444 đặt lên chỉ đạt 2.66:1 — dưới sàn 3:1
  /// cho một đối tượng đồ hoạ mang nghĩa, trong khi hai ô anh em đã đạt
  /// (success 3.83:1, warning 4.22:1). Nhìn theo HSL thì lỗi lộ ngay: ô lỗi là
  /// ô SÁNG NHẤT trong ba (L=30.6% so với success 16% và warning 26%). Hạ dọc
  /// đúng tia HSL của chính nó (hue 0°, sat 63%) xuống L=20% đưa nó vào giữa
  /// dải anh em và nâng tỉ lệ lên 3.80:1.
  static const Color errorSubtleDark = Color(0xFF531313);

  // ========================================================================
  // TÔNG CHỮ/ICON TRÊN NỀN 10% CỦA CHÍNH TÔNG ĐÓ ("badge")
  //
  // Thành ngữ badge của repo là chữ tông semantic đặt trên nền 10% của chính
  // tông ấy:
  //
  //   Container(color: tone.withValues(alpha: 0.1), child: Text(color: tone))
  //
  // Ở 10–13px đậm, đó là chữ thường -> sàn 4.5:1. Đo trên surface bản SÁNG —
  // chế độ duy nhất đang phát hành — thành ngữ này TRƯỢT ở cả ba tông:
  //   success 2.31 | warning 1.99 | error 3.29
  //
  // Các hằng *Dark có sẵn KHÔNG cứu được: dùng làm chữ chỉ lên
  // 5.74 / 2.95 / 4.23 — warning và error vẫn dưới sàn.
  //
  // Nên phải có họ accessor riêng, và phải theo Brightness: bản sáng phải
  // ĐẬM đi khỏi tông gốc, bản tối phải SÁNG lên. Một hằng phẳng không thể
  // phục vụ cả hai chiều ngược nhau.
  //
  // Cách dựng giá trị: hạ/nâng độ sáng DỌC ĐÚNG TIA HSL của chính tông đó —
  // giữ nguyên hue và độ bão hoà — nên mỗi tông vẫn là chính nó, chỉ đậm
  // hoặc nhạt hơn. Đây đúng tiền lệ đã dùng cho `errorSubtleDark` ở trên.
  //
  // Nền chuẩn hoá: ĐO TRÊN CẢ `surface` LẪN `background`, vì badge xuất hiện
  // trên cả hai. Bản sáng bị `background` #F7F4EC siết chặt hơn (nền kem sẫm
  // hơn trắng -> nền 10% sẫm hơn -> chữ sẫm tương phản kém hơn); bản tối thì
  // ngược lại, `surface` #1B221F mới là mặt siết.
  //
  // HỌ NỀN THỨ HAI: các hằng `*Subtle` (successSubtleLight #ECFDF5,
  // warningSubtleDark #78350F, …) cũng là "nền dịu cùng tông" và cũng đỡ
  // chữ/icon của chính tông đó — đúng một bài toán. Nên MỘT họ token này
  // phục vụ CẢ HAI họ nền, không đẻ thêm `*OnSubtle`.
  //
  // Chính họ nền thứ hai mới siết bản TỐI. Nền `*Subtle` bản tối sáng hơn hẳn
  // một lớp phủ 10% trên #1B221F, nên mực tối lấy thẳng tông gốc (#10B981,
  // #F59E0B) chỉ đạt 3.83 / 4.22 ở đó — vẫn dưới sàn. Vì thế mực tối phải
  // nâng sáng khỏi tông gốc, và nâng như vậy KHÔNG hại nền 10% (nền đó rất
  // sẫm nên mực sáng hơn chỉ tương phản tốt hơn).
  //
  //   tông     chế độ  mực      nền 10% (surf/bg)   *Subtle
  //   success  sáng    #0A7753  5.06 / 4.63         5.28
  //   success  tối     #12CB8D  6.57 / 7.45         4.61
  //   warning  sáng    #925E06  5.08 / 4.65         5.29
  //   warning  tối     #F6AA28  6.95 / 7.89         4.62
  //   error    sáng    #CC1111  5.03 / 4.60         5.25
  //   error    tối     #F26464  4.79 / 5.34         4.61
  //   gold     sáng    #846200  5.03 / 4.60         (không có goldSubtle)
  //   gold     tối     #BA8B00  4.66 / 5.25         (không có goldSubtle)
  //
  // LƯU Ý: NỀN vẫn lấy từ tông GỐC (`success.withValues(alpha: 0.1)`) hoặc từ
  // `*Subtle(brightness)`, không lấy từ token này. Đổi cả nền sẽ làm badge
  // đổi sắc; ở đây chỉ chữ/icon đổi.
  // ========================================================================

  static const Color successOnTintLight = Color(0xFF0A7753);
  static const Color successOnTintDark = Color(0xFF12CB8D);

  static const Color warningOnTintLight = Color(0xFF925E06);
  static const Color warningOnTintDark = Color(0xFFF6AA28);

  static const Color errorOnTintLight = Color(0xFFCC1111);
  static const Color errorOnTintDark = Color(0xFFF26464);

  static const Color goldOnTintLight = Color(0xFF846200);
  static const Color goldOnTintDark = Color(0xFFBA8B00);

  // ========================================================================
  // ĐỘ KHÓ — tông riêng cho mức "expert"
  //
  // easy/medium/hard đã có success/warning/error. Mức expert trước đây là
  // hằng tím thô #8B5CF6; nó phải đi, nhưng KHÔNG được gộp vào `primary`:
  // chế độ tối primary là #34A97C, lệch đúng 3° hue so với success #10B981
  // nên bài dễ nhất và bài khó nhất trông y hệt nhau.
  // ========================================================================

  static const Color lightDifficultyExpert = Color(0xFF6D4AA6);
  static const Color darkDifficultyExpert = Color(0xFFB49BE0);

  // ========================================================================
  // SPECIAL COLORS
  // ========================================================================

  // Gold - Achievements, Premium
  //
  // Trước là #F59E0B — TRÙNG TUYỆT ĐỐI với `warning`, và `goldLight` cũng
  // trùng tuyệt đối với `warningLight` (#FBBF24). Hai token, hai nghĩa
  // ("cẩn thận" và "thành tựu/cao cấp"), một mã màu: màn nào dùng cả hai
  // trong một khung nhìn thì người dùng không thể phân biệt, mà lint cũng
  // không kêu vì về mặt kiểu dữ liệu chúng là hai hằng hợp lệ.
  //
  // Không gộp vào `warning`: đọc các điểm dùng thật thì gold đang gánh
  // "Mẹo từ pro", "Mục tiêu Level", "AI Coach gợi ý", tile cao cấp, trận
  // chung kết. Không chỗ nào mang nghĩa cảnh báo — tô chúng thành `warning`
  // sẽ biến một gợi ý huấn luyện thành một lời cảnh báo.
  //
  // Giữ hue vàng (45°) nhưng hạ hẳn độ sáng (L 50% -> 33%) và đẩy bão hoà
  // lên tối đa: ra vàng huy chương sâu thay vì hổ phách chói. Tách khỏi
  // `warning` dE2000 = 17.4 và khỏi `streak` #F97316 dE2000 = 23.2 — cả hai
  // đều vượt xa ngưỡng ~10 của "khác màu rõ ràng".
  //
  // Chọn đúng L=33% còn vì một lý do thực dụng: 49 màn CHƯA di trú vẫn tô
  // thẳng `AppColors.gold` vào icon. Ở giá trị này nó đạt 3:1 trên nền 10%
  // của chính nó ở CẢ HAI chế độ (3.41/3.12 sáng, 3.78/4.26 tối) — bản cũ
  // chỉ được 1.99/1.82. Nút đặc chữ trắng trong coach/ cũng lên 2.10 -> 3.82.
  static const Color gold = Color(0xFFA67C00);

  /// Bậc nhạt hơn của [gold], cùng tia HSL, +6 điểm L — đúng quan hệ mà
  /// `warningLight` có với `warning`. Phải đi kèm [gold] chứ không đứng yên:
  /// để nguyên #FBBF24 thì nó vẫn là bản sao của `warningLight`.
  static const Color goldLight = Color(0xFFC79500);

  /// Huy chương bạc — bậc 2 của bục vinh danh.
  ///
  /// Không dùng `Colors.grey.shade400` (#BDBDBD): quá sáng để mang chữ
  /// `onPrimary` ở chế độ sáng, và nó nằm đúng dải xám mà `border` và
  /// `textTertiary` đang chiếm, nên khối bục sẽ đọc ra như một ô bị vô hiệu
  /// hoá chứ không phải một thứ hạng.
  static const Color silver = Color(0xFF6E7276);

  /// Huy chương đồng — bậc 3.
  ///
  /// Không dùng `Colors.brown.shade300` (#A1887F) vì cùng lý do độ sáng, và
  /// vì sắc nâu xám của nó đọc ra "bẩn" cạnh nền kem #F7F4EC.
  ///
  /// Đẩy về phía đỏ (hue 24°) có chủ đích: ở hue nâu tự nhiên ~30° nó chỉ
  /// cách `gold` 45° đúng 15 độ — dưới sàn 20° mà hệ này dùng để hai tông
  /// cạnh nhau còn phân biệt được. Vàng và đồng là cùng họ kim loại ấm nên
  /// đây là cặp dễ trùng nhất của bục vinh danh.
  static const Color bronze = Color(0xFFB15D25);

  /// Bản đọc được của [silver] và [bronze] khi chúng làm CHỮ trên nền 10% của
  /// chính mình — chiều thứ hai mà lô 3a từng bỏ sót.
  static const Color silverOnTintLight = Color(0xFF585C60);
  static const Color silverOnTintDark = Color(0xFFAFB4B9);
  static const Color bronzeOnTintLight = Color(0xFF7A4E24);
  static const Color bronzeOnTintDark = Color(0xFFCE9A63);

  // ========================================================================
  // MÀU MINH HOẠ BÀN BI-A
  // ========================================================================
  //
  // KHÔNG đổi theo Brightness, và đó là chủ đích. Đây là màu của VẬT THỂ được
  // vẽ lại — mặt nỉ, băng, lỗ, bi — chứ không phải màu giao diện. Một bàn bi-a
  // xanh ở cả chế độ sáng lẫn tối; tô nó theo theme thì nó thôi là bàn bi-a.
  //
  // Chúng tồn tại thành token chỉ để `_HeatMapPainter` không phải nhúng hằng
  // hex thô — cùng lý do `gold` là hằng chứ không phải cặp light/dark.

  /// Mặt nỉ bàn.
  static const Color tableFelt = Color(0xFF0E5C3B);

  /// Băng bàn, sáng hơn mặt nỉ một bậc.
  static const Color tableRail = Color(0xFF1E7E55);

  /// Lỗ và nét viền bàn.
  static const Color tableLine = Color(0xFF000000);

  /// Bi cái.
  static const Color ballCue = Color(0xFFFFFFFF);

  /// Bi mục tiêu.
  static const Color ballObject = Color(0xFFFFEB3B);

  /// Đường đánh trượt trên heat map.
  static const Color shotMiss = Color(0xFFFF5252);

  // Streak - Day streaks, Fire
  static const Color streak = Color(0xFFF97316);
  static const Color streakLight = Color(0xFFFB923C);

  // ========================================================================
  // SHADOW COLORS
  // ========================================================================

  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x4D000000);

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Returns appropriate colors based on brightness
  static Color background(Brightness brightness) =>
      brightness == Brightness.light ? lightBackground : darkBackground;

  static Color surface(Brightness brightness) =>
      brightness == Brightness.light ? lightSurface : darkSurface;

  static Color surfaceElevated(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceElevated : darkSurfaceElevated;

  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.light ? lightTextPrimary : darkTextPrimary;

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.light ? lightTextSecondary : darkTextSecondary;

  static Color textTertiary(Brightness brightness) =>
      brightness == Brightness.light ? lightTextTertiary : darkTextTertiary;

  static Color border(Brightness brightness) =>
      brightness == Brightness.light ? lightBorder : darkBorder;

  static Color borderSubtle(Brightness brightness) =>
      brightness == Brightness.light ? lightBorderSubtle : darkBorderSubtle;

  static Color accentColor(Brightness brightness) =>
      brightness == Brightness.light ? accent : accentLight;

  static Color accentSubtle(Brightness brightness) =>
      brightness == Brightness.light ? accentSubtleLight : accentSubtleDark;

  /// Màu chữ/icon đặt TRÊN nền [primary].
  ///
  /// Đảo chiều theo chế độ, không phải lúc nào cũng trắng: chế độ tối primary
  /// là #34A97C (xanh sáng) nên chữ trắng chỉ đạt ~2.5:1 — không đọc được.
  static Color onPrimary(Brightness brightness) =>
      brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF08201A);

  /// Nền dịu cho hộp lỗi / cảnh báo / thành công.
  ///
  /// Có accessor riêng vì màn hình nào cũng cần, và trước đây mỗi màn tự
  /// hardcode bản sáng — dark mode ra nền trắng chói trên nền than.
  static Color errorSubtle(Brightness brightness) =>
      brightness == Brightness.light ? errorSubtleLight : errorSubtleDark;

  static Color warningSubtle(Brightness brightness) =>
      brightness == Brightness.light ? warningSubtleLight : warningSubtleDark;

  static Color successSubtle(Brightness brightness) =>
      brightness == Brightness.light ? successSubtleLight : successSubtleDark;

  /// Màu chữ/icon đặt TRÊN nền dịu cùng tông `success` — cả nền 10%
  /// (`success.withValues(alpha: 0.1)`) lẫn `successSubtle(brightness)`.
  static Color successOnTint(Brightness brightness) =>
      brightness == Brightness.light
          ? successOnTintLight
          : successOnTintDark;

  /// Màu chữ/icon đặt TRÊN nền dịu cùng tông `warning` — cả nền 10%
  /// (`warning.withValues(alpha: 0.1)`) lẫn `warningSubtle(brightness)`.
  static Color warningOnTint(Brightness brightness) =>
      brightness == Brightness.light
          ? warningOnTintLight
          : warningOnTintDark;

  /// Màu chữ/icon đặt TRÊN nền dịu cùng tông `error` — cả nền 10%
  /// (`error.withValues(alpha: 0.1)`) lẫn `errorSubtle(brightness)`.
  static Color errorOnTint(Brightness brightness) =>
      brightness == Brightness.light ? errorOnTintLight : errorOnTintDark;

  /// Màu chữ/icon đặt TRÊN nền 10% của chính tông `gold`.
  ///
  /// Không có `goldSubtle` nên token này chỉ phục vụ nền 10%.
  static Color goldOnTint(Brightness brightness) =>
      brightness == Brightness.light ? goldOnTintLight : goldOnTintDark;

  /// Màu chữ/icon đặt TRÊN nền 10% của tông [silver].
  static Color silverOnTint(Brightness brightness) =>
      brightness == Brightness.light ? silverOnTintLight : silverOnTintDark;

  /// Màu chữ/icon đặt TRÊN nền 10% của tông [bronze].
  static Color bronzeOnTint(Brightness brightness) =>
      brightness == Brightness.light ? bronzeOnTintLight : bronzeOnTintDark;

  static Color primary(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimary : darkPrimary;

  static Color primaryDeep(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimaryDeep : darkPrimaryDeep;

  static Color primaryContainer(Brightness brightness) =>
      brightness == Brightness.light
          ? lightPrimaryContainer
          : darkPrimaryContainer;

  static Color accentLabel(Brightness brightness) =>
      brightness == Brightness.light ? lightAccentLabel : darkAccentLabel;

  static Color surfaceRecessed(Brightness brightness) =>
      brightness == Brightness.light
          ? lightSurfaceRecessed
          : darkSurfaceRecessed;

  /// Tông của mức độ khó "expert".
  ///
  /// Tách khỏi `primary` có chủ đích: dùng chung sẽ làm expert trùng màu với
  /// easy (`success`) ở chế độ tối. Tím giữ khoảng cách hue ≥ 97° với cả ba
  /// tông độ khó còn lại.
  static Color difficultyExpert(Brightness brightness) =>
      brightness == Brightness.light
          ? lightDifficultyExpert
          : darkDifficultyExpert;

  /// Tông pastel thứ [index], lặn vòng khi vượt quá 5.
  static Color pastelFor(int index, Brightness brightness) {
    final palette = brightness == Brightness.light ? pastelLight : pastelDark;
    return palette[index % palette.length];
  }
}
