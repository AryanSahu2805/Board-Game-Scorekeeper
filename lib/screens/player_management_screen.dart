import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/hover_text.dart';

class PlayerManagementScreen extends StatelessWidget {
  const PlayerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Management'),
      ),
      body: Consumer2<PlayerProvider, GameProvider>(
        builder: (context, playerProvider, gameProvider, child) {
          if (playerProvider.isLoading || gameProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = playerProvider.players;

          if (players.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'No players yet',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first player to get started',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              // compute stats from games list so tournament games are included
              final playerGames = gameProvider.games.where((g) => g.playerIds.contains(player.id)).toList();
              final gamesCount = playerGames.length;
              final winsCount = playerGames.where((g) => g.winnerId == player.id).length;
              final winRate = gamesCount == 0 ? player.winRate : (winsCount / gamesCount) * 100;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: HoverText(player.name[0].toUpperCase()),
                  ),
                  title: HoverText(player.name),
                  subtitle: HoverText('$gamesCount games • ${winRate.toStringAsFixed(1)}% win rate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/player-profile',
                            arguments: player.id,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _showDeleteDialog(context, player.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/player-profile',
                      arguments: player.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlayerDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Player'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Player name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                return;
              }

              await context.read<PlayerProvider>().addPlayer(
                    nameController.text.trim(),
                  );

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player added')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String playerId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Player'),
        content: const Text(
          'Are you sure you want to delete this player? This will remove all their game history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<PlayerProvider>().deletePlayer(playerId);

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}