# 🐦 Birdle - A Word Guessing Game

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A polished, **Wordle-inspired** word guessing game built with **Flutter**. Challenge yourself to find the hidden five-letter word in six attempts or less!

## ✨ Features

- 🎮 **Classic Gameplay**: Guess the hidden 5-letter word within 6 attempts
- 🎨 **Material Design 3**: Beautiful, modern UI with light and dark theme support
- ⌨️ **Dual Input**: Support for both physical keyboard and on-screen virtual keyboard
- 📱 **Cross-Platform**: Runs on iOS, Android, Web, Windows, macOS, and Linux
- 🔄 **Instant Feedback**: Color-coded tiles show exact, partial, and missed letters
- ♾️ **Unlimited Play**: Generate endless random words or play with deterministic seeds
- 🎯 **Smart Validation**: Comprehensive word list ensures fair and challenging gameplay
- 🔥 **Hard Mode**: Must use all revealed hints in subsequent guesses
- 📊 **Statistics Tracking**: Win rate, streaks, and guess distribution
- 📅 **Daily Challenge**: Play the same puzzle as everyone else each day
- 🎭 **Animations**: Shake animations for invalid guesses, bounce effects for correct ones
- ℹ️ **Help System**: Built-in tutorial explaining game mechanics
- ⚙️ **Settings Panel**: Customize your gameplay experience

## 🎮 How to Play

1. **Enter a 5-letter word** using your keyboard or the on-screen virtual keyboard
2. **Submit your guess** by pressing Enter or tapping the ENTER key
3. **Analyze the feedback**:
   - 🟩 **Green (Hit)**: Letter is correct and in the right position
   - 🟨 **Yellow/Amber (Partial)**: Letter is in the word but in wrong position
   - ⬜ **Gray (Miss)**: Letter is not in the word at all
4. **Repeat** until you guess the word or run out of attempts!

### Hard Mode Rules

When Hard Mode is enabled:
- You **must** use all green (correct position) letters in their places
- You **must** include all yellow (wrong position) letters in your next guess
- This adds extra challenge by forcing you to use revealed information

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.11.0 or higher)
- Dart SDK (version 3.11.0 or higher)
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/birdle.git
   cd birdle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# For Web
flutter build web

# For Android
flutter build apk --release

# For iOS
flutter build ios --release

# For Desktop (Windows/macOS/Linux)
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## 🏗️ Project Structure

```
birdle/
├── lib/
│   ├── main.dart          # App entry point, UI components, and dialogs
│   └── game.dart          # Core game logic and state management
├── test/                  # Unit and widget tests
├── pubspec.yaml           # Project dependencies and metadata
└── README.md              # This file
```

## 🧠 Game Logic

The game uses a sophisticated letter-matching algorithm:

1. **Exact matches (hits)** are identified first
2. **Partial matches** are calculated from remaining unmatched letters
3. Each letter in the hidden word can only be matched once per guess

This ensures fair and consistent feedback, even with repeated letters.

## 🎮 Game Modes

### Classic Mode
- Standard gameplay with 6 attempts
- No restrictions on subsequent guesses
- Perfect for casual play

### Hard Mode 🔥
- Must use all revealed letters (green and yellow) in next guesses
- Green letters must stay in their correct positions
- Increases difficulty significantly

### Daily Challenge 📅
- Same seed word for all players each day
- Compare results with friends
- Based on current date for deterministic word selection

## 📊 Statistics

Track your performance with detailed statistics:
- **Games Played**: Total number of games started
- **Win Percentage**: Ratio of wins to total games
- **Current Streak**: Consecutive wins
- **Max Streak**: Best winning streak achieved
- **Guess Distribution**: Bar chart showing how many wins per attempt number

## 🎨 Customization

### Themes

Birdle supports both light and dark modes automatically based on system preferences. Toggle themes via the Settings menu or force a specific theme in `main.dart`:

```dart
themeMode: ThemeMode.dark, // or ThemeMode.light
```

### Word Lists

Modify the word lists in `lib/game.dart`:
- `legalWords`: Words that can be the hidden word
- `legalGuesses`: Additional words accepted as valid guesses

### Game Settings

Adjust difficulty in the `Game` class:
```dart
final game = Game(maxGuesses: 7); // Change from default 6 guesses
final game = Game(seed: 42);      // Deterministic word selection
```

## 🎭 Animations

Birdle features smooth animations for enhanced user experience:

- **Shake Animation**: Triggers when an invalid guess is submitted
- **Bounce Animation**: Plays when a valid guess is submitted
- **Tile Transitions**: Smooth color transitions when revealing letter status

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

## 📱 Supported Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅     |
| iOS      | ✅     |
| Web      | ✅     |
| Windows  | ✅     |
| macOS    | ✅     |
| Linux    | ✅     |

## 🛠️ Development

### Code Quality

This project follows the [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and uses [flutter_lints](https://pub.dev/packages/flutter_lints) for static analysis.

```bash
# Analyze code
flutter analyze

# Format code
dart format .
```

### Architecture

- **Separation of Concerns**: Game logic (`game.dart`) is completely separated from UI (`main.dart`)
- **Immutable State**: Uses records and unmodifiable views for safe state management
- **Clean API**: Well-documented public methods for easy integration
- **Component-Based UI**: Reusable widgets for tiles, keyboard, and dialogs

### Key Components

#### MainApp
- Root widget managing theme state and app configuration
- Handles theme toggling between light/dark modes

#### GamePage
- Main game screen with grid and keyboard
- Manages game state, statistics, and dialogs
- Handles keyboard input (physical and virtual)

#### Tile Widget
- Renders individual letter tiles
- Supports different visual states (none, hit, partial, miss)
- Animated transitions between states

#### Virtual Keyboard
- On-screen keyboard for touch devices
- Color-coded keys matching tile feedback
- Special keys: ENTER, DELETE/BACKSPACE

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Feature Ideas

- 🏆 Achievements system
- 🌐 Multiplayer mode
- 🎨 Custom color themes
- 📈 Advanced statistics with charts
- 🔊 Sound effects
- 🌍 Multiple language support
- 💾 Cloud save for statistics

## 🙏 Acknowledgments

- Inspired by the original [Wordle](https://www.powerlanguage.co.uk/wordle/) game
- Built with [Flutter](https://flutter.dev) and [Dart](https://dart.dev)
- Word lists sourced from open-source word game projects

## 📞 Support

If you have any questions or issues, please open an issue on the GitHub repository.

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to Top](#-birdle---a-word-guessing-game)

</div>
