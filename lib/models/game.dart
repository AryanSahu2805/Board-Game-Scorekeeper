class Game {
  final String id;
  final String gameName;
  final DateTime dateTime;
  final List<String> playerIds;
  final Map<String, int> finalScores; // playerId -> score
  String? winnerId;
  int totalRounds;
  final List<RoundScore> roundScores;
  bool isCompleted;

  Game({
    required this.id,
    required this.gameName,
    required this.dateTime,
    required this.playerIds,
    required this.finalScores,
    this.winnerId,
    this.totalRounds = 0,
    List<RoundScore>? roundScores,
    this.isCompleted = false,
  }) : roundScores = roundScores ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameName': gameName,
      'dateTime': dateTime.toIso8601String(),
      'playerIds': playerIds.join(','),
      'finalScores': finalScores.entries.map((e) => '${e.key}:${e.value}').join(','),
      'winnerId': winnerId,
      'totalRounds': totalRounds,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    final playerIds = (map['playerIds'] as String).split(',');
    final finalScoresString = map['finalScores'] as String;
    final finalScores = <String, int>{};
    
    if (finalScoresString.isNotEmpty) {
      for (var entry in finalScoresString.split(',')) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          finalScores[parts[0]] = int.parse(parts[1]);
        }
      }
    }

    return Game(
      id: map['id'],
      gameName: map['gameName'],
      dateTime: DateTime.parse(map['dateTime']),
      playerIds: playerIds,
      finalScores: finalScores,
      winnerId: map['winnerId'],
      totalRounds: map['totalRounds'] ?? 0,
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

class RoundScore {
  final String gameId;
  final int roundNumber;
  final String playerId;
  final int score;

  RoundScore({
    required this.gameId,
    required this.roundNumber,
    required this.playerId,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'roundNumber': roundNumber,
      'playerId': playerId,
      'score': score,
    };
  }

  factory RoundScore.fromMap(Map<String, dynamic> map) {
    return RoundScore(
      gameId: map['gameId'],
      roundNumber: map['roundNumber'],
      playerId: map['playerId'],
      score: map['score'],
    );
  }
}