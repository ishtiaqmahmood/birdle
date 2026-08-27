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

## 🎮 How to Play

1. **Enter a 5-letter word** using your keyboard or the on-screen virtual keyboard
2. **Submit your guess** by pressing Enter or tapping the ENTER key
3. **Analyze the feedback**:
   - 🟩 **Green (Hit)**: Letter is correct and in the right position
   - 🟨 **Yellow/Amber (Partial)**: Letter is in the word but in wrong position
   - ⬜ **Gray (Miss)**: Letter is not in the word at all
4. **Repeat** until you guess the word or run out of attempts!

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
│   ├── main.dart          # App entry point and UI components
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

## 🎨 Customization

### Themes

Birdle supports both light and dark modes automatically based on system preferences. You can also force a specific theme in `main.dart`:

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

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

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
