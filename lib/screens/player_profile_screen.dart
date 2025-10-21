import 'package:flutter/material.dart';

class PlayerProfileScreen extends StatelessWidget {
  static const routeName = '/player-profile';

  @override
  Widget build(BuildContext context) {
    // Example static player stats
    final Map<String, String> player = {
      'name': 'John Doe',
      'email': 'john.doe@email.com',
      'wins': '89',
      'losses': '42',
      'favorite': 'Azul',
      'winRate': '67.9%',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Player Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                  SizedBox(height: 10),
                  Text(player['name'] ?? '',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(player['email'] ?? '', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                _statCard('Wins', player['wins'] ?? ''),
                SizedBox(width: 8),
                _statCard('Losses', player['losses'] ?? ''),
                SizedBox(width: 8),
                _statCard('Win Rate', player['winRate'] ?? ''),
              ],
            ),
            SizedBox(height: 18),
            ListTile(
              tileColor: const Color(0xFF131516),
              leading: Icon(Icons.videogame_asset),
              title: Text('Favorite Game'),
              subtitle: Text(player['favorite'] ?? ''),
              trailing: Text('Wins 25 • Losses 10'),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _gameHistoryItem('Ticket to Ride', 'Loss', 'Oct 15'),
                  _gameHistoryItem('Azul', 'Win', 'Oct 14'),
                  _gameHistoryItem('Splendor', 'Win', 'Oct 11'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameHistoryItem(String game, String result, String date) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        tileColor: const Color(0xFF131516),
        title: Text(game),
        subtitle: Text(result),
        trailing: Text(date),
      ),
    );
  }
}
