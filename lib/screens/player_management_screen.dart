import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

class PlayerManagementScreen extends StatelessWidget {
  const PlayerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Management'),
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          if (playerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = playerProvider.players;

          if (players.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'No players yet',
                    style: TextStyle(fontSize: 18, color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first player to get started',
                    style: TextStyle(color: Colors.white38),
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
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(player.name[0].toUpperCase()),
                  ),
                  title: Text(player.name),
                  subtitle: Text(
                    '${player.totalGamesPlayed} games • ${player.winRate.toStringAsFixed(1)}% win rate',
                  ),
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