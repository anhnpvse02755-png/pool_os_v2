/// Voice note attached to a shot / rack / match.
class VoiceNote {
  final String id;
  final String matchId;
  final String? rackId;
  final String? shotId;
  final String filePath;
  final int durationMs;
  final DateTime recordedAt;

  const VoiceNote({
    required this.id,
    required this.matchId,
    this.rackId,
    this.shotId,
    required this.filePath,
    required this.durationMs,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'rackId': rackId,
        'shotId': shotId,
        'filePath': filePath,
        'durationMs': durationMs,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory VoiceNote.fromJson(Map<String, dynamic> j) => VoiceNote(
        id: j['id'] as String,
        matchId: j['matchId'] as String,
        rackId: j['rackId'] as String?,
        shotId: j['shotId'] as String?,
        filePath: j['filePath'] as String,
        durationMs: j['durationMs'] as int,
        recordedAt: DateTime.parse(j['recordedAt'] as String),
      );
}