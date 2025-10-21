import 'package:flutter/material.dart';

class ScoreEntryScreen extends StatefulWidget {
  static const routeName = '/score-entry';

  @override
  _ScoreEntryScreenState createState() => _ScoreEntryScreenState();
}

class PlayerScore {
  String name;
  int score;
  bool currentTurn;
  PlayerScore({required this.name, this.score = 0, this.currentTurn = false});
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  List<PlayerScore> players = [
    PlayerScore(name: 'Player 1', score: 12, currentTurn: true),
    PlayerScore(name: 'Player 2', score: 0),
    PlayerScore(name: 'Player 3', score: 5),
  ];

  void _increment(int idx) {
    setState(() => players[idx].score++);
  }

  void _decrement(int idx) {
    setState(() {
      if (players[idx].score > 0) players[idx].score--;
    });
  }

  void _addPlayer() {
    setState(() => players.add(PlayerScore(name: 'Player ${players.length + 1}')));
  }

  void _removePlayer() {
    if (players.length <= 2) return;
    setState(() => players.removeLast());
  }

  void _nextTurn() {
    int current = players.indexWhere((p) => p.currentTurn);
    setState(() {
      players[current].currentTurn = false;
      players[(current + 1) % players.length].currentTurn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Scores'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  value: 'Select a Game',
                  items: [
                    DropdownMenuItem(child: Text('Select a Game'), value: 'Select a Game'),
                    DropdownMenuItem(child: Text('Catan'), value: 'Catan'),
                    DropdownMenuItem(child: Text('Wingspan'), value: 'Wingspan'),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: players.length,
                separatorBuilder: (_, __) => SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final p = players[idx];
                  return Card(
                    child: ListTile(
                      tileColor: Color(0xFF131516),
                      leading: CircleAvatar(child: Text(p.name.split(' ').last)),
                      title: Text(p.name),
                      subtitle: p.currentTurn ? Text('Current Turn') : null,
                      trailing: Container(
                        width: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => _decrement(idx),
                              icon: Icon(Icons.remove_circle_outline),
                              color: Colors.white70,
                            ),
                            SizedBox(width: 6),
                            Text('${p.score}', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 6),
                            IconButton(
                              onPressed: () => _increment(idx),
                              icon: Icon(Icons.add_circle_outline),
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addPlayer,
                  icon: Icon(Icons.person_add),
                  label: Text('Add Player'),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _removePlayer,
                  icon: Icon(Icons.person_remove),
                  label: Text('Remove Player'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: _nextTurn,
                  child: Text('Next Turn'),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('End Game'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
