import 'package:flutter/material.dart';
import 'score_entry_screen.dart';
import 'player_profile_screen.dart';
import 'tournament_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Board Game Scorekeeper'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, John',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, ScoreEntryScreen.routeName),
                    child: Text('New Game'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, TournamentSetupScreen.routeName),
                    child: Text('Create Tournament'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, PlayerProfileScreen.routeName),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.white70,
              ),
              child: Text('Player Profiles'),
            ),
            SizedBox(height: 20),
            Text('Recent Games', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _recentGameTile('Carcassonne', 'You won by 25 points', 'Yesterday'),
                  _recentGameTile('Terraforming Mars', "Mark's turn", 'Ongoing'),
                  _recentGameTile('Wingspan', 'You lost by 10 points', '3 days ago'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF0F1114),
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
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
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        tileColor: const Color(0xFF131516),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(time, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}
