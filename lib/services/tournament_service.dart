import 'dart:math';
import '../models/tournament.dart';
import 'package:uuid/uuid.dart';

class TournamentService {
  final _uuid = const Uuid();

  /// Generate pairings for Swiss tournament
  List<Match> generateSwissPairings(
    Tournament tournament,
    int roundNumber,
    List<TournamentStanding> standings,
    List<Match> previousMatches,
  ) {
    final participants = tournament.participantIds;
    final matches = <Match>[];

    if (roundNumber == 1) {
      // First round: random pairing
      final shuffled = List<String>.from(participants)..shuffle();
      return _pairPlayers(tournament.id, roundNumber, shuffled);
    }

    // Sort by wins, then by total points (tiebreaker)
    standings.sort((a, b) {
      final winsCompare = b.matchWins.compareTo(a.matchWins);
      if (winsCompare != 0) return winsCompare;
      return b.totalPoints.compareTo(a.totalPoints);
    });

    final paired = <String>{};
    final playersInOrder = standings.map((s) => s.playerId).toList();

    for (var i = 0; i < playersInOrder.length; i++) {
      if (paired.contains(playersInOrder[i])) continue;

      final player1 = playersInOrder[i];
      String? player2;

      // Try to find an opponent they haven't played yet
      for (var j = i + 1; j < playersInOrder.length; j++) {
        final candidate = playersInOrder[j];
        if (paired.contains(candidate)) continue;

        // Check if they've played before
        final hasPlayed = previousMatches.any((m) =>
            (m.player1Id == player1 && m.player2Id == candidate) ||
            (m.player1Id == candidate && m.player2Id == player1));

        if (!hasPlayed) {
          player2 = candidate;
          break;
        }
      }

      // If no unplayed opponent found, pair with closest ranked available
      if (player2 == null) {
        for (var j = i + 1; j < playersInOrder.length; j++) {
          if (!paired.contains(playersInOrder[j])) {
            player2 = playersInOrder[j];
            break;
          }
        }
      }

      if (player2 != null) {
        paired.add(player1);
        paired.add(player2);

        matches.add(Match(
          id: _uuid.v4(),
          tournamentId: tournament.id,
          roundNumber: roundNumber,
          player1Id: player1,
          player2Id: player2,
        ));
      } else {
        // Bye for odd number of players
        matches.add(Match(
          id: _uuid.v4(),
          tournamentId: tournament.id,
          roundNumber: roundNumber,
          player1Id: player1,
          player2Id: 'BYE',
          winnerId: player1,
          isCompleted: true,
          isBye: true,
        ));
        paired.add(player1);
      }
    }

    return matches;
  }

  /// Generate all pairings for Round-Robin tournament
  List<Match> generateRoundRobinPairings(Tournament tournament) {
    final participants = tournament.participantIds;
    final matches = <Match>[];
    final n = participants.length;

    if (n < 2) return matches;

    // Round-robin algorithm using circle method
    final players = List<String>.from(participants);
    
    // If odd number of players, add a bye
    if (n % 2 == 1) {
      players.add('BYE');
    }

    final rounds = players.length - 1;
    final matchesPerRound = players.length ~/ 2;

    for (var round = 0; round < rounds; round++) {
      for (var match = 0; match < matchesPerRound; match++) {
        final player1Index = match;
        final player2Index = players.length - 1 - match;

        final player1 = players[player1Index];
        final player2 = players[player2Index];

        // Skip if either player is a bye
        if (player1 == 'BYE') {
          matches.add(Match(
            id: _uuid.v4(),
            tournamentId: tournament.id,
            roundNumber: round + 1,
            player1Id: player2,
            player2Id: 'BYE',
            winnerId: player2,
            isCompleted: true,
            isBye: true,
          ));
        } else if (player2 == 'BYE') {
          matches.add(Match(
            id: _uuid.v4(),
            tournamentId: tournament.id,
            roundNumber: round + 1,
            player1Id: player1,
            player2Id: 'BYE',
            winnerId: player1,
            isCompleted: true,
            isBye: true,
          ));
        } else {
          matches.add(Match(
            id: _uuid.v4(),
            tournamentId: tournament.id,
            roundNumber: round + 1,
            player1Id: player1,
            player2Id: player2,
          ));
        }
      }

      // Rotate players (keep first player fixed)
      if (players.length > 2) {
        final temp = players.removeLast();
        players.insert(1, temp);
      }
    }

    return matches;
  }

  List<Match> _pairPlayers(String tournamentId, int roundNumber, List<String> players) {
    final matches = <Match>[];
    
    for (var i = 0; i < players.length - 1; i += 2) {
      matches.add(Match(
        id: _uuid.v4(),
        tournamentId: tournamentId,
        roundNumber: roundNumber,
        player1Id: players[i],
        player2Id: players[i + 1],
      ));
    }

    // Handle odd number of players (bye)
    if (players.length % 2 == 1) {
      matches.add(Match(
        id: _uuid.v4(),
        tournamentId: tournamentId,
        roundNumber: roundNumber,
        player1Id: players.last,
        player2Id: 'BYE',
        winnerId: players.last,
        isCompleted: true,
        isBye: true,
      ));
    }

    return matches;
  }

  /// Calculate current standings for a tournament
  Map<String, TournamentStanding> calculateStandings(
    List<String> participantIds,
    List<Match> completedMatches,
  ) {
    final standings = <String, TournamentStanding>{};

    // Initialize standings
    for (var playerId in participantIds) {
      standings[playerId] = TournamentStanding(playerId: playerId);
    }

    // Calculate wins, losses, and points
    for (var match in completedMatches) {
      if (!match.isCompleted || match.isBye) continue;

      final player1Standing = standings[match.player1Id]!;
      final player2Standing = standings[match.player2Id]!;

      player1Standing.opponentIds.add(match.player2Id);
      player2Standing.opponentIds.add(match.player1Id);

      if (match.winnerId == match.player1Id) {
        player1Standing.matchWins++;
        player2Standing.matchLosses++;
      } else if (match.winnerId == match.player2Id) {
        player2Standing.matchWins++;
        player1Standing.matchLosses++;
      }

      if (match.player1Score != null) {
        player1Standing.totalPoints += match.player1Score!;
      }
      if (match.player2Score != null) {
        player2Standing.totalPoints += match.player2Score!;
      }
    }

    // Add bye wins
    for (var match in completedMatches) {
      if (match.isBye && match.winnerId != null) {
        standings[match.winnerId]!.matchWins++;
      }
    }

    return standings;
  }

  /// Determine tournament winner
  String? determineTournamentWinner(Map<String, TournamentStanding> standings) {
    if (standings.isEmpty) return null;

    final sortedStandings = standings.values.toList()
      ..sort((a, b) {
        final winsCompare = b.matchWins.compareTo(a.matchWins);
        if (winsCompare != 0) return winsCompare;
        return b.totalPoints.compareTo(a.totalPoints);
      });

    return sortedStandings.first.playerId;
  }

  /// Calculate number of rounds needed for Swiss tournament
  int calculateSwissRounds(int playerCount) {
    if (playerCount <= 2) return 1;
    // Common formula: ceil(log2(playerCount))
    return (log(playerCount) / log(2)).ceil();
  }

  /// Calculate number of rounds for Round-Robin
  int calculateRoundRobinRounds(int playerCount) {
    if (playerCount <= 1) return 0;
    return playerCount % 2 == 0 ? playerCount - 1 : playerCount;
  }
}