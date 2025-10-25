import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/player_provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/game.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? playerId = ModalRoute.of(context)?.settings.arguments as String?;

    return Consumer2<PlayerProvider, GameProvider>(
      builder: (context, playerProvider, gameProvider, child) {
        final Player? player = playerId != null 
            ? playerProvider.getPlayerById(playerId)
            : playerProvider.players.isNotEmpty 
                ? playerProvider.players.first 
                : null;

        if (player == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Player Profile')),
            body: const Center(child: Text('Player not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Player Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, player),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Player Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Text(
                          player.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Member since ${DateFormat('MMM yyyy').format(player.createdAt)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                Row(
                  children: [
                    _statCard('Games\nPlayed', '${player.totalGamesPlayed}'),
                    const SizedBox(width: 8),
                    _statCard('Wins', '${player.totalWins}'),
                    const SizedBox(width: 8),
                    _statCard('Win Rate', '${player.winRate.toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 16),

                // Favorite Game
                if (player.favoriteGame != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: const Text('Favorite Game'),
                      subtitle: Text(player.favoriteGame!),
                    ),
                  ),
                const SizedBox(height: 16),

                // Recent Games
                FutureBuilder<List<Game>>(
                  future: gameProvider.getGamesByPlayer(player.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.history, size: 48, color: Colors.white24),
                                const SizedBox(height: 8),
                                const Text(
                                  'No game history yet',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final games = snapshot.data!.take(10).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Games',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...games.map((game) {
                          final isWinner = game.winnerId == player.id;
                          final playerScore = game.finalScores[player.id] ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                isWinner ? Icons.emoji_events : Icons.sports_esports,
                                color: isWinner ? Colors.amber : Colors.grey,
                              ),
                              title: Text(game.gameName),
                              subtitle: Text(
                                isWinner
                                    ? 'Won with $playerScore pts'
                                    : 'Lost ($playerScore pts)',
                              ),
                              trailing: Text(
                                DateFormat('MMM d').format(game.dateTime),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Player player) {
    final nameController = TextEditingController(text: player.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Player'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final updatedPlayer = player.copyWith(
                name: nameController.text.trim(),
              );

              await context.read<PlayerProvider>().updatePlayer(updatedPlayer);

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}