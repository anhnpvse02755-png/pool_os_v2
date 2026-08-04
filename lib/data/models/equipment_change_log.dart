/// Single equipment change entry.
class EquipmentChangeLog {
  final String id;
  final String playerId;
  final String equipmentId;
  final String equipmentName;
  final String field; // 'cue', 'shaft', 'tip', 'chalk'
  final String? previousValue;
  final String newValue;
  final DateTime changedAt;
  final String? reason;

  const EquipmentChangeLog({
    required this.id,
    required this.playerId,
    required this.equipmentId,
    required this.equipmentName,
    required this.field,
    this.previousValue,
    required this.newValue,
    required this.changedAt,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'equipmentId': equipmentId,
        'equipmentName': equipmentName,
        'field': field,
        'previousValue': previousValue,
        'newValue': newValue,
        'changedAt': changedAt.toIso8601String(),
        'reason': reason,
      };

  factory EquipmentChangeLog.fromJson(Map<String, dynamic> json) =>
      EquipmentChangeLog(
        id: json['id'] as String,
        playerId: json['playerId'] as String,
        equipmentId: json['equipmentId'] as String,
        equipmentName: json['equipmentName'] as String,
        field: json['field'] as String,
        previousValue: json['previousValue'] as String?,
        newValue: json['newValue'] as String,
        changedAt: DateTime.parse(json['changedAt'] as String),
        reason: json['reason'] as String?,
      );
}