import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/hover_text.dart';
import '../services/database_helper.dart';
import '../models/tournament.dart';

class HistoryScreen extends StatelessWidget {
	const HistoryScreen({super.key, this.embedded = false});

	final bool embedded;

	@override
	Widget build(BuildContext context) {
		return Consumer2<GameProvider, PlayerProvider>(
			builder: (context, gameProvider, playerProvider, child) {
				final games = gameProvider.games;

				// show recent games (most-recent first) with refresh
				final recentGames = games.take(10).toList();

				final content = RefreshIndicator(
					onRefresh: () async {
						await gameProvider.loadGames();
						return;
					},
					child: ListView(
						padding: const EdgeInsets.all(16),
						children: [
							const HoverText('Recent Games', style: TextStyle(fontWeight: FontWeight.bold)),
							const SizedBox(height: 8),
							if (recentGames.isEmpty)
								const Card(
									child: Padding(
										padding: EdgeInsets.all(24),
										child: Center(
											child: Column(
												children: [
													Icon(Icons.games_outlined, size: 64, color: Colors.white24),
													SizedBox(height: 16),
													HoverText('No games played yet', style: TextStyle(color: Colors.white, fontSize: 16)),
												],
											),
										),
									),
								)
							else ...recentGames.map((game) {
								final isTournament = game.gameName.startsWith('Tournament:');
								final winner = game.winnerId != null ? playerProvider.getPlayerById(game.winnerId!) : null;
								final subtitle = (game.isCompleted && winner != null)
										? '${winner.name} won (${game.finalScores[game.winnerId] ?? 0} pts)'
										: 'In progress';

								return Card(
									margin: const EdgeInsets.only(bottom: 8),
									child: ListTile(
										leading: CircleAvatar(
											backgroundColor: isTournament ? Colors.amber : Colors.grey[700],
											child: Icon(isTournament ? Icons.emoji_events : Icons.videogame_asset,
													color: isTournament ? Colors.black : Colors.white),
										),
										title: HoverText(game.gameName),
										subtitle: HoverText(subtitle),
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
							}),

							const SizedBox(height: 16),
							const HoverText('Recent Tournament Matches', style: TextStyle(fontWeight: FontWeight.bold)),
							const SizedBox(height: 8),
							FutureBuilder<List<Match>>(
								future: DatabaseHelper.instance.getAllMatches(),
								builder: (context, snapshot) {
									if (snapshot.connectionState == ConnectionState.waiting) {
										return const Center(child: CircularProgressIndicator());
									}

									final matches = snapshot.data ?? [];
									if (matches.isEmpty) {
										return const HoverText('No tournament matches recorded yet', style: TextStyle(color: Colors.white));
									}

									// show up to 20 recent matches
									final recentMatches = matches.take(20).toList();

									return Column(
										children: recentMatches.map((m) {
											final p1 = playerProvider.getPlayerById(m.player1Id)?.name ?? 'Unknown';
											final p2 = m.player2Id == 'BYE' ? 'BYE' : playerProvider.getPlayerById(m.player2Id)?.name ?? 'Unknown';
											final winner = m.winnerId != null ? playerProvider.getPlayerById(m.winnerId!)?.name : null;

											final title = m.isBye ? '$p1 (Bye)' : 'Round ${m.roundNumber}: $p1 vs $p2';
											final subtitle = m.isCompleted
													? (winner != null ? 'Winner: $winner' : 'Completed')
													: 'Pending';

											return Card(
												margin: const EdgeInsets.only(bottom: 8),
												child: ListTile(
													leading: const Icon(Icons.sports_martial_arts, color: Colors.white),
													title: HoverText(title),
													subtitle: HoverText(subtitle),
													onTap: () {
														// try to open the tournament view for this match's tournament if available
														Navigator.pushNamed(context, '/tournament-view', arguments: m.tournamentId);
													},
												),
											);
										}).toList(),
									);
								},
							),
						],
					),
				);

				if (embedded) return content;

				return Scaffold(
					appBar: AppBar(
						title: const HoverText('History'),
					),
					body: content,
				);
			},
		);
	}
}
