import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _hardMode = false;
  int _dailySeed = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _setHardMode(bool value) {
    setState(() {
      _hardMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birdle',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: GamePage(
        onThemeToggle: _toggleTheme,
        hardMode: _hardMode,
        onHardModeChanged: _setHardMode,
        dailySeed: _dailySeed,
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key, this.isCurrentInput = false});

  final String letter;
  final HitType hitType;
  final bool isCurrentInput;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    Border border;

    switch (hitType) {
      case HitType.hit:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        border = Border.all(color: Colors.green.shade600, width: 2);
        break;
      case HitType.partial:
        backgroundColor = Colors.amber.shade700;
        textColor = Colors.white;
        border = Border.all(color: Colors.amber.shade700, width: 2);
        break;
      case HitType.miss:
        backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade500;
        textColor = Colors.white;
        border = Border.all(color: backgroundColor, width: 2);
        break;
      case HitType.none:
        backgroundColor = Colors.transparent;
        textColor = theme.colorScheme.onSurface;
        border = Border.all(
          color: letter.isNotEmpty
              ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          width: letter.isNotEmpty ? 2 : 1.5,
        );
        break;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool hardMode;
  final ValueChanged<bool> onHardModeChanged;
  final int dailySeed;

  const GamePage({
    super.key,
    required this.onThemeToggle,
    required this.hardMode,
    required this.onHardModeChanged,
    required this.dailySeed,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late Game _game;
  String _currentInput = '';
  final FocusNode _focusNode = FocusNode();
  bool _showSettings = false;
  bool _showHelp = false;
  bool _showStats = false;
  int _streak = 0;
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  int _maxStreak = 0;
  Map<int, int> _guessDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  List<int> _animatingRows = [];

  static const List<List<String>> _keyboardRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DELETE'],
  ];

  @override
  void initState() {
    super.initState();
    _game = Game(seed: widget.dailySeed % legalWords.length);
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadStats();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _loadStats() {
    setState(() {
      _streak = 0;
      _gamesPlayed = 0;
      _gamesWon = 0;
      _maxStreak = 0;
      _guessDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    });
  }

  void _saveStats() {
    // Stats would be persisted in a real app using shared_preferences
  }

  void _resetGame() {
    setState(() {
      _game = Game(seed: Random().nextInt(legalWords.length));
      _currentInput = '';
      _animatingRows.clear();
    });
  }

  void _playDaily() {
    setState(() {
      _game = Game(seed: widget.dailySeed % legalWords.length);
      _currentInput = '';
      _animatingRows.clear();
    });
  }

  void _onKeyPressed(String key) {
    if (_game.didWin || _game.didLose) return;

    if (key == 'ENTER') {
      _submitGuess();
    } else if (key == 'DELETE' || key == 'BACKSPACE') {
      if (_currentInput.isNotEmpty) {
        setState(() {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        });
      }
    } else if (RegExp(r'^[A-Za-z]$').hasMatch(key)) {
      if (_currentInput.length < 5) {
        setState(() {
          _currentInput += key.toLowerCase();
        });
      }
    }
  }

  void _submitGuess() {
    if (_currentInput.length < 5) {
      _showMessage('Not enough letters');
      _shakeController.forward(from: 0);
      return;
    }

    if (!_game.isLegalGuess(_currentInput)) {
      _showMessage('Not in word list');
      _shakeController.forward(from: 0);
      return;
    }

    // Hard mode validation
    if (widget.hardMode && _game.activeIndex > 0) {
      final previous = _game.previousGuess;
      final requiredLetters = <String, int>{};
      
      for (final letter in previous) {
        if (letter.type == HitType.hit || letter.type == HitType.partial) {
          requiredLetters[letter.char] = (requiredLetters[letter.char] ?? 0) + 1;
        }
      }
      
      final currentGuessLetters = <String, int>{};
      for (var i = 0; i < _currentInput.length; i++) {
        final char = _currentInput[i];
        currentGuessLetters[char] = (currentGuessLetters[char] ?? 0) + 1;
      }
      
      for (final entry in requiredLetters.entries) {
        if ((currentGuessLetters[entry.key] ?? 0) < entry.value) {
          _showMessage('Must use all revealed letters');
          _shakeController.forward(from: 0);
          return;
        }
      }
      
      for (var i = 0; i < 5; i++) {
        if (previous[i].type == HitType.hit && _currentInput[i] != previous[i].char) {
          _showMessage('Must keep correct letters in place');
          _shakeController.forward(from: 0);
          return;
        }
      }
    }

    setState(() {
      _game.guess(_currentInput);
      _currentInput = '';
      _animatingRows.add(_game.activeIndex - 1);
    });

    _bounceController.forward(from: 0);

    if (_game.didWin) {
      _gamesWon++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
      _guessDistribution[_game.activeIndex + 1] = 
        (_guessDistribution[_game.activeIndex + 1] ?? 0) + 1;
      _gamesPlayed++;
      _saveStats();
      _showEndDialog(title: 'You Won! 🎉', message: 'Great job guessing the word!');
    } else if (_game.didLose) {
      _streak = 0;
      _gamesPlayed++;
      _saveStats();
      _showEndDialog(
        title: 'Game Over 😔',
        message: 'The word was: ${_game.hiddenWord.toString().toUpperCase()}',
      );
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        width: 250,
      ),
    );
  }

  void _showEndDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Map<String, HitType> _getKeyHitTypes() {
    final keyHits = <String, HitType>{};
    for (final word in _game.guesses) {
      if (word.isEmpty) continue;
      for (final letter in word) {
        final char = letter.char.toUpperCase();
        final currentHit = keyHits[char] ?? HitType.none;
        if (letter.type == HitType.hit) {
          keyHits[char] = HitType.hit;
        } else if (letter.type == HitType.partial && currentHit != HitType.hit) {
          keyHits[char] = HitType.partial;
        } else if (letter.type == HitType.miss &&
            currentHit != HitType.hit &&
            currentHit != HitType.partial) {
          keyHits[char] = HitType.miss;
        }
      }
    }
    return keyHits;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyLabel = event.logicalKey.keyLabel.toUpperCase();
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _onKeyPressed('ENTER');
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _onKeyPressed('DELETE');
      } else if (keyLabel.length == 1 && RegExp(r'^[A-Z]$').hasMatch(keyLabel)) {
        _onKeyPressed(keyLabel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyHitMap = _getKeyHitTypes();
    final activeRowIndex = _game.activeIndex;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Birdle',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'How to Play',
              onPressed: () => setState(() => _showHelp = true),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statistics',
              onPressed: () => setState(() => _showStats = true),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => setState(() => _showSettings = true),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              tooltip: 'More Options',
              onSelected: (value) {
                if (value == 'daily') _playDaily();
                if (value == 'reset') _resetGame();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'daily', child: Text('📅 Daily Challenge')),
                const PopupMenuItem(value: 'reset', child: Text('🔄 New Random Game')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Grid
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_game.maxGuesses, (rowIndex) {
                        final isSubmitted = rowIndex < activeRowIndex ||
                            (activeRowIndex == -1 && _game.guesses[rowIndex].isNotEmpty);
                        final isCurrent = rowIndex == activeRowIndex;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (colIndex) {
                              String letter = '';
                              HitType hitType = HitType.none;

                              if (isSubmitted) {
                                final word = _game.guesses[rowIndex];
                                letter = word[colIndex].char;
                                hitType = word[colIndex].type;
                              } else if (isCurrent && colIndex < _currentInput.length) {
                                letter = _currentInput[colIndex];
                              }

                              return AnimatedBuilder(
                                animation: _shakeController,
                                builder: (context, child) {
                                  double shakeOffset = 0;
                                  if (_animatingRows.contains(rowIndex) || 
                                      (!isSubmitted && !isCurrent)) {
                                    shakeOffset = sin(_shakeController.value * 2 * pi) * 10;
                                  }
                                  return Transform.translate(
                                    offset: Offset(shakeOffset, 0),
                                    child: child!,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                  child: Tile(
                                    letter,
                                    hitType,
                                    isCurrentInput: isCurrent,
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Virtual Keyboard
              _buildKeyboard(keyHitMap),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(Map<String, HitType> keyHitMap) {
    return Column(
      children: _keyboardRows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              final hitType = keyHitMap[key] ?? HitType.none;
              return _buildKeyButton(key, hitType);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(String key, HitType hitType) {
    final isSpecialKey = key == 'ENTER' || key == 'DELETE';
    final double width = isSpecialKey ? 62.0 : 36.0;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color fgColor = Colors.white;

    switch (hitType) {
      case HitType.hit:
        bgColor = Colors.green.shade600;
        break;
      case HitType.partial:
        bgColor = Colors.amber.shade700;
        break;
      case HitType.miss:
        bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade500;
        break;
      case HitType.none:
        bgColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        fgColor = theme.colorScheme.onSurface;
        break;
    }

    Widget keyContent;
    if (key == 'DELETE') {
      keyContent = const Icon(Icons.backspace_outlined, size: 20);
    } else {
      keyContent = Text(
        key,
        style: TextStyle(
          fontSize: isSpecialKey ? 12 : 16,
          fontWeight: FontWeight.bold,
          color: fgColor,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      width: width,
      height: 52,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _onKeyPressed(key),
          child: Center(child: keyContent),
        ),
      ),
    );
  }

  Widget _buildStatsDialog() {
    final winPercentage = _gamesPlayed > 0 
        ? ((_gamesWon / _gamesPlayed) * 100).round() 
        : 0;
    final maxBarHeight = 100.0;
    
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Played', _gamesPlayed.toString()),
                _buildStatItem('Win %', '$winPercentage'),
                _buildStatItem('Streak', '$_streak'),
                _buildStatItem('Max Streak', '$_maxStreak'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Guess Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(6, (index) {
              final guessNum = index + 1;
              final count = _guessDistribution[guessNum] ?? 0;
              final maxCount = _guessDistribution.values.reduce((a, b) => a > b ? a : b);
              final barWidth = maxCount > 0 
                  ? (count / maxCount) * maxBarHeight 
                  : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    SizedBox(width: 20, child: Text('$guessNum')),
                    Container(
                      width: barWidth,
                      height: 28,
                      color: _game.didWin && _game.activeIndex + 1 == guessNum 
                          ? Colors.green 
                          : Colors.grey,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => setState(() => _showStats = false),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildHelpDialog() {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Play',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Guess the hidden 5-letter word in 6 tries.'),
            const SizedBox(height: 12),
            const Text('Each guess must be a valid 5-letter word.',
                style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            const Text('After each guess, the tiles will show how close you are:'),
            const SizedBox(height: 16),
            _buildExampleTile('W', 'E', HitType.hit, 'W is in the word and in the correct spot'),
            _buildExampleTile('I', 'N', HitType.partial, 'N is in the word but in the wrong spot'),
            _buildExampleTile('G', 'R', HitType.miss, 'R is not in the word'),
            const SizedBox(height: 16),
            if (widget.hardMode)
              const Text(
                '🔥 Hard Mode Active: You must use all revealed letters in subsequent guesses!',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => setState(() => _showHelp = false),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleTile(String letter1, String letter2, HitType hitType, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Tile(letter1, hitType),
          const SizedBox(width: 4),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  Widget _buildSettingsDialog() {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark/light theme'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) => widget.onThemeToggle(),
            ),
            SwitchListTile(
              title: const Text('Hard Mode'),
              subtitle: const Text('Must use revealed hints'),
              value: widget.hardMode,
              onChanged: widget.onHardModeChanged,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('New Random Game'),
              subtitle: const Text('Start a new game with random word'),
              onTap: () {
                Navigator.pop(context);
                _resetGame();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Daily Challenge'),
              subtitle: const Text('Play today\'s puzzle'),
              onTap: () {
                Navigator.pop(context);
                _playDaily();
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => setState(() => _showSettings = false),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main game UI (previously built content)
        KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'Birdle',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'How to Play',
                  onPressed: () => setState(() => _showHelp = true),
                ),
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  tooltip: 'Statistics',
                  onPressed: () => setState(() => _showStats = true),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onPressed: () => setState(() => _showSettings = true),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  tooltip: 'More Options',
                  onSelected: (value) {
                    if (value == 'daily') _playDaily();
                    if (value == 'reset') _resetGame();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'daily', child: Text('📅 Daily Challenge')),
                    const PopupMenuItem(value: 'reset', child: Text('🔄 New Random Game')),
                  ],
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_game.maxGuesses, (rowIndex) {
                            final isSubmitted = rowIndex < activeRowIndex ||
                                (activeRowIndex == -1 && _game.guesses[rowIndex].isNotEmpty);
                            final isCurrent = rowIndex == activeRowIndex;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (colIndex) {
                                  String letter = '';
                                  HitType hitType = HitType.none;

                                  if (isSubmitted) {
                                    final word = _game.guesses[rowIndex];
                                    letter = word[colIndex].char;
                                    hitType = word[colIndex].type;
                                  } else if (isCurrent && colIndex < _currentInput.length) {
                                    letter = _currentInput[colIndex];
                                  }

                                  return AnimatedBuilder(
                                    animation: _shakeController,
                                    builder: (context, child) {
                                      double shakeOffset = 0;
                                      if (_animatingRows.contains(rowIndex) || 
                                          (!isSubmitted && !isCurrent)) {
                                        shakeOffset = sin(_shakeController.value * 2 * pi) * 10;
                                      }
                                      return Transform.translate(
                                        offset: Offset(shakeOffset, 0),
                                        child: child!,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                      child: Tile(
                                        letter,
                                        hitType,
                                        isCurrentInput: isCurrent,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildKeyboard(keyHitMap),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        // Dialogs overlay
        if (_showHelp) _buildHelpDialog(),
        if (_showStats) _buildStatsDialog(),
        if (_showSettings) _buildSettingsDialog(),
      ],
    );
  }
}
