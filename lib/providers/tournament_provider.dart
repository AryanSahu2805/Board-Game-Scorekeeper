import 'package:flutter/foundation.dart';
import '../models/tournament.dart';
import '../models/game.dart';
import 'game_provider.dart';
import '../services/database_helper.dart';
import '../services/tournament_service.dart';
import 'package:uuid/uuid.dart';

class TournamentProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TournamentService _tournamentService = TournamentService();
  final GameProvider? _gameProvider;
  final _uuid = const Uuid();
  TournamentProvider({GameProvider? gameProvider}) : _gameProvider = gameProvider;
  
  List<Tournament> _tournaments = [];
  Tournament? _currentTournament;
  List<Match> _currentMatches = [];
  Map<String, TournamentStanding> _standings = {};
  bool _isLoading = false;

  List<Tournament> get tournaments => _tournaments;
  Tournament? get currentTournament => _currentTournament;
  List<Match> get currentMatches => _currentMatches;
  Map<String, TournamentStanding> get standings => _standings;
  bool get isLoading => _isLoading;

  Future<void> loadTournaments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tournaments = await _dbHelper.getAllTournaments();
    } catch (e) {
      debugPrint('Error loading tournaments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTournament({
    required String name,
    required TournamentFormat format,
    required List<String> participantIds,
  }) async {
    if (participantIds.length < 4) {
      throw Exception('Tournament requires at least 4 participants');
    }

    final tournament = Tournament(
      id: _uuid.v4(),
      name: name,
      format: format,
      participantIds: participantIds,
    );

    await _dbHelper.insertTournament(tournament);
    _tournaments.insert(0, tournament);
    _currentTournament = tournament;

    // Generate initial pairings
    if (format == TournamentFormat.swiss) {
      final initialStandings = participantIds.map((id) => 
        TournamentStanding(playerId: id)
      ).toList();
      
      _currentMatches = _tournamentService.generateSwissPairings(
        tournament,
        1,
        initialStandings,
        [],
      );
    } else {
      _currentMatches = _tournamentService.generateRoundRobinPairings(tournament);
    }

    // Save matches
    for (var match in _currentMatches) {
      await _dbHelper.insertMatch(match);
    }

    _updateStandings();
    notifyListeners();
  }

  Future<void> loadTournament(String tournamentId) async {
    _currentTournament = await _dbHelper.getTournament(tournamentId);
    if (_currentTournament == null) return;

    _currentMatches = await _dbHelper.getMatchesByTournament(tournamentId);
    _updateStandings();
    notifyListeners();
  }

  List<Match> getCurrentRoundMatches() {
    if (_currentTournament == null) return [];
    return _currentMatches
        .where((m) => m.roundNumber == _currentTournament!.currentRound)
        .toList();
  }

  Future<void> recordMatchResult({
    required String matchId,
    required String winnerId,
    required int player1Score,
    required int player2Score,
  }) async {
    final matchIndex = _currentMatches.indexWhere((m) => m.id == matchId);
    if (matchIndex == -1) return;

    final match = _currentMatches[matchIndex];
    match.winnerId = winnerId;
    match.player1Score = player1Score;
    match.player2Score = player2Score;
    match.isCompleted = true;

    await _dbHelper.updateMatch(match);
    _updateStandings();
    notifyListeners();
  }

  bool isRoundComplete() {
    final currentRoundMatches = getCurrentRoundMatches();
    return currentRoundMatches.every((m) => m.isCompleted);
  }

  Future<void> advanceToNextRound() async {
    if (_currentTournament == null || !isRoundComplete()) return;

    _currentTournament!.currentRound++;

    if (_currentTournament!.format == TournamentFormat.swiss) {
      final completedMatches = _currentMatches
          .where((m) => m.roundNumber < _currentTournament!.currentRound)
          .toList();
      
      final maxRounds = _tournamentService.calculateSwissRounds(
        _currentTournament!.participantIds.length
      );

      if (_currentTournament!.currentRound <= maxRounds) {
        final standingsList = _standings.values.toList();
        final newMatches = _tournamentService.generateSwissPairings(
          _currentTournament!,
          _currentTournament!.currentRound,
          standingsList,
          completedMatches,
        );

        for (var match in newMatches) {
          await _dbHelper.insertMatch(match);
        }
        _currentMatches.addAll(newMatches);
      } else {
        await _completeTournament();
      }
    } else {
      // Round-Robin: check if all rounds complete
      final totalRounds = _tournamentService.calculateRoundRobinRounds(
        _currentTournament!.participantIds.length
      );
      
      if (_currentTournament!.currentRound > totalRounds) {
        await _completeTournament();
      }
    }

    await _dbHelper.updateTournament(_currentTournament!);
    notifyListeners();
  }

  Future<void> _completeTournament() async {
    if (_currentTournament == null) return;

    _currentTournament!.status = TournamentStatus.completed;
    _currentTournament!.winnerId = _tournamentService.determineTournamentWinner(_standings);
    
    await _dbHelper.updateTournament(_currentTournament!);
    // Also record the tournament win as a Game so it appears in recent games
    try {
      final winnerId = _currentTournament!.winnerId;
      final gameId = _uuid.v4();
      final finalScores = <String, int>{};
      for (var pid in _currentTournament!.participantIds) {
        finalScores[pid] = pid == winnerId ? 1 : 0;
      }

      final tournamentGame = Game(
        id: gameId,
        gameName: 'Tournament: ${_currentTournament!.name}',
        dateTime: DateTime.now(),
        playerIds: List<String>.from(_currentTournament!.participantIds),
        finalScores: finalScores,
        winnerId: winnerId,
        totalRounds: 0,
        isCompleted: true,
      );

      await _dbHelper.insertGame(tournamentGame);

      // If a GameProvider was injected, refresh its games so UI updates immediately
      if (_gameProvider != null) {
        await _gameProvider!.loadGames();
      }
    } catch (e) {
      debugPrint('Error recording tournament game: $e');
    }
  }

  void _updateStandings() {
    if (_currentTournament == null) return;

    final completedMatches = _currentMatches.where((m) => m.isCompleted).toList();
    _standings = _tournamentService.calculateStandings(
      _currentTournament!.participantIds,
      completedMatches,
    );
  }

  List<MapEntry<String, TournamentStanding>> getSortedStandings() {
    final entries = _standings.entries.toList();
    entries.sort((a, b) {
      final winsCompare = b.value.matchWins.compareTo(a.value.matchWins);
      if (winsCompare != 0) return winsCompare;
      return b.value.totalPoints.compareTo(a.value.totalPoints);
    });
    return entries;
  }

  void clearCurrentTournament() {
    _currentTournament = null;
    _currentMatches = [];
    _standings = {};
    notifyListeners();
  }
}