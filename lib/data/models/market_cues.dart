// ============================================================================
// Market Cue Database - Vietnam Market
// ============================================================================
// Contains popular cues available in Vietnam market for comparison.
// Brands from Vietnam, Japan, Taiwan, and USA.
// ============================================================================

class MarketCue {
  final String id;
  final String brand;
  final String model;
  final String origin; // Vietnam, Japan, Taiwan, USA
  final String category; // Entry-level, Mid-range, High-end
  final double priceMin; // VND
  final double priceMax; // VND
  final String cueType; // Playing, Break, Jump, Break/Jump
  final String shaft; // Material
  final String tip; // Brand and type
  final double weight; // oz
  final String joint;
  final String wrap;
  final String description;
  final double rating; // 1-5 stars

  const MarketCue({
    required this.id,
    required this.brand,
    required this.model,
    required this.origin,
    required this.category,
    required this.priceMin,
    required this.priceMax,
    required this.cueType,
    required this.shaft,
    required this.tip,
    required this.weight,
    required this.joint,
    required this.wrap,
    required this.description,
    required this.rating,
  });

  String get priceRange => '${_formatPrice(priceMin)} - ${_formatPrice(priceMax)}';

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    }
    return '${(price / 1000).toStringAsFixed(0)}K';
  }
}

class MarketCueDatabase {
  static const List<MarketCue> cues = [
    // ========== VIETNAM CUES ==========
    MarketCue(
      id: 'vn_longcue_1',
      brand: 'Long Cue',
      model: 'LC Pro',
      origin: 'Vietnam',
      category: 'Mid-range',
      priceMin: 3500000,
      priceMax: 5000000,
      cueType: 'Playing',
      shaft: 'Acer wood',
      tip: 'Triangle 9.5mm',
      weight: 19.5,
      joint: 'Uni-loc style',
      wrap: 'Irish Linen',
      description: 'Cơ gỗ tự nhiên phổ biến tại VN, phù hợp beginners đến intermediate.',
      rating: 3.8,
    ),
    MarketCue(
      id: 'vn_vics_1',
      brand: 'VICS',
      model: 'V-2000',
      origin: 'Vietnam',
      category: 'Entry-level',
      priceMin: 1500000,
      priceMax: 2500000,
      cueType: 'Playing',
      shaft: 'Maple wood',
      tip: 'VICS 9.5mm',
      weight: 19.0,
      joint: 'Brass',
      wrap: 'Nylon',
      description: 'Cơ giá rẻ, phù hợp beginners. Độ bền trung bình.',
      rating: 3.2,
    ),
    MarketCue(
      id: 'vn_century_1',
      brand: 'Century',
      model: 'Century Pro',
      origin: 'Vietnam',
      category: 'Mid-range',
      priceMin: 4500000,
      priceMax: 6500000,
      cueType: 'Playing',
      shaft: 'North American Maple',
      tip: 'Kamui Clear 9.5mm',
      weight: 19.5,
      joint: 'Uni-loc',
      wrap: 'Irish Linen',
      description: 'Cơ VN cao cấp với gỗ Bắc Mỹ, joint chuẩn uni-loc.',
      rating: 4.2,
    ),
    MarketCue(
      id: 'vn_ceu_1',
      brand: 'CEU',
      model: 'CEU Champion',
      origin: 'Vietnam',
      category: 'Mid-range',
      priceMin: 4000000,
      priceMax: 6000000,
      cueType: 'Playing',
      shaft: 'Maple wood',
      tip: 'Elk Master 9.5mm',
      weight: 19.5,
      joint: 'Brass',
      wrap: 'Irish Linen',
      description: 'Cơ VN được nhiều player ưa chuộng, cảm giác đánh tốt.',
      rating: 4.0,
    ),
    MarketCue(
      id: 'vn_kachango_1',
      brand: 'Kachango',
      model: 'Kachango Pro',
      origin: 'Vietnam',
      category: 'High-end',
      priceMin: 8000000,
      priceMax: 12000000,
      cueType: 'Playing',
      shaft: 'Premium Maple',
      tip: 'Kamui SS 9.5mm',
      weight: 19.5,
      joint: 'Pilkit Joint',
      wrap: 'Leather',
      description: 'Cơ VN cao cấp, design đẹp, performance tốt.',
      rating: 4.5,
    ),
    MarketCue(
      id: 'vn_tiger_1',
      brand: 'Tiger',
      model: 'Tiger Custom',
      origin: 'Vietnam',
      category: 'High-end',
      priceMin: 10000000,
      priceMax: 15000000,
      cueType: 'Playing',
      shaft: 'High-grade Maple',
      tip: 'Kamui SS 9.5mm',
      weight: 19.0,
      joint: 'Pilkit Pro',
      wrap: 'Leather',
      description: 'Cơ custom VN, được làm thủ công, cảm giác đánh tuyệt vời.',
      rating: 4.7,
    ),

    // ========== JAPAN CUES ==========
    MarketCue(
      id: 'jp_mizuki_1',
      brand: 'Mizuki',
      model: 'Mizuki Custom',
      origin: 'Japan',
      category: 'High-end',
      priceMin: 15000000,
      priceMax: 25000000,
      cueType: 'Playing',
      shaft: 'Japanese White Ash',
      tip: 'Kamui Zero 9.5mm',
      weight: 19.5,
      joint: 'Pilkit Mizuki',
      wrap: 'Leather',
      description: 'Cơ Nhật cao cấp, gỗ ash chất lượng cao, độ chính xác tuyệt đối.',
      rating: 4.8,
    ),
    MarketCue(
      id: 'jp_yamaha_1',
      brand: 'Yamaha',
      model: 'Yamaha Custom',
      origin: 'Japan',
      category: 'High-end',
      priceMin: 18000000,
      priceMax: 30000000,
      cueType: 'Playing',
      shaft: 'Japanese White Ash',
      tip: 'Kamui SS 9.5mm',
      weight: 19.5,
      joint: 'Pilkit Yamaha',
      wrap: 'Leather',
      description: 'Thương hiệu Nhật uy tín, build quality vượt trội.',
      rating: 4.9,
    ),
    MarketCue(
      id: 'jp_tokuyasu_1',
      brand: 'Tokuyasu',
      model: 'Tokuyasu Pro',
      origin: 'Japan',
      category: 'High-end',
      priceMin: 20000000,
      priceMax: 35000000,
      cueType: 'Playing',
      shaft: 'Premium Ash',
      tip: 'Kamui SS 9.5mm',
      weight: 19.5,
      joint: 'Tokuyasu Joint',
      wrap: 'Leather',
      description: 'Cơ Nhật handcrafted, được nhiều pro player sử dụng.',
      rating: 4.9,
    ),

    // ========== TAIWAN CUES ==========
    MarketCue(
      id: 'tw_fury_1',
      brand: 'FURY',
      model: 'Fury Elite',
      origin: 'Taiwan',
      category: 'Mid-range',
      priceMin: 5000000,
      priceMax: 8000000,
      cueType: 'Playing',
      shaft: 'North American Maple',
      tip: 'Tiger Emerald 9.5mm',
      weight: 19.5,
      joint: 'Uni-loc',
      wrap: 'Irish Linen',
      description: 'Thương hiệu Đài Loan nổi tiếng, chất lượng ổn định.',
      rating: 4.3,
    ),
    MarketCue(
      id: 'tw_alpha_1',
      brand: 'Alpha',
      model: 'Alpha Pro',
      origin: 'Taiwan',
      category: 'Mid-range',
      priceMin: 4500000,
      priceMax: 7000000,
      cueType: 'Playing',
      shaft: 'Maple wood',
      tip: 'Elk Master 9.5mm',
      weight: 19.5,
      joint: 'Alpha Joint',
      wrap: 'Irish Linen',
      description: 'Cơ Đài Loan với giá hợp lý, phù hợp intermediate players.',
      rating: 4.1,
    ),
    MarketCue(
      id: 'tw_century_tw_1',
      brand: 'Century',
      model: 'Century GT',
      origin: 'Taiwan',
      category: 'High-end',
      priceMin: 10000000,
      priceMax: 15000000,
      cueType: 'Playing',
      shaft: 'Premium Maple',
      tip: 'Kamui Clear 9.5mm',
      weight: 19.5,
      joint: 'Pilkit',
      wrap: 'Leather',
      description: 'Century Đài Loan, build quality tốt, nhiều pro dùng.',
      rating: 4.5,
    ),

    // ========== USA CUES ==========
    MarketCue(
      id: 'usa_predator_1',
      brand: 'Predator',
      model: 'Predator SP4',
      origin: 'USA',
      category: 'High-end',
      priceMin: 20000000,
      priceMax: 35000000,
      cueType: 'Playing',
      shaft: 'Predator Maple',
      tip: 'Predator 9.5mm',
      weight: 19.5,
      joint: 'Uni-loc',
      wrap: 'Irish Linen',
      description: 'Thương hiệu Mỹ nổi tiếng thế giới, công nghệ carbon fiber.',
      rating: 4.8,
    ),
    MarketCue(
      id: 'usa_mcdaniel_1',
      brand: 'McDaniel',
      model: 'McDaniel Custom',
      origin: 'USA',
      category: 'High-end',
      priceMin: 25000000,
      priceMax: 50000000,
      cueType: 'Playing',
      shaft: 'Premium Ash',
      tip: 'Kamui SS 9.5mm',
      weight: 19.0,
      joint: 'McDaniel Joint',
      wrap: 'Leather',
      description: 'Cơ custom Mỹ handcrafted, độ chính xác cao, pro-level.',
      rating: 4.9,
    ),
    MarketCue(
      id: 'usa_southwest_1',
      brand: 'Southwest',
      model: 'Southwest Pro',
      origin: 'USA',
      category: 'High-end',
      priceMin: 30000000,
      priceMax: 60000000,
      cueType: 'Playing',
      shaft: 'Birds Eye Maple',
      tip: 'Kamui SS 9.5mm',
      weight: 19.0,
      joint: 'Pilkit Pro',
      wrap: 'Leather',
      description: 'Cơ Mỹ cao cấp với design độc đáo, pro tournament standard.',
      rating: 5.0,
    ),
  ];

  static List<MarketCue> getByOrigin(String origin) {
    return cues.where((c) => c.origin == origin).toList();
  }

  static List<MarketCue> getByCategory(String category) {
    return cues.where((c) => c.category == category).toList();
  }

  static List<MarketCue> getByPriceRange(double minPrice, double maxPrice) {
    return cues.where((c) => c.priceMin >= minPrice && c.priceMax <= maxPrice).toList();
  }

  static List<MarketCue> search(String query) {
    final lower = query.toLowerCase();
    return cues.where((c) =>
        c.brand.toLowerCase().contains(lower) ||
        c.model.toLowerCase().contains(lower) ||
        c.description.toLowerCase().contains(lower)).toList();
  }

  static List<String> get origins => ['Vietnam', 'Japan', 'Taiwan', 'USA'];
  static List<String> get categories => ['Entry-level', 'Mid-range', 'High-end'];
}
