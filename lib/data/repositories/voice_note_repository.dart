import 'dart:convert';

import '../datasources/local/local_storage_datasource.dart';
import '../models/voice_note.dart';

abstract class IVoiceNoteRepository {
  Future<List<VoiceNote>> forMatch(String matchId);
  Future<void> save(VoiceNote note);
}

class LocalVoiceNoteRepository implements IVoiceNoteRepository {
  LocalVoiceNoteRepository();
  static const _kKey = 'poolos_v2.voice_notes';

  @override
  Future<List<VoiceNote>> forMatch(String matchId) async {
    final raw = LocalStorageDataSource.prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final all = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(VoiceNote.fromJson)
        .toList();
    return all.where((n) => n.matchId == matchId).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  @override
  Future<void> save(VoiceNote note) async {
    final raw = LocalStorageDataSource.prefs.getString(_kKey);
    final list = (raw == null || raw.isEmpty)
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(note.toJson());
    await LocalStorageDataSource.prefs.setString(_kKey, jsonEncode(list));
  }
}