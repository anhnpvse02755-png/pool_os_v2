import '../../data/datasources/local/local_storage_datasource.dart';
import '../../data/repositories/settings_repository.dart';

/// Local Settings Repository Implementation
class LocalSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> getSettings() async {
    final data = await LocalStorageDataSource.getSettings();
    return AppSettings.fromJson(data);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await LocalStorageDataSource.saveSettings(settings.toJson());
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    final settings = await getSettings();
    final json = settings.toJson();
    return json[key] as T?;
  }

  @override
  Future<void> saveSetting<T>(String key, T value) async {
    final settings = await getSettings();
    final json = settings.toJson();
    json[key] = value;
    await LocalStorageDataSource.saveSettings(json);
  }

  @override
  Future<void> resetToDefaults() async {
    await LocalStorageDataSource.saveSettings(AppSettings().toJson());
  }
}
