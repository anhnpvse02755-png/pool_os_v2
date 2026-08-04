/// Environment snapshot for a match.
class MatchEnvironment {
  final String matchId;
  final String? tableBrand;
  final int? tableSize; // 7 | 8 | 9
  final int? clothAgeMonths;
  final String? clothBrand;
  final String? clothSpeed; // 'slow' | 'medium' | 'fast'
  final double? humidityPercent;
  final String? lightingType; // 'direct' | 'diffused' | 'mixed'
  final double? temperatureCelsius;

  const MatchEnvironment({
    required this.matchId,
    this.tableBrand,
    this.tableSize,
    this.clothAgeMonths,
    this.clothBrand,
    this.clothSpeed,
    this.humidityPercent,
    this.lightingType,
    this.temperatureCelsius,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'tableBrand': tableBrand,
        'tableSize': tableSize,
        'clothAgeMonths': clothAgeMonths,
        'clothBrand': clothBrand,
        'clothSpeed': clothSpeed,
        'humidityPercent': humidityPercent,
        'lightingType': lightingType,
        'temperatureCelsius': temperatureCelsius,
      };

  factory MatchEnvironment.fromJson(Map<String, dynamic> j) => MatchEnvironment(
        matchId: j['matchId'] as String,
        tableBrand: j['tableBrand'] as String?,
        tableSize: j['tableSize'] as int?,
        clothAgeMonths: j['clothAgeMonths'] as int?,
        clothBrand: j['clothBrand'] as String?,
        clothSpeed: j['clothSpeed'] as String?,
        humidityPercent: (j['humidityPercent'] as num?)?.toDouble(),
        lightingType: j['lightingType'] as String?,
        temperatureCelsius: (j['temperatureCelsius'] as num?)?.toDouble(),
      );
}