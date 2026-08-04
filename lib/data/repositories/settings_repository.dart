/// Settings Repository Interface
/// Abstracts data access for app settings
abstract class SettingsRepository {
  /// Get all settings
  Future<AppSettings> getSettings();

  /// Save settings
  Future<void> saveSettings(AppSettings settings);

  /// Get setting by key
  Future<T?> getSetting<T>(String key);

  /// Save setting
  Future<void> saveSetting<T>(String key, T value);

  /// Reset to defaults
  Future<void> resetToDefaults();
}

/// App Settings Model
class AppSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool hapticEnabled;
  final String language;
  final String theme;
  final bool showStreakReminder;
  final int dailyGoalDrills;

  AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.language = 'vi',
    this.theme = 'light',
    this.showStreakReminder = true,
    this.dailyGoalDrills = 2,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticEnabled,
    String? language,
    String? theme,
    bool? showStreakReminder,
    int? dailyGoalDrills,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      showStreakReminder: showStreakReminder ?? this.showStreakReminder,
      dailyGoalDrills: dailyGoalDrills ?? this.dailyGoalDrills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'hapticEnabled': hapticEnabled,
      'language': language,
      'theme': theme,
      'showStreakReminder': showStreakReminder,
      'dailyGoalDrills': dailyGoalDrills,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      hapticEnabled: json['hapticEnabled'] ?? true,
      language: json['language'] ?? 'vi',
      theme: json['theme'] ?? 'light',
      showStreakReminder: json['showStreakReminder'] ?? true,
      dailyGoalDrills: json['dailyGoalDrills'] ?? 2,
    );
  }
}

/// Equipment Model
class Equipment {
  final String id;
  final String name;
  final EquipmentType type;
  final String? brand;
  final String? model;
  final String? notes;
  final DateTime createdAt;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    this.brand,
    this.model,
    this.notes,
    required this.createdAt,
  });
}

enum EquipmentType {
  cue,
  chalk,
  glove,
  rack,
  table,
  other,
}
