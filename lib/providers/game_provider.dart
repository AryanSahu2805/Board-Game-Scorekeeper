import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../models/game_template.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class GameProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();
  
  List<Game> _games = [];
  Game? _currentGame;
  GameTemplate? _selectedTemplate;
  bool _isLoading = false;

  List<Game> get games => _games;
  Game? get currentGame => _currentGame;
  GameTemplate? get selectedTemplate => _selectedTemplate;
  bool get isLoading => _isLoading;
  
  List<GameTemplate> get availableTemplates => GameTemplate.getDefaultTemplates();

  Future<void> loadGames() async {
    _isLoading = true;
    notifyListeners();

    try {
      _games = await _dbHelper.getAllGames();
    } catch (e) {
      debugPrint('Error loading games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Game>> getGamesByPlayer(String playerId) async {
    return await _dbHelper.getGamesByPlayer(playerId);
  }

  void selectTemplate(GameTemplate template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void startNewGame(String gameName, List<String> playerIds) {
    final template = _selectedTemplate ?? availableTemplates.first;
    
    final initialScores = <String, int>{};
    for (var playerId in playerIds) {
      initialScores[playerId] = template.startingScore;
    }

    _currentGame = Game(
      id: _uuid.v4(),
      gameName: gameName,
      dateTime: DateTime.now(),
      playerIds: playerIds,
      finalScores: initialScores,
      totalRounds: 0,
    );
    
    notifyListeners();
  }

  void addRoundScores(Map<String, int> roundScores) {
    if (_currentGame == null) return;

    final template = _selectedTemplate ?? availableTemplates.first;
    _currentGame!.totalRounds++;

    // Update final scores based on scoring method
    for (var entry in roundScores.entries) {
      final playerId = entry.key;
      final scoreToAdd = entry.value;

      if (template.scoringMethod == 'cumulative') {
        _currentGame!.finalScores[playerId] = 
            (_currentGame!.finalScores[playerId] ?? 0) + scoreToAdd;
      } else if (template.scoringMethod == 'per_round') {
        _currentGame!.finalScores[playerId] = scoreToAdd;
      } else if (template.scoringMethod == 'first_to_target') {
        _currentGame!.finalScores[playerId] = 
            (_currentGame!.finalScores[playerId] ?? 0) + scoreToAdd;
      }

      // Add round score record
      _currentGame!.roundScores.add(RoundScore(
        gameId: _currentGame!.id,
        roundNumber: _currentGame!.totalRounds,
        playerId: playerId,
        score: scoreToAdd,
      ));
    }

    notifyListeners();
  }

  void undoLastRound() {
    if (_currentGame == null || _currentGame!.totalRounds == 0) return;

    final template = _selectedTemplate ?? availableTemplates.first;
    final lastRound = _currentGame!.totalRounds;
    
    // Remove scores from last round
    final lastRoundScores = _currentGame!.roundScores
        .where((rs) => rs.roundNumber == lastRound)
        .toList();
    
    for (var roundScore in lastRoundScores) {
      if (template.scoringMethod == 'cumulative' || 
          template.scoringMethod == 'first_to_target') {
        _currentGame!.finalScores[roundScore.playerId] = 
            (_currentGame!.finalScores[roundScore.playerId] ?? 0) - roundScore.score;
      }
    }

    _currentGame!.roundScores.removeWhere((rs) => rs.roundNumber == lastRound);
    _currentGame!.totalRounds--;
    
    notifyListeners();
  }

  Future<void> endGame() async {
    if (_currentGame == null) return;

    // Determine winner
    String? winnerId;
    int highestScore = _currentGame!.finalScores.values.isEmpty 
        ? 0 
        : _currentGame!.finalScores.values.reduce((a, b) => a > b ? a : b);
    
    for (var entry in _currentGame!.finalScores.entries) {
      if (entry.value == highestScore) {
        winnerId = entry.key;
        break;
      }
    }

    _currentGame!.winnerId = winnerId;
    _currentGame!.isCompleted = true;

    await _dbHelper.insertGame(_currentGame!);
    _games.insert(0, _currentGame!);
    
    notifyListeners();
  }

  /// Select an existing game to be the current game (e.g. for viewing summary)
  void selectGame(Game game) {
    _currentGame = game;
    notifyListeners();
  }

  void cancelGame() {
    _currentGame = null;
    _selectedTemplate = null;
    notifyListeners();
  }

  bool checkWinCondition() {
    if (_currentGame == null || _selectedTemplate == null) return false;

    if (_selectedTemplate!.scoringMethod == 'first_to_target' && 
        _selectedTemplate!.targetScore != null) {
      return _currentGame!.finalScores.values.any(
        (score) => score >= _selectedTemplate!.targetScore!
      );
    }

    return false;
  }
}