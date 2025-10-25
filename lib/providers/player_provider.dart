import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class PlayerProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();
  
  List<Player> _players = [];
  bool _isLoading = false;

  List<Player> get players => _players;
  bool get isLoading => _isLoading;

  Future<void> loadPlayers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _players = await _dbHelper.getAllPlayers();
    } catch (e) {
      debugPrint('Error loading players: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPlayer(String name) async {
    final player = Player(
      id: _uuid.v4(),
      name: name,
    );

    await _dbHelper.insertPlayer(player);
    _players.add(player);
    notifyListeners();
  }

  Future<void> updatePlayer(Player player) async {
    await _dbHelper.updatePlayer(player);
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      _players[index] = player;
      notifyListeners();
    }
  }

  Future<void> deletePlayer(String playerId) async {
    await _dbHelper.deletePlayer(playerId);
    _players.removeWhere((p) => p.id == playerId);
    notifyListeners();
  }

  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePlayerStats(String playerId, {
    int? gamesPlayed,
    int? wins,
    int? losses,
    String? favoriteGame,
  }) async {
    final player = getPlayerById(playerId);
    if (player == null) return;

    final updatedPlayer = player.copyWith(
      totalGamesPlayed: gamesPlayed ?? player.totalGamesPlayed,
      totalWins: wins ?? player.totalWins,
      totalLosses: losses ?? player.totalLosses,
      favoriteGame: favoriteGame ?? player.favoriteGame,
    );

    await updatePlayer(updatedPlayer);
  }
}