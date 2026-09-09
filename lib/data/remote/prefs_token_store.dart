// ============================================================================
// PREFS TOKEN STORE — giữ phiên đăng nhập qua các lần mở app
// ============================================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'directus_client.dart';

/// [TokenStore] lưu xuống SharedPreferences.
///
/// Giữ trong bộ nhớ một bản sao để [read] không phải chạm đĩa mỗi request —
/// mỗi lời gọi API đều đọc token, mà `_send` gọi [read] cho từng cái.
class PrefsTokenStore implements TokenStore {
  PrefsTokenStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _key = 'directus_session';

  SharedPreferences? _prefs;
  DirectusSession? _cached;
  bool _loaded = false;

  Future<SharedPreferences> get _store async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<DirectusSession?> read() async {
    if (_loaded) return _cached;
    try {
      final raw = (await _store).getString(_key);
      _cached = raw == null
          ? null
          : DirectusSession.fromJson(
              (jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      // Dữ liệu hỏng thì coi như chưa đăng nhập, đừng làm app chết lúc mở.
      _cached = null;
    }
    _loaded = true;
    return _cached;
  }

  @override
  Future<void> write(DirectusSession session) async {
    _cached = session;
    _loaded = true;
    try {
      await (await _store).setString(_key, jsonEncode(session.toJson()));
    } catch (_) {
      // Ghi đĩa hỏng vẫn giữ được phiên trong bộ nhớ cho lần chạy này.
    }
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    try {
      await (await _store).remove(_key);
    } catch (_) {
      // Đã xoá khỏi bộ nhớ; lần mở sau cùng lắm phải đăng nhập lại.
    }
  }
}
