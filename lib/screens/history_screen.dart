import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../models/game.dart';
import '../widgets/hover_text.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, PlayerProvider>(
      builder: (context, gameProvider, playerProvider, child) {
        final games = gameProvider.games;

        return Scaffold(
          appBar: AppBar(
            title: const HoverText('History'),
          ),
          body: games.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 72, color: Colors.white24),
                      SizedBox(height: 12),
                      Text('No game history yet', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final Game game = games[index];
                    final isTournament = game.gameName.startsWith('Tournament:');
                    final winner = game.winnerId != null
                        ? playerProvider.getPlayerById(game.winnerId!)
                        : null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isTournament ? Colors.amber : Colors.grey[700],
                          child: Icon(isTournament ? Icons.emoji_events : Icons.videogame_asset,
                              color: isTournament ? Colors.black : Colors.white),
                        ),
                        title: HoverText(game.gameName),
                        subtitle: HoverText(
                          winner != null ? 'Winner: ${winner.name}' : 'No winner recorded',
                        ),
                        trailing: HoverText(
                          DateFormat('MMM d, yyyy').format(game.dateTime),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        onTap: () {
                          gameProvider.selectGame(game);
                          Navigator.pushNamed(context, '/game-summary');
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
