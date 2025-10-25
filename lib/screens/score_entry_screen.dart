import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../models/game_template.dart';

class ScoreEntryScreen extends StatefulWidget {
  const ScoreEntryScreen({super.key});

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  GameTemplate? _selectedTemplate;
  List<String> _selectedPlayerIds = [];
  bool _gameStarted = false;
  Map<String, TextEditingController> _scoreControllers = {};
  int _currentPlayerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      if (gameProvider.currentGame != null) {
        setState(() => _gameStarted = true);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gameStarted ? 'Enter Scores' : 'Setup Game'),
        actions: _gameStarted
            ? [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _undoLastRound,
                  tooltip: 'Undo Last Round',
                ),
              ]
            : null,
      ),
      body: _gameStarted ? _buildGameInProgress() : _buildGameSetup(),
    );
  }

  Widget _buildGameSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Game',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return DropdownButtonFormField<GameTemplate>(
                        value: _selectedTemplate,
                        decoration: const InputDecoration(
                          hintText: 'Choose a game...',
                        ),
                        items: gameProvider.availableTemplates.map((template) {
                          return DropdownMenuItem(
                            value: template,
                            child: Text(template.name),
                          );
                        }).toList(),
                        onChanged: (template) {
                          setState(() => _selectedTemplate = template);
                          gameProvider.selectTemplate(template!);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Players',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                style: TextStyle(color: Colors.white54),
                              ),
                              const SizedBox(height: 8),
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
                          final isSelected = _selectedPlayerIds.contains(player.id);
                          return CheckboxListTile(
                            title: Text(player.name),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  _selectedPlayerIds.add(player.id);
                                } else {
                                  _selectedPlayerIds.remove(player.id);
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
          ElevatedButton(
            onPressed: _canStartGame() ? _startGame : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Start Game', style: TextStyle(fontSize: 16)),
          ),
          if (!_canStartGame() && _selectedTemplate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select at least 2 players',
                style: TextStyle(color: Colors.orange[300], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameInProgress() {
    return Consumer2<GameProvider, PlayerProvider>(
      builder: (context, gameProvider, playerProvider, child) {
        final game = gameProvider.currentGame;
        if (game == null) return const Center(child: Text('No active game'));

        // Initialize score controllers
        for (var playerId in game.playerIds) {
          if (!_scoreControllers.containsKey(playerId)) {
            _scoreControllers[playerId] = TextEditingController();
          }
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    game.gameName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Round ${game.totalRounds + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: game.playerIds.length,
                itemBuilder: (context, index) {
                  final playerId = game.playerIds[index];
                  final player = playerProvider.getPlayerById(playerId);
                  if (player == null) return const SizedBox();

                  final currentScore = game.finalScores[playerId] ?? 0;
                  final isCurrentPlayer = index == _currentPlayerIndex;

                  return Card(
                    color: isCurrentPlayer
                        ? Colors.blue.withOpacity(0.1)
                        : const Color(0xFF131516),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text(player.name[0].toUpperCase()),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Current Score: $currentScore',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _scoreControllers[playerId],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter score for this round',
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      final current = int.tryParse(
                                              _scoreControllers[playerId]!.text) ??
                                          0;
                                      _scoreControllers[playerId]!.text =
                                          (current - 1).toString();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      final current = int.tryParse(
                                              _scoreControllers[playerId]!.text) ??
                                          0;
                                      _scoreControllers[playerId]!.text =
                                          (current + 1).toString();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131516),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showEndGameDialog(context),
                      child: const Text('End Game'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitRound,
                      child: const Text('Next Round'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _canStartGame() {
    return _selectedTemplate != null && _selectedPlayerIds.length >= 2;
  }

  void _startGame() {
    if (!_canStartGame()) return;

    final gameProvider = context.read<GameProvider>();
    gameProvider.startNewGame(_selectedTemplate!.name, _selectedPlayerIds);

    setState(() => _gameStarted = true);
  }

  void _submitRound() {
    final gameProvider = context.read<GameProvider>();
    final roundScores = <String, int>{};

    bool allScoresEntered = true;
    for (var entry in _scoreControllers.entries) {
      final score = int.tryParse(entry.value.text);
      if (score == null) {
        allScoresEntered = false;
        break;
      }
      roundScores[entry.key] = score;
    }

    if (!allScoresEntered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter scores for all players')),
      );
      return;
    }

    gameProvider.addRoundScores(roundScores);

    // Clear controllers
    for (var controller in _scoreControllers.values) {
      controller.clear();
    }

    // Check win condition
    if (gameProvider.checkWinCondition()) {
      _showWinDialog();
    }

    setState(() {});
  }

  void _undoLastRound() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.undoLastRound();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Last round undone')),
    );
  }

  void _showEndGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Game'),
        content: const Text('Are you sure you want to end this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final gameProvider = context.read<GameProvider>();
              await gameProvider.endGame();
              
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/game-summary');
              }
            },
            child: const Text('End Game'),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    final gameProvider = context.read<GameProvider>();
    final playerProvider = context.read<PlayerProvider>();
    
    final game = gameProvider.currentGame!;
    final winner = playerProvider.getPlayerById(game.winnerId ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🏆 Winner!'),
        content: Text(
          '${winner?.name ?? "Unknown"} has reached the target score!',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await gameProvider.endGame();
              
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/game-summary');
              }
            },
            child: const Text('View Results'),
          ),
        ],
      ),
    );
  }
}