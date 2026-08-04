/// Equipment model — restored from Pool OS V1.
///
/// V1 fields (Cue model) are preserved verbatim. V2-only fields such as
/// pricing and usage tracking are added without simplifying V1 behaviour.
///
/// Fields → V1 source:
///   - shaftMaterial, shaftDiameter, tipBrand, tipHardness, tipSize,
///     cueType, weight, balance, joint, isActive, isBreakCue  — V1 `Cue`
///
/// Extensions on top of V1:
///   - model, category, purchaseDate, purchasePrice, currentValue,
///     condition, usageHours, lastTipChange, notes, imageUrls,
///     isArchived, brandOther, modelOther  — V2 player requirements
class Equipment {
  // -- Identity -----------------------------------------------------------
  final String id;
  final String? playerId;
  final String name;

  // -- Classification ---------------------------------------------------
  /// Category discriminator. V2 had: cue, shaft, tip, accessory.
  /// V2-restored: cue, shaft, tip, chalk, glove, extension, case, accessory.
  final String category;

  /// Cue-type, only meaningful when [category] == 'cue'.
  /// One of: playing / break / jump / break_jump.
  final String? cueType;

  // -- Brand / Model -----------------------------------------------------
  final String? brand;
  final String? brandOther;
  final String? model;
  final String? modelOther;

  // -- Shaft (cue) -------------------------------------------------------
  final String? shaftMaterial;
  final double? shaftDiameter; // mm

  // -- Tip (cue / shaft) -----------------------------------------------
  final String? tipBrand;
  final double? tipDiameter; // mm
  final String? tipHardness;
  final DateTime? lastTipChange;

  // -- Butt / Body -------------------------------------------------------
  final double? weight; // oz
  final String? balance; // Center / Forward / Rear
  final String? joint;
  final String? wrap; // Irish Linen / Leather / ...
  final String? ferrule;

  // -- Extensions --------------------------------------------------------
  final String? extension; // length e.g. "10in"
  final String? cueCase; // brand/model of the case
  final String? chalk; // brand
  final String? glove;
  final List<String> accessories;

  // -- Purchase / Value -------------------------------------------------
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final double? currentValue;
  final String? condition;

  // -- Usage / Maintenance -----------------------------------------------
  final double? usageHours;
  final bool isActive; // currently in use as PLAYING cue
  final bool isBreakCue; // currently active for BREAK role
  final bool isJumpCue; // currently active for JUMP role
  final bool isArchived;
  final List<MaintenanceEntry> maintenanceHistory;

  // -- Free-form ---------------------------------------------------------
  final List<String> imageUrls;
  final String? notes;

  // -- Audit ------------------------------------------------------------
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipment({
    required this.id,
    this.playerId,
    required this.name,
    required this.category,
    this.cueType,
    this.brand,
    this.brandOther,
    this.model,
    this.modelOther,
    this.shaftMaterial,
    this.shaftDiameter,
    this.tipBrand,
    this.tipDiameter,
    this.tipHardness,
    this.lastTipChange,
    this.weight,
    this.balance,
    this.joint,
    this.wrap,
    this.ferrule,
    this.extension,
    this.cueCase,
    this.chalk,
    this.glove,
    this.accessories = const [],
    this.purchaseDate,
    this.purchasePrice,
    this.currentValue,
    this.condition,
    this.usageHours,
    this.isActive = false,
    this.isBreakCue = false,
    this.isJumpCue = false,
    this.isArchived = false,
    this.maintenanceHistory = const [],
    this.imageUrls = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Mirror of V1's `cue.shaft` computed getter.
  String get shaftLabel {
    final m = shaftMaterial ?? '';
    final d = shaftDiameter;
    if (m.isEmpty && d == null) return '';
    if (d == null) return m;
    return '$m ${d.toStringAsFixed(d.truncateToDouble() == d ? 0 : 2)}mm';
  }

  /// Mirror of V1's `cue.tip` computed getter.
  String get tipLabel {
    final b = tipBrand ?? '';
    final h = tipHardness ?? '';
    if (b.isEmpty && h.isEmpty) return '';
    if (h.isEmpty) return b;
    return '$b $h';
  }

  /// Effective brand label, taking into account `brandOther`.
  String get brandLabel {
    if (brand == 'Other') return brandOther ?? 'Other';
    return brand ?? '';
  }

  /// Effective model label, taking into account `modelOther`.
  String get modelLabel {
    if (model == 'Other') return modelOther ?? 'Other';
    return model ?? '';
  }

  Equipment copyWith({
    String? id,
    String? playerId,
    String? name,
    String? category,
    String? cueType,
    String? brand,
    String? brandOther,
    String? model,
    String? modelOther,
    String? shaftMaterial,
    double? shaftDiameter,
    String? tipBrand,
    double? tipDiameter,
    String? tipHardness,
    DateTime? lastTipChange,
    double? weight,
    String? balance,
    String? joint,
    String? wrap,
    String? ferrule,
    String? extension,
    String? cueCase,
    String? chalk,
    String? glove,
    List<String>? accessories,
    DateTime? purchaseDate,
    double? purchasePrice,
    double? currentValue,
    String? condition,
    double? usageHours,
    bool? isActive,
    bool? isBreakCue,
    bool? isJumpCue,
    bool? isArchived,
    List<MaintenanceEntry>? maintenanceHistory,
    List<String>? imageUrls,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      category: category ?? this.category,
      cueType: cueType ?? this.cueType,
      brand: brand ?? this.brand,
      brandOther: brandOther ?? this.brandOther,
      model: model ?? this.model,
      modelOther: modelOther ?? this.modelOther,
      shaftMaterial: shaftMaterial ?? this.shaftMaterial,
      shaftDiameter: shaftDiameter ?? this.shaftDiameter,
      tipBrand: tipBrand ?? this.tipBrand,
      tipDiameter: tipDiameter ?? this.tipDiameter,
      tipHardness: tipHardness ?? this.tipHardness,
      lastTipChange: lastTipChange ?? this.lastTipChange,
      weight: weight ?? this.weight,
      balance: balance ?? this.balance,
      joint: joint ?? this.joint,
      wrap: wrap ?? this.wrap,
      ferrule: ferrule ?? this.ferrule,
      extension: extension ?? this.extension,
      cueCase: cueCase ?? this.cueCase,
      chalk: chalk ?? this.chalk,
      glove: glove ?? this.glove,
      accessories: accessories ?? this.accessories,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      condition: condition ?? this.condition,
      usageHours: usageHours ?? this.usageHours,
      isActive: isActive ?? this.isActive,
      isBreakCue: isBreakCue ?? this.isBreakCue,
      isJumpCue: isJumpCue ?? this.isJumpCue,
      isArchived: isArchived ?? this.isArchived,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      imageUrls: imageUrls ?? this.imageUrls,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'name': name,
        'category': category,
        'cueType': cueType,
        'brand': brand,
        'brandOther': brandOther,
        'model': model,
        'modelOther': modelOther,
        'shaftMaterial': shaftMaterial,
        'shaftDiameter': shaftDiameter,
        'tipBrand': tipBrand,
        'tipDiameter': tipDiameter,
        'tipHardness': tipHardness,
        'lastTipChange': lastTipChange?.toIso8601String(),
        'weight': weight,
        'balance': balance,
        'joint': joint,
        'wrap': wrap,
        'ferrule': ferrule,
        'extension': extension,
        'cueCase': cueCase,
        'chalk': chalk,
        'glove': glove,
        'accessories': accessories,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'purchasePrice': purchasePrice,
        'currentValue': currentValue,
        'condition': condition,
        'usageHours': usageHours,
        'isActive': isActive,
        'isBreakCue': isBreakCue,
        'isJumpCue': isJumpCue,
        'isArchived': isArchived,
        'maintenanceHistory': maintenanceHistory.map((m) => m.toJson()).toList(),
        'imageUrls': imageUrls,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: json['id'] as String,
        playerId: json['playerId'] as String?,
        name: json['name'] as String,
        category: json['category'] as String? ?? 'accessory',
        cueType: json['cueType'] as String?,
        brand: json['brand'] as String?,
        brandOther: json['brandOther'] as String?,
        model: json['model'] as String?,
        modelOther: json['modelOther'] as String?,
        shaftMaterial: json['shaftMaterial'] as String?,
        shaftDiameter: (json['shaftDiameter'] as num?)?.toDouble(),
        tipBrand: json['tipBrand'] as String?,
        tipDiameter: (json['tipDiameter'] as num?)?.toDouble(),
        tipHardness: json['tipHardness'] as String?,
        lastTipChange: json['lastTipChange'] != null
            ? DateTime.parse(json['lastTipChange'] as String)
            : null,
        weight: (json['weight'] as num?)?.toDouble(),
        balance: json['balance'] as String?,
        joint: json['joint'] as String?,
        wrap: json['wrap'] as String?,
        ferrule: json['ferrule'] as String?,
        extension: json['extension'] as String?,
        cueCase: json['cueCase'] as String?,
        chalk: json['chalk'] as String?,
        glove: json['glove'] as String?,
        accessories: (json['accessories'] as List?)?.cast<String>() ?? const [],
        purchaseDate: json['purchaseDate'] != null
            ? DateTime.parse(json['purchaseDate'] as String)
            : null,
        purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
        currentValue: (json['currentValue'] as num?)?.toDouble(),
        condition: json['condition'] as String?,
        usageHours: (json['usageHours'] as num?)?.toDouble(),
        isActive: json['isActive'] as bool? ?? false,
        isBreakCue: json['isBreakCue'] as bool? ?? false,
        isJumpCue: json['isJumpCue'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        maintenanceHistory: (json['maintenanceHistory'] as List?)
                ?.map((e) => MaintenanceEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        imageUrls:
            (json['imageUrls'] as List?)?.cast<String>() ?? const [],
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );
}

/// Append-only maintenance log entry.
class MaintenanceEntry {
  final String id;
  final DateTime date;
  final String type; // tip_change, rewrap, shaft_replacement, cleaning, other
  final String description;
  final double? cost;
  final String? performedBy;

  const MaintenanceEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    this.cost,
    this.performedBy,
  });

  MaintenanceEntry copyWith({
    String? id,
    DateTime? date,
    String? type,
    String? description,
    double? cost,
    String? performedBy,
  }) =>
      MaintenanceEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        type: type ?? this.type,
        description: description ?? this.description,
        cost: cost ?? this.cost,
        performedBy: performedBy ?? this.performedBy,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type,
        'description': description,
        'cost': cost,
        'performedBy': performedBy,
      };

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) =>
      MaintenanceEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        type: json['type'] as String,
        description: json['description'] as String,
        cost: (json['cost'] as num?)?.toDouble(),
        performedBy: json['performedBy'] as String?,
      );
}

/// Aggregate per-cue stats (used by Equipment Statistics Screen).
class EquipmentStats {
  final String cueId;
  final int matchCount;
  final int wins;
  final int losses;
  final int racks;
  final double averageAccuracy;
  final double averageBreakSpeed;
  final double usageHours;
  final DateTime? lastUsed;

  const EquipmentStats({
    required this.cueId,
    required this.matchCount,
    required this.wins,
    required this.losses,
    required this.racks,
    required this.averageAccuracy,
    required this.averageBreakSpeed,
    required this.usageHours,
    this.lastUsed,
  });

  double get winRate => matchCount == 0 ? 0 : wins / matchCount;
}
