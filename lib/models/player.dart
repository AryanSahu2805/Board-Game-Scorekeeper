class Player {
  final String id;
  String name;
  int totalGamesPlayed;
  int totalWins;
  int totalLosses;
  String? favoriteGame;
  DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.favoriteGame,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get winRate {
    if (totalGamesPlayed == 0) return 0.0;
    return (totalWins / totalGamesPlayed) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'favoriteGame': favoriteGame,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      totalWins: map['totalWins'] ?? 0,
      totalLosses: map['totalLosses'] ?? 0,
      favoriteGame: map['favoriteGame'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Player copyWith({
    String? name,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalLosses,
    String? favoriteGame,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      favoriteGame: favoriteGame ?? this.favoriteGame,
      createdAt: createdAt,
    );
  }
}