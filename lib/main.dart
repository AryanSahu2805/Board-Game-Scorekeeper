import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/score_entry_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/tournament_setup_screen.dart';

void main() {
  runApp(BoardGameScorekeeperApp());
}

class BoardGameScorekeeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.dark();
    return MaterialApp(
      title: 'Board Game Scorekeeper',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: Colors.grey[900],
          secondary: Colors.blueGrey,
        ),
        scaffoldBackgroundColor: Color(0xFF0F1114),
        cardColor: Color(0xFF131516),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
      ),
      routes: {
        '/': (context) => HomeScreen(),
        ScoreEntryScreen.routeName: (context) => ScoreEntryScreen(),
        PlayerProfileScreen.routeName: (context) => PlayerProfileScreen(),
        TournamentSetupScreen.routeName: (context) => TournamentSetupScreen(),
      },
      initialRoute: '/',
    );
  }
}
