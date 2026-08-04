/// Tournament Model
class Tournament {
  final String id;
  final String name;
  final String type; // league, local, regional, national
  final String status; // upcoming, in_progress, completed
  final DateTime? startDate;
  final DateTime? endDate;
  final String? venue;
  final int? maxParticipants;
  final List<TournamentParticipant> participants;
  final TournamentBracket? bracket;
  final DateTime createdAt;

  Tournament({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.startDate,
    this.endDate,
    this.venue,
    this.maxParticipants,
    this.participants = const [],
    this.bracket,
    required this.createdAt,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'local',
      status: json['status'] ?? 'upcoming',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      venue: json['venue'],
      maxParticipants: json['max_participants'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'venue': venue,
      'max_participants': maxParticipants,
    };
  }
}

/// Tournament Participant
class TournamentParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final int seed;
  final String status; // registered, active, eliminated, winner
  final int wins;
  final int losses;

  TournamentParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.seed = 0,
    this.status = 'registered',
    this.wins = 0,
    this.losses = 0,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      id: json['id'],
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      seed: json['seed'] ?? 0,
      status: json['status'] ?? 'registered',
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
    );
  }
}

/// Tournament Bracket
class TournamentBracket {
  final List<TournamentRound> rounds;

  TournamentBracket({required this.rounds});

  factory TournamentBracket.fromJson(Map<String, dynamic> json) {
    return TournamentBracket(
      rounds: (json['rounds'] as List<dynamic>?)
              ?.map((e) => TournamentRound.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Tournament Round
class TournamentRound {
  final String name;
  final List<TournamentMatch> matches;

  TournamentRound({
    required this.name,
    required this.matches,
  });

  factory TournamentRound.fromJson(Map<String, dynamic> json) {
    return TournamentRound(
      name: json['name'] ?? '',
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => TournamentMatch.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Tournament Match
class TournamentMatch {
  final String id;
  final int round;
  final int position;
  final TournamentParticipant? player1;
  final TournamentParticipant? player2;
  final int? player1Score;
  final int? player2Score;
  final String? winnerId;
  final String status; // pending, in_progress, completed

  TournamentMatch({
    required this.id,
    required this.round,
    required this.position,
    this.player1,
    this.player2,
    this.player1Score,
    this.player2Score,
    this.winnerId,
    this.status = 'pending',
  });

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      id: json['id'],
      round: json['round'] ?? 1,
      position: json['position'] ?? 0,
      player1: json['player1'] != null
          ? TournamentParticipant.fromJson(json['player1'])
          : null,
      player2: json['player2'] != null
          ? TournamentParticipant.fromJson(json['player2'])
          : null,
      player1Score: json['player1_score'],
      player2Score: json['player2_score'],
      winnerId: json['winner_id'],
      status: json['status'] ?? 'pending',
    );
  }
}

/// Tournament Library - Demo data
class TournamentLibrary {
  static final List<Tournament> tournaments = [
    Tournament(
      id: 'tournament_1',
      name: 'PoolOS Weekly League',
      type: 'league',
      status: 'in_progress',
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      venue: 'PoolOS Arena',
      maxParticipants: 16,
      createdAt: DateTime.now(),
    ),
    Tournament(
      id: 'tournament_2',
      name: 'Local Championship 2026',
      type: 'local',
      status: 'upcoming',
      startDate: DateTime.now().add(const Duration(days: 14)),
      venue: 'City Sports Center',
      maxParticipants: 32,
      createdAt: DateTime.now(),
    ),
    Tournament(
      id: 'tournament_3',
      name: 'Beginner Cup',
      type: 'league',
      status: 'upcoming',
      startDate: DateTime.now().add(const Duration(days: 7)),
      venue: 'Club House',
      maxParticipants: 24,
      createdAt: DateTime.now(),
    ),
  ];

  static Tournament? getTournament(String id) {
    return tournaments.firstWhere(
      (t) => t.id == id,
      orElse: () => tournaments.first,
    );
  }
}
