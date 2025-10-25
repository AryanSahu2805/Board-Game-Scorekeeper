import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/player_provider.dart';
import 'providers/game_provider.dart';
import 'providers/tournament_provider.dart';
import 'screens/home_screen.dart';
import 'screens/score_entry_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/player_management_screen.dart';
import 'screens/tournament_setup_screen.dart';
import 'screens/tournament_view_screen.dart';
import 'screens/game_summary_screen.dart';

void main() {
  runApp(const BoardGameScorekeeperApp());
}

class BoardGameScorekeeperApp extends StatelessWidget {
  const BoardGameScorekeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()..loadPlayers()),
        ChangeNotifierProvider(create: (_) => GameProvider()..loadGames()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()..loadTournaments()),
      ],
      child: MaterialApp(
        title: 'Board Game Scorekeeper',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        routes: {
          '/': (context) => const HomeScreen(),
          '/score-entry': (context) => const ScoreEntryScreen(),
          '/player-profile': (context) => const PlayerProfileScreen(),
          '/player-management': (context) => const PlayerManagementScreen(),
          '/tournament-setup': (context) => const TournamentSetupScreen(),
          '/tournament-view': (context) => const TournamentViewScreen(),
          '/game-summary': (context) => const GameSummaryScreen(),
        },
        initialRoute: '/',
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.grey[900],
        secondary: Colors.blueGrey,
        surface: const Color(0xFF131516),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1114),
      cardColor: const Color(0xFF131516),
      cardTheme: CardTheme(
        color: const Color(0xFF131516),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF131516),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}