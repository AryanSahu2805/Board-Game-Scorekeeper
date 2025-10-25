import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/player_provider.dart';
import '../providers/game_provider.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import '../widgets/hover_text.dart';

class HomeScreen extends StatefulWidget {
  /// When [embedded] is true the widget will render only the inner content
  /// (no Scaffold / AppBar / BottomNavigationBar). This allows embedding
  /// the Home screen inside a parent (for example a PageView).
  const HomeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // If embedded, only return the inner body so a parent can provide the
    // Scaffold (useful when used inside a PageView).
    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Consumer<PlayerProvider>(
              builder: (context, playerProvider, child) {
                final userName = playerProvider.players.isNotEmpty
                    ? playerProvider.players.first.name
                    : 'Player';
                return HoverText(
                  'Welcome back, $userName',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Show a Continue button when there is an active game or tournament
            Consumer2<GameProvider, TournamentProvider>(
              builder: (context, gameProvider, tournamentProvider, child) {
                final hasActiveGame = gameProvider.currentGame != null && !gameProvider.currentGame!.isCompleted;
                final hasActiveTournament = tournamentProvider.currentTournament != null && tournamentProvider.currentTournament!.status != TournamentStatus.completed;

                if (!hasActiveGame && !hasActiveTournament) return const SizedBox.shrink();

                final label = hasActiveGame
                    ? 'Continue Game'
                    : 'Continue Tournament: ${tournamentProvider.currentTournament!.name}';

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (hasActiveGame) {
                            Navigator.pushNamed(context, '/score-entry');
                          } else {
                            Navigator.pushNamed(context, '/tournament-view');
                          }
                        },
                        child: HoverText(label),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/score-entry'),
                    child: const HoverText('New Game'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/tournament-setup'),
                    child: const HoverText('Create Tournament'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/player-management'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const HoverText('Player Profiles'),
            ),
            const SizedBox(height: 20),
            const HoverText(
              'Recent Games',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer2<GameProvider, PlayerProvider>(
                builder: (context, gameProvider, playerProvider, child) {
                  if (gameProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final recentGames = gameProvider.games.take(10).toList();

                  if (recentGames.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.games_outlined,
                              size: 64, color: Colors.white24),
                          SizedBox(height: 16),
                          HoverText(
                            'No games played yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          HoverText(
                            'Start a new game to get started!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => gameProvider.loadGames(),
                    child: ListView.builder(
                      itemCount: recentGames.length,
                      itemBuilder: (context, index) {
                        final game = recentGames[index];
                        final winner = game.winnerId != null
                            ? playerProvider.getPlayerById(game.winnerId!)
                            : null;
                        
                        final timeAgo = _getTimeAgo(game.dateTime);
                        
                        String subtitle;
                        if (game.isCompleted && winner != null) {
                          final winnerScore = game.finalScores[game.winnerId];
                          subtitle = '${winner.name} won ($winnerScore pts)';
                        } else {
                          subtitle = 'In progress';
                        }

                        return _recentGameTile(
                          game.gameName,
                          subtitle,
                          timeAgo,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );

    if (widget.embedded) return inner;

    return Scaffold(
      appBar: AppBar(
        title: const HoverText('Board Game Scorekeeper'),
      ),
      body: inner,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlayerDialog,
        tooltip: 'Add Player',
        child: const Icon(Icons.person_add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F1114),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/tournament-setup');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Tournaments'),
        ],
      ),
    );
  }

  void _showAddPlayerDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const HoverText('Add Player'),
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
            child: const HoverText('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              await context.read<PlayerProvider>().addPlayer(name);

              if (ctx.mounted) Navigator.pop(ctx);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: HoverText('Player "$name" added')),
                );
              }
            },
            child: const HoverText('Add'),
          ),
        ],
      ),
    );
  }

  Widget _recentGameTile(String title, String subtitle, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: HoverText(title),
        subtitle: HoverText(subtitle),
        trailing: HoverText(
          time,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}