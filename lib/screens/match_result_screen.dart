import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';
import '../widgets/hover_text.dart';

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({super.key});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  late final Map<String, dynamic> args;
  late final String matchId;
  late final String player1Id;
  late final String player2Id;
  late final String player1Name;
  late final String player2Name;

  int player1Score = 0;
  int player2Score = 0;
  String? selectedWinner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    matchId = args['matchId'] as String;
    player1Id = args['player1Id'] as String;
    player2Id = args['player2Id'] as String;
    player1Name = args['player1Name'] as String;
    player2Name = args['player2Name'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const HoverText('Enter Match Result'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              color: Theme.of(context).cardColor,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Players and counters in a clean two-column layout
                    Row(
                      children: [
                        // Left column: Player labels
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HoverText(player1Name, style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 24),
                              HoverText(player2Name, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),

                        // Right column: counters
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildCounterRow(player1Score, () {
                                setState(() { if (player1Score > 0) player1Score--; selectedWinner = null; });
                              }, () {
                                setState(() { player1Score++; selectedWinner = null; });
                              }),
                              const SizedBox(height: 18),
                              _buildCounterRow(player2Score, () {
                                setState(() { if (player2Score > 0) player2Score--; selectedWinner = null; });
                              }, () {
                                setState(() { player2Score++; selectedWinner = null; });
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const HoverText('Winner:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: HoverText(player1Name),
                            selected: selectedWinner == player1Id || (selectedWinner == null && player1Score > player2Score),
                            selectedColor: Theme.of(context).colorScheme.primary.withAlpha(230),
                            onSelected: (_) => setState(() => selectedWinner = player1Id),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: HoverText(player2Name),
                            selected: selectedWinner == player2Id || (selectedWinner == null && player2Score > player1Score),
                            selectedColor: Theme.of(context).colorScheme.primary.withAlpha(230),
                            onSelected: (_) => setState(() => selectedWinner = player2Id),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const HoverText('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const HoverText('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterRow(int value, VoidCallback onDecrement, VoidCallback onIncrement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          splashRadius: 20,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
          ),
          child: HoverText(
            '$value',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          splashRadius: 20,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    String? winnerId = selectedWinner;
    if (winnerId == null) {
      if (player1Score > player2Score) { winnerId = player1Id; }
      else if (player2Score > player1Score) { winnerId = player2Id; }
    }

    if (winnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure a winner is selected or scores are not tied')),
      );
      return;
    }

    try {
      final provider = context.read<TournamentProvider>();
      final navigator = Navigator.of(context);

      await provider.recordMatchResult(
        matchId: matchId,
        winnerId: winnerId,
        player1Score: player1Score,
        player2Score: player2Score,
      );

      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording result: $e')),
        );
      }
    }
  }
}
