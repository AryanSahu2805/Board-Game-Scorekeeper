import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../models/game_template.dart';
import '../widgets/hover_text.dart';

class ScoreEntryScreen extends StatefulWidget {
  const ScoreEntryScreen({super.key});

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  GameTemplate? _selectedTemplate;
  final List<String> _selectedPlayerIds = [];
  bool _gameStarted = false;
  final Map<String, TextEditingController> _scoreControllers = {};
  final int _currentPlayerIndex = 0;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If there's nothing to pop, go to root
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
        title: HoverText(_gameStarted ? 'Enter Scores' : 'Setup Game'),
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
                  const HoverText(
                    'Select Game',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedTemplate?.name,
                        decoration: const InputDecoration(
                          hintText: 'Choose a game...',
                        ),
                        items: gameProvider.availableTemplates.map((template) {
                          return DropdownMenuItem<String>(
                            value: template.name,
                            child: HoverText(template.name),
                          );
                        }).toList(),
                        onChanged: (templateName) {
                          if (templateName == null) return;
                          final selected = gameProvider.availableTemplates.firstWhere(
                            (t) => t.name == templateName,
                            orElse: () => gameProvider.availableTemplates.first,
                          );
                          setState(() => _selectedTemplate = selected);
                          gameProvider.selectTemplate(selected);
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
                  const HoverText(
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
                              const HoverText(
                                'No players available',
                                      style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/player-management');
                                },
                                child: const HoverText('Add Players'),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: playerProvider.players.map((player) {
                          final isSelected = _selectedPlayerIds.contains(player.id);
                          return CheckboxListTile(
                            title: HoverText(player.name),
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
            child: const HoverText('Start Game', style: TextStyle(fontSize: 16)),
          ),
          if (!_canStartGame() && _selectedTemplate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: HoverText(
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
  if (game == null) return const Center(child: HoverText('No active game'));

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
                  HoverText(
                    game.gameName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                        HoverText(
                    'Round ${game.totalRounds + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
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
            ? Colors.blue.withAlpha(26)
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
                                child: HoverText(player.name[0].toUpperCase()),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HoverText(
                                      player.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    HoverText(
                                      'Current Score: $currentScore',
                                      style: const TextStyle(
                                        color: Colors.white,
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
                    color: Colors.black.withAlpha(51),
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
                child: const HoverText('End Game'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitRound,
                      child: const HoverText('Next Round'),
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
        const SnackBar(content: HoverText('Please enter scores for all players')),
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
      const SnackBar(content: HoverText('Last round undone')),
    );
  }

  void _showEndGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
  title: const HoverText('End Game'),
  content: const HoverText('Are you sure you want to end this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const HoverText('Cancel'),
          ),
          TextButton(
            // ignore: use_build_context_synchronously
            onPressed: () async {
              Navigator.pop(ctx);
              final gameProvider = context.read<GameProvider>();
              await gameProvider.endGame();
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/game-summary');
            },
            child: const HoverText('End Game'),
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
        title: const HoverText('🏆 Winner!'),
        content: HoverText(
          '${winner?.name ?? "Unknown"} has reached the target score!',
        ),
        actions: [
          TextButton(
            // ignore: use_build_context_synchronously
            onPressed: () async {
              Navigator.pop(ctx);
              await gameProvider.endGame();
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/game-summary');
            },
            child: const HoverText('View Results'),
          ),
        ],
      ),
    );
  }
}