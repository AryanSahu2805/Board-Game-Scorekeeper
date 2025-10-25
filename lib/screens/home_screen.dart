import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/player_provider.dart';
import '../providers/game_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Game Scorekeeper'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<PlayerProvider>(
              builder: (context, playerProvider, child) {
                final userName = playerProvider.players.isNotEmpty
                    ? playerProvider.players.first.name
                    : 'Player';
                return Text(
                  'Welcome back, $userName',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/score-entry'),
                    child: const Text('New Game'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/tournament-setup'),
                    child: const Text('Create Tournament'),
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
              child: const Text('Player Profiles'),
            ),
            const SizedBox(height: 20),
            const Text(
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.games_outlined,
                              size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            'No games played yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a new game to get started!',
                            style: TextStyle(
                              color: Colors.white38,
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F1114),
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          
          if (index == 1) {
            // History - could navigate to a history screen
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

  Widget _recentGameTile(String title, String subtitle, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
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