import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';
import '../providers/player_provider.dart';
import '../models/tournament.dart';
import '../widgets/hover_text.dart';

class TournamentViewScreen extends StatefulWidget {
  const TournamentViewScreen({super.key});

  @override
  State<TournamentViewScreen> createState() => _TournamentViewScreenState();
}

class _TournamentViewScreenState extends State<TournamentViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _buildBracketTab(
    Tournament tournament,
    TournamentProvider tournamentProvider,
    PlayerProvider playerProvider,
  ) {
    final matches = tournamentProvider.currentMatches;
    if (matches.isEmpty) return const Center(child: HoverText('No matches scheduled'));

    final rounds = <int>{};
  for (var m in matches) { rounds.add(m.roundNumber); }
    final maxRound = rounds.isEmpty ? 0 : rounds.reduce((a, b) => a > b ? a : b);
    

    // Build a column for each round
    final columns = <Widget>[];
    for (var round = 1; round <= maxRound; round++) {
      final roundMatches = matches.where((m) => m.roundNumber == round).toList();

      final children = <Widget>[];
      children.add(Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: HoverText('Round $round', style: const TextStyle(fontWeight: FontWeight.bold)),
      ));
      // Winners label appears under the round header
      children.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: HoverText('Winners', style: TextStyle(fontSize: 12, color: Colors.white70)),
      ));

      for (var m in roundMatches) {
        final p1 = playerProvider.getPlayerById(m.player1Id)?.name ?? 'Unknown';
        final p2 = m.player2Id == 'BYE' ? 'Bye' : (playerProvider.getPlayerById(m.player2Id)?.name ?? 'Unknown');

        children.add(Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HoverText('$p1 vs $p2', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                if (m.isCompleted)
                  HoverText('Winner: ${playerProvider.getPlayerById(m.winnerId ?? '')?.name ?? 'TBD'}', style: const TextStyle(color: Colors.green)),
                if (!m.isCompleted) const HoverText('Pending', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ));
      }

      // After the winner matches, show a "Losers" label at the bottom of the column
      children.add(const SizedBox(height: 12));
      children.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: HoverText('Losers', style: TextStyle(fontSize: 12, color: Colors.white70)),
      ));

      columns.add(Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ));
    }

    // Build children interleaving a vertical separator line between round columns
    final rowChildren = <Widget>[];
    for (var i = 0; i < columns.length; i++) {
      rowChildren.add(columns[i]);
      if (i < columns.length - 1) {
        rowChildren.add(const SizedBox(width: 12));
        rowChildren.add(Container(
          width: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white12,
        ));
        rowChildren.add(const SizedBox(width: 12));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ConstrainedBox(
          // Ensure the row can center its children when there's spare space
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: columns.length <= 2 ? MainAxisAlignment.center : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TournamentProvider, PlayerProvider>(
      builder: (context, tournamentProvider, playerProvider, child) {
        final tournament = tournamentProvider.currentTournament;

        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(title: const HoverText('Tournament')),
            body: const Center(child: HoverText('No active tournament')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                // Persist tournament state before leaving so it can be resumed later
                final navigator = Navigator.of(context);
                await tournamentProvider.persistCurrentTournament();
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  navigator.pushReplacementNamed('/');
                }
              },
            ),
            title: HoverText(tournament.name),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Matches'),
                Tab(text: 'Standings'),
                Tab(text: 'Bracket'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildMatchesTab(tournament, tournamentProvider, playerProvider),
              _buildStandingsTab(tournamentProvider, playerProvider),
              _buildBracketTab(tournament, tournamentProvider, playerProvider),
            ],
          ),
          bottomNavigationBar: tournament.status == TournamentStatus.completed
              ? null
              : _buildBottomActions(tournamentProvider),
        );
      },
    );
  }

  Widget _buildMatchesTab(
    Tournament tournament,
    TournamentProvider tournamentProvider,
    PlayerProvider playerProvider,
  ) {
    final currentRoundMatches = tournamentProvider.getCurrentRoundMatches();

    if (currentRoundMatches.isEmpty) {
      return const Center(child: HoverText('No matches scheduled'));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HoverText(
                'Round ${tournament.currentRound}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              HoverText(
                '${currentRoundMatches.where((m) => m.isCompleted).length}/${currentRoundMatches.length} complete',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentRoundMatches.length,
            itemBuilder: (context, index) {
              final match = currentRoundMatches[index];
              return _buildMatchCard(match, playerProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(Match match, PlayerProvider playerProvider) {
    final player1 = playerProvider.getPlayerById(match.player1Id);
    final player2 = match.player2Id == 'BYE' 
        ? null 
        : playerProvider.getPlayerById(match.player2Id);

    if (match.isBye) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: HoverText(
                  '${player1?.name ?? "Unknown"} (Bye)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: match.isCompleted
            ? null
            : () async {
                final res = await Navigator.pushNamed(
                  context,
                  '/match-result',
                  arguments: {
                    'matchId': match.id,
                    'player1Id': match.player1Id,
                    'player2Id': match.player2Id,
                    'player1Name': player1?.name ?? '',
                    'player2Name': player2?.name ?? '',
                  },
                );

                if (res == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Match result recorded')),
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HoverText(
                          player1?.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: match.winnerId == match.player1Id
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (match.isCompleted && match.player1Score != null)
                          HoverText(
                            '${match.player1Score} pts',
                            style: const TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: HoverText('vs', style: TextStyle(color: Colors.white)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        HoverText(
                          player2?.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: match.winnerId == match.player2Id
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (match.isCompleted && match.player2Score != null)
                          HoverText(
                            '${match.player2Score} pts',
                            style: const TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (match.isCompleted) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                      color: Colors.green.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const HoverText(
                    'Completed',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showMatchResultDialog(
                    match,
                    player1?.name ?? '',
                    player2?.name ?? '',
                  ),
                  child: const HoverText('Enter Result'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsTab(
    TournamentProvider tournamentProvider,
    PlayerProvider playerProvider,
  ) {
    final sortedStandings = tournamentProvider.getSortedStandings();

    if (sortedStandings.isEmpty) {
      return const Center(child: HoverText('No standings available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedStandings.length,
      itemBuilder: (context, index) {
        final entry = sortedStandings[index];
        final player = playerProvider.getPlayerById(entry.key);
        final standing = entry.value;
        final position = index + 1;

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
              child: HoverText(
                '$position',
                style: TextStyle(
                  color: position <= 3 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: HoverText(
              player?.name ?? 'Unknown',
              style: TextStyle(
                fontWeight: position == 1 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: HoverText(
              '${standing.matchWins}W - ${standing.matchLosses}L • '
              '${player?.totalWins ?? 0} wins • ${player?.winRate.toStringAsFixed(0) ?? '0'}% all-time',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                HoverText(
                  '${standing.totalPoints} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: position == 1 ? Colors.amber : Colors.white,
                  ),
                ),
                HoverText(
                  '${(standing.winRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(TournamentProvider tournamentProvider) {
    final canAdvance = tournamentProvider.isRoundComplete();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131516),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: canAdvance ? _advanceRound : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: HoverText(
          canAdvance ? 'Next Round' : 'Complete All Matches',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showMatchResultDialog(Match match, String player1Name, String player2Name) {
    int player1Score = 0;
    int player2Score = 0;
    String? selectedWinner;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const HoverText('Enter Match Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Player 1 counter
              Row(
                children: [
                  Expanded(child: HoverText(player1Name)),
                  IconButton(
                    onPressed: () => setState(() {
                      if (player1Score > 0) { player1Score--; }
                      // If scores change, clear explicit winner selection so it can be re-selected
                      selectedWinner = null;
                    }),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: HoverText('$player1Score'),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      player1Score++;
                      selectedWinner = null;
                    }),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Player 2 counter
              Row(
                children: [
                  Expanded(child: HoverText(player2Name)),
                  IconButton(
                    onPressed: () => setState(() {
                      if (player2Score > 0) { player2Score--; }
                      selectedWinner = null;
                    }),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: HoverText('$player2Score'),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      player2Score++;
                      selectedWinner = null;
                    }),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const HoverText('Winner:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: HoverText(player1Name),
                      selected: selectedWinner == match.player1Id || (selectedWinner == null && player1Score > player2Score),
                      onSelected: (_) {
                        setState(() => selectedWinner = match.player1Id);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: HoverText(player2Name),
                      selected: selectedWinner == match.player2Id || (selectedWinner == null && player2Score > player1Score),
                      onSelected: (_) {
                        setState(() => selectedWinner = match.player2Id);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const HoverText('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // If no explicit winner chosen, infer from scores
                String? winnerId = selectedWinner;
                if (winnerId == null) {
                  if (player1Score > player2Score) { winnerId = match.player1Id; }
                  else if (player2Score > player1Score) { winnerId = match.player2Id; }
                }

                if (winnerId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please ensure a winner is selected or scores are not tied'),
                    ),
                  );
                  return;
                }

                await context.read<TournamentProvider>().recordMatchResult(
                      matchId: match.id,
                      winnerId: winnerId,
                      player1Score: player1Score,
                      player2Score: player2Score,
                    );

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Match result recorded')),
                  );
                }
              },
              child: const HoverText('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _advanceRound() async {
    final tournamentProvider = context.read<TournamentProvider>();
    await tournamentProvider.advanceToNextRound();

    if (mounted) {
      if (tournamentProvider.currentTournament?.status == TournamentStatus.completed) {
        _showTournamentCompleteDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advanced to next round')),
        );
      }
    }
  }

  void _showTournamentCompleteDialog() {
    final tournamentProvider = context.read<TournamentProvider>();
    final playerProvider = context.read<PlayerProvider>();
    final tournament = tournamentProvider.currentTournament!;
    final winner = tournament.winnerId != null
        ? playerProvider.getPlayerById(tournament.winnerId!)
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
  title: const HoverText('🏆 Tournament Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HoverText('Winner:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            HoverText(
              winner?.name ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        actions: [
            TextButton(
            onPressed: () {
              tournamentProvider.clearCurrentTournament();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const HoverText('Home'),
          ),
        ],
      ),
    );
  }
}