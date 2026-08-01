import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String playerId;
  final DateTime date;
  final String type; // 'practice' | 'tournament' | 'casual'

  // Pre-Match Context
  final DateTime? arrivalTime;
  final int? warmupDuration;
  final List<String>? warmupDrills;
  final int? warmupScore;

  // Readiness (1-5)
  final int energyLevel;
  final int focusLevel;
  final int confidenceLevel;

  // Post-Match Context
  final String? fatigueLevel;
  final List<String>? fatigueLocations;
  final String? mentalState;
  final int? selfRating;
  final String? keyFactor;

  // Meta
  final int? durationMinutes;
  final String? notes;
  final DateTime createdAt;

  const Session({
    required this.id,
    required this.playerId,
    required this.date,
    required this.type,
    this.arrivalTime,
    this.warmupDuration,
    this.warmupDrills,
    this.warmupScore,
    this.energyLevel = 3,
    this.focusLevel = 3,
    this.confidenceLevel = 3,
    this.fatigueLevel,
    this.fatigueLocations,
    this.mentalState,
    this.selfRating,
    this.keyFactor,
    this.durationMinutes,
    this.notes,
    required this.createdAt,
  });

  Session copyWith({
    String? id,
    String? playerId,
    DateTime? date,
    String? type,
    DateTime? arrivalTime,
    int? warmupDuration,
    List<String>? warmupDrills,
    int? warmupScore,
    int? energyLevel,
    int? focusLevel,
    int? confidenceLevel,
    String? fatigueLevel,
    List<String>? fatigueLocations,
    String? mentalState,
    int? selfRating,
    String? keyFactor,
    int? durationMinutes,
    String? notes,
    DateTime? createdAt,
  }) {
    return Session(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      date: date ?? this.date,
      type: type ?? this.type,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      warmupDuration: warmupDuration ?? this.warmupDuration,
      warmupDrills: warmupDrills ?? this.warmupDrills,
      warmupScore: warmupScore ?? this.warmupScore,
      energyLevel: energyLevel ?? this.energyLevel,
      focusLevel: focusLevel ?? this.focusLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      fatigueLocations: fatigueLocations ?? this.fatigueLocations,
      mentalState: mentalState ?? this.mentalState,
      selfRating: selfRating ?? this.selfRating,
      keyFactor: keyFactor ?? this.keyFactor,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        playerId,
        date,
        type,
        arrivalTime,
        warmupDuration,
        warmupDrills,
        warmupScore,
        energyLevel,
        focusLevel,
        confidenceLevel,
        fatigueLevel,
        fatigueLocations,
        mentalState,
        selfRating,
        keyFactor,
        durationMinutes,
        notes,
        createdAt,
      ];
}
