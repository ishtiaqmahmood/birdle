import 'package:birdle/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game Logic Tests', () {
    test('Initial game state', () {
      final game = Game(seed: 0);
      expect(game.maxGuesses, equals(5));
      expect(game.guessesRemaining, equals(5));
      expect(game.activeIndex, equals(0));
      expect(game.didWin, isFalse);
      expect(game.didLose, isFalse);
      expect(game.previousGuess.isEmpty, isTrue);
    });

    test('Evaluating valid guess and checking hits', () {
      final game = Game(seed: 0);
      // seed 0 word is aback
      final guessResult = game.guess('aback');
      expect(game.didWin, isTrue);
      expect(game.didLose, isFalse);
      expect(game.guessesRemaining, equals(4));
      expect(game.activeIndex, equals(1));
      expect(guessResult.every((letter) => letter.type == HitType.hit), isTrue);
    });

    test('Partial hit evaluation', () {
      final game = Game(seed: 0); // hidden word is aback
      final guessResult = game.matchGuessOnly('abase');
      // 'a', 'b', 'a' hit, 's' miss, 'e' miss
      expect(guessResult[0].type, equals(HitType.hit));
      expect(guessResult[1].type, equals(HitType.hit));
      expect(guessResult[2].type, equals(HitType.hit));
      expect(guessResult[3].type, equals(HitType.miss));
      expect(guessResult[4].type, equals(HitType.miss));
    });

    test('Game loss state when all guesses used', () {
      final game = Game(seed: 0); // aback
      for (var i = 0; i < 5; i++) {
        expect(game.didLose, isFalse);
        game.guess('abase');
      }
      expect(game.guessesRemaining, equals(0));
      expect(game.activeIndex, equals(-1));
      expect(game.didWin, isFalse);
      expect(game.didLose, isTrue);
    });

    test('Game reset resets guesses and state', () {
      final game = Game(seed: 0);
      game.guess('abase');
      expect(game.activeIndex, equals(1));
      game.resetGame();
      expect(game.activeIndex, equals(0));
      expect(game.guessesRemaining, equals(5));
      expect(game.didWin, isFalse);
      expect(game.didLose, isFalse);
    });

    test('Word validation works correctly', () {
      final game = Game();
      expect(game.isLegalGuess('aback'), isTrue);
      expect(game.isLegalGuess('abort'), isTrue);
      expect(game.isLegalGuess('zzzzz'), isFalse);
    });
  });
}
