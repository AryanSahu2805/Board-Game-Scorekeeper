# 🎲 Board Game Scorekeeper & Tournament Manager

> A comprehensive Flutter application for tracking board game sessions, managing player statistics, and organizing competitive tournaments with Swiss and Round-Robin formats.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-lightgrey)](https://flutter.dev)

---

## 📹 Presentation Video

**Watch our complete project presentation and demo:**

> 🔗 [App Demo Video](https://drive.google.com/file/d/189AYVvg6G3fADSk_iqNizYNPkRTrN5mk/view?usp=sharing)
> 🔗 [Presentation Part 1](https://drive.google.com/file/d/12MsHAivpNdS6jZP5WAgepOKvassW5sDT/view?usp=sharing)
> 🔗 [Presentation Part 2](https://drive.google.com/file/d/17w6Z3wxaqtdA-FMSM10nEcJB07IX8UMZ/view)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Usage Guide](#usage-guide)
- [Database Schema](#database-schema)
- [Tournament Algorithms](#tournament-algorithms)
- [Project Structure](#project-structure)
- [Development Process](#development-process)
- [Testing](#testing)
- [Team](#team)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## 🎯 Overview

**Board Game Scorekeeper** is a mobile and desktop application designed to eliminate the hassle of manual scorekeeping during board game sessions. Whether you're hosting a casual game night or organizing a competitive tournament, our app provides an intuitive, feature-rich platform for tracking scores, managing players, and running professional tournaments.

### The Problem We Solved

Board game enthusiasts face several challenges:
- ❌ Manual scoring is error-prone and time-consuming
- ❌ No centralized way to track game history
- ❌ Complex spreadsheets required for tournament organization
- ❌ Difficult to maintain player statistics over time
- ❌ Tournament pairing algorithms (Swiss, Round-Robin) are complex to implement manually

### Our Solution

✅ **Automated score tracking** with real-time calculations  
✅ **Complete game history** with detailed statistics  
✅ **Built-in tournament system** with automatic pairing  
✅ **Player profiles** with win rates and performance metrics  
✅ **Smart algorithms** for Swiss and Round-Robin tournaments  
✅ **Offline-first design** with local SQLite database  

---

## ✨ Features

### 🎮 Core Features

#### 1. **Score Templates**
- Pre-configured templates for 10 popular board games
- Support for multiple scoring methods:
  - Cumulative scoring (scores add up each round)
  - Per-round scoring (only current round counts)
  - First-to-target scoring (race to specific point total)
- Custom starting scores and win conditions
- Support for negative scores where applicable

**Supported Games:**
- Catan, Carcassonne, Terraforming Mars, Wingspan, Azul
- Ticket to Ride, Splendor, Scrabble, Uno, Custom Games

#### 2. **Player Management**
- Create and manage player profiles
- Automatic statistics tracking:
  - Total games played
  - Total wins and losses
  - Win rate percentage
  - Favorite games
  - Join date
- View detailed player history
- Edit player information
- Delete players with cascade cleanup

#### 3. **Game Session Tracking**
- Start new game sessions with selected players
- Round-by-round score entry
- Real-time score calculations
- **Undo/Redo functionality** for error correction
- Automatic winner determination
- Complete game history storage
- View past game summaries

#### 4. **Tournament System**
- Create tournaments with 4+ players
- Two tournament formats:
  - **Swiss System**: Players with similar records compete
  - **Round-Robin**: Every player faces every other player
- Automatic match pairing using sophisticated algorithms
- Real-time standings and leaderboards
- Match result recording
- Bye handling for odd player counts
- Tournament completion with winner determination

#### 5. **Statistics & Analytics**
- Individual player statistics
- Win/loss records
- Performance trends
- Head-to-head comparisons
- Game-specific performance metrics

#### 6. **Offline-First Design**
- Complete functionality without internet
- Local SQLite database
- Fast data access
- Reliable persistence

---

## 📸 Screenshots

*Add screenshots of your application here showing:*
- Home screen
- Player management
- Score entry during gameplay
- Tournament setup
- Tournament view with brackets
- Player profile
- Game history
- Game summary

---

## 🏗️ Architecture

Our application follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────┐
│   UI Layer          │  Screens & Widgets
│   (Presentation)    │
└─────────────────────┘
         ↕
┌─────────────────────┐
│   State Management  │  Providers (ChangeNotifier)
│   Layer             │
└─────────────────────┘
         ↕
┌─────────────────────┐
│   Business Logic    │  Services & Algorithms
│   Layer             │
└─────────────────────┘
         ↕
┌─────────────────────┐
│   Data Layer        │  Models & Database Helper
│                     │
└─────────────────────┘
         ↕
┌─────────────────────┐
│   Database Layer    │  SQLite Storage
│                     │
└─────────────────────┘
```

### Architecture Benefits

✅ **Separation of Concerns**: Each layer has a single responsibility  
✅ **Testability**: Layers can be tested independently  
✅ **Maintainability**: Changes in one layer don't cascade  
✅ **Scalability**: Easy to add new features  
✅ **Readability**: Clear code organization  

### Key Architectural Patterns

1. **Provider Pattern** for state management
2. **Singleton Pattern** for database access
3. **Repository Pattern** for data operations
4. **Factory Pattern** for object creation
5. **Observer Pattern** for reactive updates

---

## 🛠️ Technology Stack

### Framework & Language
- **Flutter 3.x**: Google's UI toolkit for building natively compiled applications
- **Dart 3.x**: Client-optimized language for fast apps on any platform

### State Management
- **Provider Pattern**: Official Flutter state management solution
- **ChangeNotifier**: Observable state changes
- **Consumer Widgets**: Reactive UI updates

### Database
- **SQLite**: Local relational database
- **sqflite**: Flutter plugin for SQLite
- **sqflite_common_ffi**: Cross-platform SQLite support for desktop

### Supporting Packages
- **uuid**: Unique identifier generation
- **intl**: Internationalization and date formatting
- **path**: File path manipulation

### Platforms Supported
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 📦 Installation

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/AryanSahu2805/Board-Game-Scorekeeper.git
   cd Board-Game-Scorekeeper
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   
   For Android/iOS:
   ```bash
   flutter run
   ```
   
   For Desktop (Windows):
   ```bash
   flutter run -d windows
   ```
   
   For Desktop (macOS):
   ```bash
   flutter run -d macos
   ```
   
   For Desktop (Linux):
   ```bash
   flutter run -d linux
   ```

4. **Build for release**
   
   Android APK:
   ```bash
   flutter build apk --release
   ```
   
   Android App Bundle:
   ```bash
   flutter build appbundle --release
   ```
   
   iOS:
   ```bash
   flutter build ios --release
   ```
   
   Windows:
   ```bash
   flutter build windows --release
   ```

---

## 📖 Usage Guide

### Getting Started

1. **Add Players**
   - Tap the floating action button on the home screen
   - Enter player name
   - Player profile is automatically created

2. **Start a New Game**
   - Tap "New Game" on the home screen
   - Select a game template (e.g., Catan, Wingspan)
   - Choose 2 or more players
   - Tap "Start Game"

3. **Enter Scores**
   - Enter scores for each player in the current round
   - Tap "Next Round" to proceed
   - Use "Undo Last Round" if you make a mistake
   - Tap "End Game" when finished

4. **View Results**
   - Winner is displayed with a trophy icon
   - Final standings show all players ranked by score
   - Game is automatically saved to history

### Creating a Tournament

1. **Setup Tournament**
   - Navigate to the Tournaments tab
   - Tap "Create Tournament"
   - Enter tournament name
   - Select format (Swiss or Round-Robin)
   - Choose 4 or more participants
   - Tap "Create Tournament"

2. **Record Match Results**
   - View current round matches
   - Tap on a match to record results
   - Enter scores for both players
   - Confirm the winner
   - Match is marked as complete

3. **Advance Rounds**
   - When all matches in a round are complete, tap "Next Round"
   - New pairings are automatically generated
   - Continue until tournament is complete

4. **View Tournament Results**
   - Final standings show all participants ranked
   - Winner is determined by match wins and points
   - Tournament is saved to history

### Managing Players

1. **View Player Profiles**
   - Navigate to Player Management
   - Tap on any player to view their profile
   - See statistics, win rate, and recent games

2. **Edit Player**
   - Open player profile
   - Tap the edit icon
   - Update player name
   - Save changes

3. **Delete Player**
   - Navigate to Player Management
   - Tap the delete icon next to a player
   - Confirm deletion
   - Player and their data are removed

---

## 🗄️ Database Schema

### Tables

#### **players**
Stores player information and statistics.

| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| name | TEXT | NOT NULL |
| totalGamesPlayed | INTEGER | DEFAULT 0 |
| totalWins | INTEGER | DEFAULT 0 |
| totalLosses | INTEGER | DEFAULT 0 |
| favoriteGame | TEXT | NULL |
| createdAt | TEXT | NOT NULL |

#### **games**
Records completed game sessions.

| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| gameName | TEXT | NOT NULL |
| dateTime | TEXT | NOT NULL |
| playerIds | TEXT | NOT NULL |
| finalScores | TEXT | NOT NULL |
| winnerId | TEXT | NULL |
| totalRounds | INTEGER | DEFAULT 0 |
| isCompleted | INTEGER | DEFAULT 0 |

#### **round_scores**
Detailed round-by-round scoring data.

| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| gameId | TEXT | NOT NULL, FK → games(id) |
| roundNumber | INTEGER | NOT NULL |
| playerId | TEXT | NOT NULL, FK → players(id) |
| score | INTEGER | NOT NULL |

#### **tournaments**
Tournament metadata and configuration.

| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| name | TEXT | NOT NULL |
| format | TEXT | NOT NULL |
| participantIds | TEXT | NOT NULL |
| currentRound | INTEGER | DEFAULT 1 |
| status | TEXT | NOT NULL |
| createdAt | TEXT | NOT NULL |
| winnerId | TEXT | NULL |

#### **matches**
Individual tournament matches.

| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| tournamentId | TEXT | NOT NULL, FK → tournaments(id) |
| roundNumber | INTEGER | NOT NULL |
| player1Id | TEXT | NOT NULL |
| player2Id | TEXT | NOT NULL |
| winnerId | TEXT | NULL |
| player1Score | INTEGER | NULL |
| player2Score | INTEGER | NULL |
| isCompleted | INTEGER | DEFAULT 0 |
| isBye | INTEGER | DEFAULT 0 |

### Relationships

- **Games ↔ Players**: Many-to-many relationship through playerIds stored as comma-separated string
- **Round Scores → Games**: Many-to-one relationship with cascade delete
- **Tournaments ↔ Players**: Many-to-many relationship through participantIds
- **Matches → Tournaments**: Many-to-one relationship with cascade delete
- **Matches → Players**: References player IDs for pairing information

---

## 🧮 Tournament Algorithms

### Swiss System Tournament

The Swiss system pairs players with similar records without elimination.

**Algorithm Overview:**

1. **Round 1**: Random pairing
   ```dart
   // Shuffle participants for fair first round
   final shuffled = List<String>.from(participants)..shuffle();
   ```

2. **Subsequent Rounds**: Performance-based pairing
   ```dart
   // Sort by wins, then by total points
   standings.sort((a, b) {
     final winsCompare = b.matchWins.compareTo(a.matchWins);
     if (winsCompare != 0) return winsCompare;
     return b.totalPoints.compareTo(a.totalPoints);
   });
   ```

3. **Avoid Repeat Matchups**
   ```dart
   // Check if players have faced each other before
   final hasPlayed = previousMatches.any((m) =>
     (m.player1Id == p1 && m.player2Id == p2) ||
     (m.player1Id == p2 && m.player2Id == p1)
   );
   ```

4. **Calculate Required Rounds**
   ```dart
   // Formula: ceiling(log2(playerCount))
   int calculateSwissRounds(int playerCount) {
     return (log(playerCount) / log(2)).ceil();
   }
   ```

**Features:**
- No player elimination
- Players face opponents of similar skill
- Efficient winner determination
- Handles odd player counts with byes

### Round-Robin Tournament

Every player faces every other player exactly once.

**Algorithm Overview:**

1. **Circle Rotation Method**
   ```dart
   final rounds = players.length - 1;
   final matchesPerRound = players.length ~/ 2;
   
   for (var round = 0; round < rounds; round++) {
     // Generate matches for this round
     for (var match = 0; match < matchesPerRound; match++) {
       // Pair opposite positions in the circle
     }
     
     // Rotate players (keep first fixed)
     final temp = players.removeLast();
     players.insert(1, temp);
   }
   ```

2. **Total Matches Formula**
   ```
   Total Matches = n * (n - 1) / 2
   where n = number of players
   ```

**Features:**
- Guaranteed fairness (everyone plays everyone)
- Deterministic match schedule
- Known upfront: total rounds = n - 1
- Simple winner determination by total wins

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── player.dart                    # Player entity
│   ├── game.dart                      # Game session entity
│   ├── game_template.dart             # Game configuration templates
│   └── tournament.dart                # Tournament & Match entities
├── providers/                         # State management
│   ├── player_provider.dart           # Player state management
│   ├── game_provider.dart             # Game state management
│   └── tournament_provider.dart       # Tournament state management
├── services/                          # Business logic
│   ├── database_helper.dart           # SQLite operations
│   └── tournament_service.dart        # Tournament algorithms
├── screens/                           # UI screens
│   ├── home_screen.dart               # Main dashboard
│   ├── main_tabs_screen.dart          # Tab navigation
│   ├── score_entry_screen.dart        # Game score entry
│   ├── game_summary_screen.dart       # Game results
│   ├── history_screen.dart            # Game history
│   ├── player_management_screen.dart  # Player list
│   ├── player_profile_screen.dart     # Player details
│   ├── tournament_setup_screen.dart   # Tournament creation
│   └── tournament_view_screen.dart    # Active tournament view
└── widgets/                           # Reusable widgets
    └── hover_text.dart                # Custom text with hover effect
```

---

## 🔧 Development Process

### Timeline
- **Total Duration**: 18 days
- **Team Size**: 2 developers
- **Commits**: 30+ commits with detailed messages

### Development Methodology
- **Version Control**: Git with feature branches
- **Code Review**: Peer reviews before merging
- **Testing**: Unit, widget, and integration tests
- **Documentation**: Inline comments and comprehensive README

### Git Workflow
1. Feature branches for major additions
2. Regular commits with descriptive messages
3. Code reviews before merging to main
4. Clean commit history maintained throughout

### Commit Message Convention
```
feat: Add tournament pairing algorithm
fix: Resolve state sync issue in game provider
refactor: Improve database query performance
docs: Update README with installation instructions
test: Add unit tests for Swiss pairing
```

---

## 🧪 Testing

### Testing Strategy

#### 1. **Unit Tests**
- Score calculation logic
- Win rate computation
- Tournament pairing algorithms
- Database serialization/deserialization

#### 2. **Widget Tests**
- Button click handlers
- Form validation
- Navigation flows
- Consumer widget updates

#### 3. **Integration Tests**
- Complete game flow (3 players, 5 rounds)
- Swiss tournament (8 players, all rounds)
- Round-Robin tournament (6 players)
- Data persistence across app restarts

#### 4. **Manual Testing**
- User experience flows
- Edge cases (odd players, ties, byes)
- Cross-platform compatibility
- Performance with large datasets

### Test Coverage

✅ All core features tested  
✅ Edge cases handled  
✅ No critical bugs in production  
✅ Performance validated on real devices  

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/player_test.dart
```

---

## 👥 Team

### Team CodeGamers

**Aryan Sahu**
- GitHub: [@AryanSahu2805](https://github.com/AryanSahu2805)
- Role: Lead Developer
- Contributions: 
  - Database architecture and implementation
  - Player management system
  - Game session tracking
  - UI/UX design and theming
  - State management setup

**Kenny Bui**
- GitHub: [@Kanzanbu](https://github.com/Kanzanbu)
- Role: Lead Developer
- Contributions:
  - Tournament system implementation
  - Swiss and Round-Robin algorithms
  - Tournament pairing logic
  - Testing and quality assurance
  - Documentation

### Project Details
- **Course**: Mobile App Development
- **Project**: Project 1 - Board Game Scorekeeper
- **Institution**: [Your University/Institution]
- **Semester**: Fall 2025

---

## 🚀 Future Enhancements

### Phase 1: Enhanced Features
- ☐ Cloud sync with Firebase
- ☐ Social features (share results, challenge friends)
- ☐ More game templates (50+ popular board games)
- ☐ Export game history as CSV/PDF
- ☐ Custom game template creator
- ☐ Profile pictures for players
- ☐ Achievements and badges system

### Phase 2: Advanced Features
- ☐ AI-powered opponent suggestions
- ☐ Advanced analytics and charts
- ☐ Head-to-head statistics
- ☐ Performance trends over time
- ☐ Tournament brackets visualization
- ☐ Photo upload for game sessions
- ☐ Notes and comments on games

### Phase 3: Platform Expansion
- ☐ Web version (responsive design)
- ☐ Smartwatch companion app
- ☐ Voice-based score entry
- ☐ Internationalization (10+ languages)
- ☐ Dark/Light theme toggle
- ☐ Accessibility improvements
- ☐ Multiplayer real-time tournaments

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute
1. **Report Bugs**: Open an issue with detailed reproduction steps
2. **Suggest Features**: Share your ideas in the issues section
3. **Submit Pull Requests**: Fix bugs or add features
4. **Improve Documentation**: Help us make the docs better
5. **Test**: Help us test on different devices and platforms

### Contribution Guidelines

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Write/update tests**
5. **Commit with clear messages**
   ```bash
   git commit -m 'feat: Add amazing feature'
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Comment complex logic
- Write tests for new features
- Ensure all tests pass before submitting PR

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Aryan Sahu & Kenny Bui

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

### Special Thanks

- **Flutter Team**: For creating an amazing cross-platform framework
- **Dart Team**: For a powerful and elegant programming language
- **Our Course Instructor**: For guidance and feedback throughout the project
- **Board Game Community**: For inspiring this project
- **Open Source Contributors**: For the packages we depend on

### Packages Used

- [provider](https://pub.dev/packages/provider) - State management
- [sqflite](https://pub.dev/packages/sqflite) - SQLite database
- [path](https://pub.dev/packages/path) - File path manipulation
- [uuid](https://pub.dev/packages/uuid) - UUID generation
- [intl](https://pub.dev/packages/intl) - Internationalization

### Inspiration

This project was inspired by the challenges faced during regular board game nights and the desire to create a comprehensive solution that combines score tracking with professional tournament management.

---

## 📞 Contact

Have questions, suggestions, or feedback? Reach out to us!

**Aryan Sahu**
- GitHub: [@AryanSahu2805](https://github.com/AryanSahu2805)
- Email: [Your Email]

**Kenny Bui**
- GitHub: [@Kanzanbu](https://github.com/Kanzanbu)
- Email: [Your Email]

**Project Link**: [https://github.com/AryanSahu2805/Board-Game-Scorekeeper](https://github.com/AryanSahu2805/Board-Game-Scorekeeper)

---

## 📊 Project Stats

![GitHub Stars](https://img.shields.io/github/stars/AryanSahu2805/Board-Game-Scorekeeper?style=social)
![GitHub Forks](https://img.shields.io/github/forks/AryanSahu2805/Board-Game-Scorekeeper?style=social)
![GitHub Issues](https://img.shields.io/github/issues/AryanSahu2805/Board-Game-Scorekeeper)
![GitHub Pull Requests](https://img.shields.io/github/issues-pr/AryanSahu2805/Board-Game-Scorekeeper)

### Code Metrics
- **Total Files**: 19 Dart files
- **Lines of Code**: ~3,500
- **Screens**: 8 main screens
- **Models**: 4 data models
- **Providers**: 3 state managers
- **Test Coverage**: Comprehensive unit and integration tests

---

<div align="center">

### ⭐ Star this repository if you find it helpful!

**Made with ❤️ by Team CodeGamers**

*Bringing professional scorekeeping to board game enthusiasts everywhere*

[Report Bug](https://github.com/AryanSahu2805/Board-Game-Scorekeeper/issues) • [Request Feature](https://github.com/AryanSahu2805/Board-Game-Scorekeeper/issues) • [Documentation](https://github.com/AryanSahu2805/Board-Game-Scorekeeper/wiki)

</div>

---

**Last Updated**: October 2025  
**Version**: 1.0.0  

**Status**: ✅ Production Ready
