class Tournament {
  final String id;
  String name;
  final TournamentFormat format;
  final List<String> participantIds;
  int currentRound;
  TournamentStatus status;
  final DateTime createdAt;
  String? winnerId;

  Tournament({
    required this.id,
    required this.name,
    required this.format,
    required this.participantIds,
    this.currentRound = 1,
    this.status = TournamentStatus.active,
    DateTime? createdAt,
    this.winnerId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'format': format.toString(),
      'participantIds': participantIds.join(','),
      'currentRound': currentRound,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'winnerId': winnerId,
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'],
      name: map['name'],
      format: TournamentFormat.values.firstWhere(
        (e) => e.toString() == map['format'],
      ),
      participantIds: (map['participantIds'] as String).split(','),
      currentRound: map['currentRound'],
      status: TournamentStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      winnerId: map['winnerId'],
    );
  }
}

enum TournamentFormat {
  swiss,
  roundRobin,
}

enum TournamentStatus {
  active,
  completed,
}

class Match {
  final String id;
  final String tournamentId;
  final int roundNumber;
  final String player1Id;
  final String player2Id;
  String? winnerId;
  int? player1Score;
  int? player2Score;
  bool isCompleted;
  bool isBye; // For odd number of players

  Match({
    required this.id,
    required this.tournamentId,
    required this.roundNumber,
    required this.player1Id,
    required this.player2Id,
    this.winnerId,
    this.player1Score,
    this.player2Score,
    this.isCompleted = false,
    this.isBye = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'roundNumber': roundNumber,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'winnerId': winnerId,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'isCompleted': isCompleted ? 1 : 0,
      'isBye': isBye ? 1 : 0,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'],
      tournamentId: map['tournamentId'],
      roundNumber: map['roundNumber'],
      player1Id: map['player1Id'],
      player2Id: map['player2Id'],
      winnerId: map['winnerId'],
      player1Score: map['player1Score'],
      player2Score: map['player2Score'],
      isCompleted: map['isCompleted'] == 1,
      isBye: map['isBye'] == 1,
    );
  }
}

class TournamentStanding {
  final String playerId;
  int matchWins;
  int matchLosses;
  int totalPoints;
  List<String> opponentIds;

  TournamentStanding({
    required this.playerId,
    this.matchWins = 0,
    this.matchLosses = 0,
    this.totalPoints = 0,
    List<String>? opponentIds,
  }) : opponentIds = opponentIds ?? [];

  double get winRate {
    final totalMatches = matchWins + matchLosses;
    if (totalMatches == 0) return 0.0;
    return matchWins / totalMatches;
  }
}