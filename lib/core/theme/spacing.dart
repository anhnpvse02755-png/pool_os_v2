/// PoolOS Design System - Spacing Scale
/// Based on 4px base unit
class AppSpacing {
  AppSpacing._();

  /// Micro spacing - icon padding, tiny gaps
  static const double space1 = 4.0;

  /// Tight spacing - element internal padding
  static const double space2 = 8.0;

  /// Compact spacing - list item padding
  static const double space3 = 12.0;

  /// Standard spacing - section padding, standard gaps
  static const double space4 = 16.0;

  /// Comfortable spacing - comfortable padding
  static const double space5 = 20.0;

  /// Section spacing - section margins
  static const double space6 = 24.0;

  /// Large spacing - large section gaps
  static const double space8 = 32.0;

  /// Hero spacing - hero margins, page padding
  static const double space12 = 48.0;

  /// Display spacing - empty states, major separations
  static const double space16 = 64.0;

  // ========================================================================
  // BORDER RADIUS
  // ========================================================================

  /// Small radius - buttons, inputs
  static const double radiusSm = 6.0;

  /// Medium radius - cards, modals
  static const double radiusMd = 8.0;

  /// Large radius - large cards, sheets
  static const double radiusLg = 12.0;

  /// Full radius - pills, avatars
  static const double radiusFull = 9999.0;

  // ========================================================================
  // ALIASES (convenience shortcuts)
  // ========================================================================

  /// xs = 4px
  static const double xs = space1;
  /// sm = 8px
  static const double sm = space2;
  /// md = 12px
  static const double md = space3;
  /// lg = 16px
  static const double lg = space4;
  /// xl = 20px
  static const double xl = space5;
  /// xxl = 24px
  static const double xxl = space6;
}
