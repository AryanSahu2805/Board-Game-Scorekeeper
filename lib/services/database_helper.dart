import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/tournament.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('board_game_scorekeeper.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Players table
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        totalGamesPlayed INTEGER DEFAULT 0,
        totalWins INTEGER DEFAULT 0,
        totalLosses INTEGER DEFAULT 0,
        favoriteGame TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Games table
    await db.execute('''
      CREATE TABLE games (
        id TEXT PRIMARY KEY,
        gameName TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        playerIds TEXT NOT NULL,
        finalScores TEXT NOT NULL,
        winnerId TEXT,
        totalRounds INTEGER DEFAULT 0,
        isCompleted INTEGER DEFAULT 0
      )
    ''');

    // Round Scores table
    await db.execute('''
      CREATE TABLE round_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gameId TEXT NOT NULL,
        roundNumber INTEGER NOT NULL,
        playerId TEXT NOT NULL,
        score INTEGER NOT NULL,
        FOREIGN KEY (gameId) REFERENCES games (id) ON DELETE CASCADE,
        FOREIGN KEY (playerId) REFERENCES players (id)
      )
    ''');

    // Tournaments table
    await db.execute('''
      CREATE TABLE tournaments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        format TEXT NOT NULL,
        participantIds TEXT NOT NULL,
        currentRound INTEGER DEFAULT 1,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        winnerId TEXT
      )
    ''');

    // Matches table
    await db.execute('''
      CREATE TABLE matches (
        id TEXT PRIMARY KEY,
        tournamentId TEXT NOT NULL,
        roundNumber INTEGER NOT NULL,
        player1Id TEXT NOT NULL,
        player2Id TEXT NOT NULL,
        winnerId TEXT,
        player1Score INTEGER,
        player2Score INTEGER,
        isCompleted INTEGER DEFAULT 0,
        isBye INTEGER DEFAULT 0,
        FOREIGN KEY (tournamentId) REFERENCES tournaments (id) ON DELETE CASCADE
      )
    ''');
  }

  // Player CRUD operations
  Future<void> insertPlayer(Player player) async {
    final db = await database;
    await db.insert(
      'players',
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('players');
    return List.generate(maps.length, (i) => Player.fromMap(maps[i]));
  }

  Future<Player?> getPlayer(String id) async {
    final db = await database;
    final maps = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Player.fromMap(maps.first);
  }

  Future<void> updatePlayer(Player player) async {
    final db = await database;
    await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> deletePlayer(String id) async {
    final db = await database;
    await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Game CRUD operations
  Future<void> insertGame(Game game) async {
    final db = await database;
    await db.insert(
      'games',
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert round scores
    for (var roundScore in game.roundScores) {
      await db.insert('round_scores', roundScore.toMap());
    }
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'games',
      orderBy: 'dateTime DESC',
    );
    
    final games = <Game>[];
    for (var map in maps) {
      final game = Game.fromMap(map);
      // Load round scores
      final roundScoreMaps = await db.query(
        'round_scores',
        where: 'gameId = ?',
        whereArgs: [game.id],
      );
      game.roundScores.addAll(
        roundScoreMaps.map((m) => RoundScore.fromMap(m)),
      );
      games.add(game);
    }
    
    return games;
  }

  Future<List<Game>> getGamesByPlayer(String playerId) async {
    final db = await database;
    final allGames = await getAllGames();
    return allGames.where((game) => game.playerIds.contains(playerId)).toList();
  }

  Future<void> insertRoundScore(RoundScore roundScore) async {
    final db = await database;
    await db.insert('round_scores', roundScore.toMap());
  }

  // Tournament CRUD operations
  Future<void> insertTournament(Tournament tournament) async {
    final db = await database;
    await db.insert(
      'tournaments',
      tournament.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Tournament>> getAllTournaments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tournaments',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Tournament.fromMap(maps[i]));
  }

  Future<Tournament?> getTournament(String id) async {
    final db = await database;
    final maps = await db.query(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Tournament.fromMap(maps.first);
  }

  Future<void> updateTournament(Tournament tournament) async {
    final db = await database;
    await db.update(
      'tournaments',
      tournament.toMap(),
      where: 'id = ?',
      whereArgs: [tournament.id],
    );
  }

  // Match CRUD operations
  Future<void> insertMatch(Match match) async {
    final db = await database;
    await db.insert(
      'matches',
      match.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Match>> getMatchesByTournament(String tournamentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: 'tournamentId = ?',
      whereArgs: [tournamentId],
      orderBy: 'roundNumber ASC',
    );
    return List.generate(maps.length, (i) => Match.fromMap(maps[i]));
  }

  Future<List<Match>> getMatchesByRound(String tournamentId, int round) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: 'tournamentId = ? AND roundNumber = ?',
      whereArgs: [tournamentId, round],
    );
    return List.generate(maps.length, (i) => Match.fromMap(maps[i]));
  }

  Future<void> updateMatch(Match match) async {
    final db = await database;
    await db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}