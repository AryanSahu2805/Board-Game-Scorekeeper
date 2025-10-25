import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/player_provider.dart';
import 'providers/game_provider.dart';
import 'providers/tournament_provider.dart';
import 'screens/main_tabs_screen.dart';
import 'screens/score_entry_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/player_management_screen.dart';
import 'screens/tournament_setup_screen.dart';
import 'screens/tournament_view_screen.dart';
import 'screens/game_summary_screen.dart';
import 'screens/history_screen.dart';

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
        ChangeNotifierProvider(create: (ctx) => TournamentProvider(gameProvider: Provider.of<GameProvider>(ctx, listen: false))..loadTournaments()),
      ],
      child: MaterialApp(
        title: 'Board Game Scorekeeper',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        routes: {
          '/': (context) => const MainTabsScreen(),
          '/history': (context) => const HistoryScreen(),
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
      // Use high-contrast white for primary body text so colored accents pop
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      // Brighter primary and secondary accents for a more vibrant feeling
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.blueAccent,
        secondary: Colors.cyanAccent,
        surface: const Color(0xFF0D1A22),
      ),
      // Slightly lighter background so accents contrast well
      scaffoldBackgroundColor: const Color(0xFF081218),
      // Card color with a subtle tint so cards lift visually from the background
      cardColor: const Color(0xFF0F222B),
      cardTheme: CardThemeData(
        color: const Color(0xFF131516),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.cyanAccent,
          side: const BorderSide(color: Colors.cyanAccent),
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
      // Make checkboxes match the app blue and have a contrasting check mark
      // Use WidgetStateProperty / WidgetState (newer API) to avoid deprecated MaterialStateProperty/MaterialState
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return Colors.blueAccent;
          return Colors.blueAccent.withAlpha(150);
        }),
        checkColor: WidgetStateProperty.all<Color>(Colors.white),
        side: const BorderSide(color: Colors.blueAccent),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF071218),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white70,
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