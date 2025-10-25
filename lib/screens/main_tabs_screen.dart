import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'tournament_setup_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A simple AppBar that stays consistent while swiping
      appBar: AppBar(
        title: const Text('Board Game Scorekeeper'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          // Use the embedded variants where possible so nested Scaffolds are avoided
          HomeScreen(embedded: true),
          HistoryScreen(embedded: true),
          TournamentSetupScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F1114),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Tournaments'),
        ],
      ),
    );
  }
}
