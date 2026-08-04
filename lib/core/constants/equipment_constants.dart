/// Equipment reference data — restored from Pool OS V1.
///
/// All brand lists, shaft materials, tip hardnesses, joints, balance and
/// cue-type enumerations are sourced from V1 (`features/equipment/domain/
/// models/cue.dart :: CueBrands`). They are encoded here as immutable
/// constants so screens and forms can pick them up without hitting a
/// repository.
class EquipmentConstants {
  EquipmentConstants._();

  // ---------------------------------------------------------------------------
  // Cue categories — V1 has 4 cue types. V2 had collapsed this to type=string.
  // ---------------------------------------------------------------------------
  static const List<String> cueTypes = [
    'playing',
    'break',
    'jump',
    'break_jump',
  ];

  static const Map<String, String> cueTypeLabels = {
    'playing': 'Playing Cue',
    'break': 'Break Cue',
    'jump': 'Jump Cue',
    'break_jump': 'Break + Jump',
  };

  // ---------------------------------------------------------------------------
  // Equipment categories — broader than just cue types. V2 already had these.
  // ---------------------------------------------------------------------------
  static const List<String> equipmentCategories = [
    'cue',
    'shaft',
    'tip',
    'chalk',
    'glove',
    'extension',
    'case',
    'accessory',
  ];

  static const Map<String, String> categoryLabels = {
    'cue': 'Cue',
    'shaft': 'Shaft',
    'tip': 'Tip',
    'chalk': 'Chalk',
    'glove': 'Glove',
    'extension': 'Extension',
    'case': 'Cue Case',
    'accessory': 'Phụ kiện',
  };

  // ---------------------------------------------------------------------------
  // Cue brands — V1 list
  // ---------------------------------------------------------------------------
  static const List<String> cueBrands = [
    'Predator',
    'Mezz',
    'Cuetec',
    'Jacoby',
    'McDermott',
    'Meucci',
    'Schon',
    'Pechauer',
    'Viking',
    'Fury',
    'Poison',
    'Lucasi',
    'Rhino',
    'Becue',
    'Players',
    'OB',
    'Valley',
    'Imperial',
    'Mizerak',
    'Duffy',
    'Schmelke',
    'J. Flowers',
    'Custom',
    'Other',
  ];

  // ---------------------------------------------------------------------------
  // Shaft materials / models — V1 list
  // ---------------------------------------------------------------------------
  static const List<String> shaftMaterials = [
    'Revo',
    'Ignite',
    'Cynergy',
    'WX Sigma',
    'WX Alpha',
    'EX Pro',
    'Z3',
    '314-3',
    'Vantage',
    'Maple',
    'Ash',
    'Oak',
    'Ebony',
    'Birdseye Maple',
    'Carbon Fiber',
    'Fiberglass',
    'Graphite',
  ];

  static const List<double> shaftDiameters = [
    11.75,
    12.0,
    12.25,
    12.5,
    12.75,
    13.0,
  ];

  // ---------------------------------------------------------------------------
  // Tip — V1
  // ---------------------------------------------------------------------------
  static const List<String> tipBrands = [
    'Kamui',
    'Zan',
    'HOW',
    'Navigator',
    'Taom',
    'Moori',
    'Triangle',
    'Tiger',
    'Elk Master',
    'Master',
    'Tempest',
    'Le Pro',
    'Everest',
    'Ultraskin',
    'Thoroughbred',
    'Other',
  ];

  static const List<double> tipDiameters = [
    11.5,
    11.75,
    12.0,
    12.25,
    12.5,
    12.75,
    13.0,
    13.2,
    13.5,
    13.75,
    13.9,
    14.0,
  ];

  static const List<String> tipHardnesses = [
    'Soft',
    'Medium Soft',
    'Medium',
    'Medium Hard',
    'Hard',
    'Extra Hard',
  ];

  // ---------------------------------------------------------------------------
  // Cue body options
  // ---------------------------------------------------------------------------
  static const List<String> balances = [
    'Center',
    'Forward',
    'Rear',
  ];

  static const List<String> joints = [
    '5/16x18',
    '3/8x10',
    'Uni-Loc',
    'Sino',
    'CueTec',
    'Radial',
    'Meier',
    'Custom',
  ];

  static const List<String> wraps = [
    'Irish Linen',
    'Leather',
    'Synthetic',
    'None',
    'Other',
  ];

  static const List<String> ferrules = [
    'Ivorine',
    'Carbon Fiber',
    'Phenolic',
    'Brass',
    'Other',
  ];

  // ---------------------------------------------------------------------------
  // Maintenance / condition
  // ---------------------------------------------------------------------------
  static const List<String> conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Worn',
    'Needs Service',
  ];

  // ---------------------------------------------------------------------------
  // Tip-replacement reminder threshold (days). 6 months = ~183 days.
  // ---------------------------------------------------------------------------
  static const int tipReplacementDays = 183;
  static const int maintenanceReminderDays = 365;
}
