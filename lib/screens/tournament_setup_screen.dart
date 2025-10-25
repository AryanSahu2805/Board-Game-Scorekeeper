import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';
import '../providers/player_provider.dart';
import '../models/tournament.dart';

class TournamentSetupScreen extends StatefulWidget {
  const TournamentSetupScreen({super.key});

  @override
  State<TournamentSetupScreen> createState() => _TournamentSetupScreenState();
}

class _TournamentSetupScreenState extends State<TournamentSetupScreen> {
  final _nameController = TextEditingController();
  TournamentFormat _selectedFormat = TournamentFormat.swiss;
  final Set<String> _selectedParticipants = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Tournament'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tournament Name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tournament Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Weekly Board Game Championship',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tournament Format
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Tournament Format',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 20),
                          onPressed: () => _showFormatInfo(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Swiss'),
                            selected: _selectedFormat == TournamentFormat.swiss,
                            onSelected: (_) {
                              setState(() => _selectedFormat = TournamentFormat.swiss);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Round-Robin'),
                            selected: _selectedFormat == TournamentFormat.roundRobin,
                            onSelected: (_) {
                              setState(() => _selectedFormat = TournamentFormat.roundRobin);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Participants Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Participants',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_selectedParticipants.length} selected',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer<PlayerProvider>(
                      builder: (context, playerProvider, child) {
                        if (playerProvider.players.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                const Text(
                                  'No players available',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/player-management');
                                  },
                                  child: const Text('Add Players'),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: playerProvider.players.map((player) {
                            final isSelected = _selectedParticipants.contains(player.id);
                            return CheckboxListTile(
                              title: Text(player.name),
                              subtitle: Text(
                                '${player.totalWins} wins • ${player.winRate.toStringAsFixed(0)}% win rate',
                              ),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value!) {
                                    _selectedParticipants.add(player.id);
                                  } else {
                                    _selectedParticipants.remove(player.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton(
              onPressed: _canCreateTournament() ? _createTournament : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create Tournament',
                style: TextStyle(fontSize: 16),
              ),
            ),

            if (!_canCreateTournament())
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _getValidationMessage(),
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canCreateTournament() {
    return _nameController.text.trim().isNotEmpty && 
           _selectedParticipants.length >= 4;
  }

  String _getValidationMessage() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter a tournament name';
    }
    if (_selectedParticipants.length < 4) {
      return 'Please select at least 4 participants';
    }
    return '';
  }

  void _createTournament() async {
    if (!_canCreateTournament()) return;

    try {
      final tournamentProvider = context.read<TournamentProvider>();
      
      await tournamentProvider.createTournament(
        name: _nameController.text.trim(),
        format: _selectedFormat,
        participantIds: _selectedParticipants.toList(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/tournament-view');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating tournament: $e')),
        );
      }
    }
  }

  void _showFormatInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tournament Formats'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Swiss System',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Players with similar records face each other. '
                'Number of rounds based on player count. '
                'No player elimination.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Round-Robin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Every player plays against every other player once. '
                'More matches but fair for all participants.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}