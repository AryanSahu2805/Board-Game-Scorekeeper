import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';

class GameSummaryScreen extends StatelessWidget {
  const GameSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Summary'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<GameProvider, PlayerProvider>(
        builder: (context, gameProvider, playerProvider, child) {
          final game = gameProvider.currentGame;
          
          if (game == null) {
            return const Center(child: Text('No game data available'));
          }

          // Sort players by score
          final sortedPlayers = game.playerIds.toList()
            ..sort((a, b) {
              final scoreA = game.finalScores[a] ?? 0;
              final scoreB = game.finalScores[b] ?? 0;
              return scoreB.compareTo(scoreA);
            });

          final winner = game.winnerId != null
              ? playerProvider.getPlayerById(game.winnerId!)
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Winner Card
                if (winner != null) ...[
                  Card(
                    color: Colors.amber.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Winner!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            winner.name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${game.finalScores[winner.id]} points',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Game Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.gameName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Rounds: ${game.totalRounds}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Final Standings
                const Text(
                  'Final Standings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ...sortedPlayers.asMap().entries.map((entry) {
                  final position = entry.key + 1;
                  final playerId = entry.value;
                  final player = playerProvider.getPlayerById(playerId);
                  final score = game.finalScores[playerId] ?? 0;

                  if (player == null) return const SizedBox();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: position == 1
                            ? Colors.amber
                            : position == 2
                                ? Colors.grey[400]
                                : position == 3
                                    ? Colors.orange[300]
                                    : Colors.grey[700],
                        child: Text(
                          '$position',
                          style: TextStyle(
                            color: position <= 3 ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: position == 1 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Text(
                        '$score pts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: position == 1 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          color: position == 1 
                              ? Colors.amber 
                              : Colors.white70,
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          gameProvider.cancelGame();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                        child: const Text('Home'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          gameProvider.cancelGame();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/score-entry',
                            (route) => false,
                          );
                        },
                        child: const Text('New Game'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}