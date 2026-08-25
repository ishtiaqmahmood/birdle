import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birdle',
      debugShowCheckedModeBanner: false,
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
      home: const GamePage(),
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
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Game _game;
  String _currentInput = '';
  final FocusNode _focusNode = FocusNode();

  static const List<List<String>> _keyboardRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DELETE'],
  ];

  @override
  void initState() {
    super.initState();
    _game = Game();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _game.resetGame();
      _currentInput = '';
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
      return;
    }

    if (!_game.isLegalGuess(_currentInput)) {
      _showMessage('Not in word list');
      return;
    }

    setState(() {
      _game.guess(_currentInput);
      _currentInput = '';
    });

    if (_game.didWin) {
      _showEndDialog(title: 'You Won! 🎉', message: 'Great job guessing the word!');
    } else if (_game.didLose) {
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
              icon: const Icon(Icons.refresh),
              tooltip: 'New Game',
              onPressed: _resetGame,
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

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Tile(
                                  letter,
                                  hitType,
                                  isCurrentInput: isCurrent,
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
}
