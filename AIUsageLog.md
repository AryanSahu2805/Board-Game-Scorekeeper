# AI Usage Log

## Project: Board Game Scorekeeper Flutter Application

This document provides a transparent record of AI assistance used during the development of this project, in accordance with academic integrity guidelines.

---

## Entry 1
**Date:** October 21, 2025  
**AI Tool Used:** ChatGPT / GitHub Copilot  
**Purpose:** Initial Project Setup and Architecture Planning

**What was asked/generated:**
- Discussed overall Flutter app architecture for a board game scorekeeper
- Asked about best practices for state management using Provider
- Requested guidance on SQLite database structure for players, games, and tournaments

**How it was applied:**
- Used AI suggestions to structure the project with Models, Providers, Services, and Screens folders
- Implemented Provider pattern for state management based on AI recommendations
- Created initial database schema with players, games, tournaments, and matches tables

**What was learned:**
- Understanding of Flutter's Provider package for state management
- How to structure a database with proper foreign key relationships
- Best practices for separating business logic from UI code

**Reflection:**
The AI helped establish a solid foundation, but all implementation details and specific business logic were developed independently. The suggestions provided a roadmap that I then customized for our specific requirements.

---

## Entry 2
**Date:** October 25, 2025  
**AI Tool Used:** ChatGPT  
**Purpose:** Tournament Pairing Algorithms

**What was asked/generated:**
- Asked for explanation of Swiss tournament pairing system
- Requested pseudocode for Round-Robin tournament generation
- Discussed how to handle odd number of players (bye system)

**How it was applied:**
- Studied the AI's explanation of Swiss pairing (matching players with similar records)
- Implemented custom `generateSwissPairings()` method in `tournament_service.dart`
- Created Round-Robin circle method algorithm with my own implementation
- Added bye handling logic for tournaments with odd player counts

**What was learned:**
- Mathematical concepts behind Swiss tournament systems
- Circle rotation algorithm for Round-Robin scheduling
- How to avoid repeat pairings using opponent tracking

**Reflection:**
While AI explained the algorithms conceptually, I wrote all the actual Dart code myself. The AI provided the theory, but understanding and implementing it required significant independent work and debugging.

---

## Entry 3
**Date:** October 25, 2025  
**AI Tool Used:** GitHub Copilot  
**Purpose:** Database Helper Methods and CRUD Operations

**What was asked/generated:**
- Copilot suggested some boilerplate for SQLite CRUD operations
- Auto-completed some repetitive database query patterns
- Suggested error handling patterns for async database operations

**How it was applied:**
- Reviewed Copilot's suggestions for insertPlayer, updatePlayer, deletePlayer methods
- Modified suggested code to match our specific Player model structure
- Extended patterns to create methods for Game, Tournament, and Match entities
- Added proper error handling and transaction management

**What was learned:**
- Standard patterns for CRUD operations in Flutter/Dart
- How to properly use async/await with SQLite
- Importance of conflict resolution strategies

**Reflection:**
Copilot accelerated writing repetitive database code, but I had to understand each method to ensure it matched our data models. I made significant modifications to handle relationships between entities.

---

## Entry 4
**Date:** October 25, 2025  
**AI Tool Used:** ChatGPT  
**Purpose:** UI/UX Design Patterns and Flutter Widgets

**What was asked/generated:**
- Asked about best practices for creating a dark theme in Flutter
- Requested examples of card-based layouts for displaying game history
- Discussed how to implement pull-to-refresh functionality

**How it was applied:**
- Created custom dark theme with high-contrast colors in `main.dart`
- Designed card-based UI for player profiles, game history, and tournaments
- Implemented RefreshIndicator in history and home screens
- Added custom `HoverText` widget for better desktop experience

**What was learned:**
- How to customize Flutter's ThemeData for consistent styling
- Material Design principles for list and card layouts
- Creating reusable custom widgets

**Reflection:**
AI provided design principles, but all actual UI implementation and styling decisions were mine. The theme colors, spacing, and overall aesthetic were chosen independently.

---

## Entry 5
**Date:** October 25, 2025  
**AI Tool Used:** ChatGPT  
**Purpose:** Debugging Navigation and State Management Issues

**What was asked/generated:**
- Described a bug where tournament state wasn't persisting after navigation
- Asked about proper use of Provider.of() vs Consumer widgets
- Discussed BuildContext lifecycle in Flutter

**How it was applied:**
- Added `persistCurrentTournament()` method to save state before navigation
- Fixed several bugs by using Consumer widgets in appropriate places
- Implemented proper state updates with `notifyListeners()`

**What was learned:**
- When to use Consumer vs Provider.of for accessing state
- How Flutter's widget tree affects state management
- Importance of calling notifyListeners() after state changes

**Reflection:**
AI helped me understand the root cause of bugs, but I debugged and fixed them independently. The debugging process taught me more about Flutter's architecture than the AI explanations alone.

---

## Entry 6
**Date:** October 26, 2025  
**AI Tool Used:** GitHub Copilot  
**Purpose:** Code Completion and Refactoring

**What was asked/generated:**
- Copilot suggested method names and parameter lists for several functions
- Auto-completed some common Flutter widget patterns
- Suggested variable names following Dart conventions

**How it was applied:**
- Accepted suggestions for well-named methods like `getSortedStandings()`
- Used widget structure suggestions as starting points, then customized
- Followed naming convention suggestions for consistency

**What was learned:**
- Dart/Flutter naming conventions and best practices
- Common patterns for organizing code within classes
- How to write more readable and maintainable code

**Reflection:**
Copilot was most useful for speeding up typing and maintaining consistency. However, all logic, algorithms, and design decisions were made independently.

---

## Entry 7
**Date:** October 26, 2025  
**AI Tool Used:** ChatGPT  
**Purpose:** Understanding Platform-Specific Database Setup

**What was asked/generated:**
- Asked about differences between mobile and desktop SQLite in Flutter
- Requested explanation of sqflite vs sqflite_common_ffi packages
- Discussed how to handle platform detection

**How it was applied:**
- Added platform-specific database initialization in `database_helper.dart`
- Implemented proper database factory selection for Windows/Linux/macOS
- Ensured code works across multiple platforms

**What was learned:**
- Flutter's platform detection capabilities
- Differences in database implementations across platforms
- How to write cross-platform compatible code

**Reflection:**
This was essential for desktop support. AI explained the concepts, but implementing and testing across platforms required independent problem-solving.

---

## Entry 8
**Date:** October 26, 2025  
**AI Tool Used:** ChatGPT  
**Purpose:** Statistics Calculation and Win Rate Logic

**What was asked/generated:**
- Discussed how to calculate win rates from game history
- Asked about edge cases (division by zero, no games played)
- Requested best practices for displaying statistics in UI

**How it was applied:**
- Implemented win rate calculation in Player model and throughout UI
- Added proper handling for edge cases (0 games, no winner, etc.)
- Created statistics display cards in player profile screen

**What was learned:**
- Importance of handling edge cases in calculations
- How to display statistics in a user-friendly way
- Defensive programming practices

**Reflection:**
AI helped identify potential bugs before they occurred. The actual implementation and testing of all edge cases was done independently.

---

## Summary

### Overall AI Usage Assessment
- **Percentage of AI-generated code:** ~5-10% (mostly boilerplate and suggestions)
- **Percentage of AI-influenced design:** ~20-25% (architectural guidance and best practices)
- **Percentage of original work:** ~70-75% (all core logic, algorithms, UI design, and debugging)

### Key Principles Followed
1. **Never copied entire code blocks** from AI without understanding them
2. **Always modified and customized** AI suggestions to fit our needs
3. **Used AI as a learning tool** rather than a code generator
4. **Independently debugged** all issues, even when AI suggested solutions
5. **Made all design decisions** independently, using AI only for technical guidance

### Skills Developed Independently
- Flutter widget composition and layout design
- Provider state management patterns
- SQLite database design and queries
- Tournament pairing algorithms implementation
- Cross-platform compatibility handling
- UI/UX design and theming
- Git workflow and version control

### Academic Integrity Statement
This project represents genuine learning and development work. AI tools were used responsibly as assistants for:
- Understanding concepts and best practices
- Accelerating repetitive coding tasks
- Identifying potential issues early
- Learning industry-standard patterns

All core functionality, business logic, and creative decisions were made independently. The commit history shows consistent, incremental progress that reflects genuine development work rather than bulk AI generation.

---

**Prepared by:** Aryan Sahu & Kenny Bui  
**Date:** October 27, 2025  
**Course:** Mobile App Development