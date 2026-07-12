import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/features/game/logic/puzzle_engine.dart';
import 'package:proyecto_puzzlerace/features/game/models/puzzle_models.dart';

void main() {
  group('PuzzleEngine', () {
    test('createShuffled genera todas las piezas sin repetir', () {
      for (final difficulty in Difficulty.values) {
        final tiles = PuzzleEngine.createShuffled(difficulty.tileCount);
        expect(tiles.length, difficulty.tileCount);
        expect(tiles.toSet(), Set.of(List.generate(difficulty.tileCount, (i) => i)));
      }
    });

    test('createShuffled nunca devuelve un tablero ya resuelto', () {
      for (var seed = 0; seed < 200; seed++) {
        final tiles = PuzzleEngine.createShuffled(9, random: Random(seed));
        expect(PuzzleEngine.isSolved(tiles), isFalse);
      }
    });

    test('isSolved detecta el tablero ordenado', () {
      expect(PuzzleEngine.isSolved([0, 1, 2, 3]), isTrue);
      expect(PuzzleEngine.isSolved([1, 0, 2, 3]), isFalse);
    });

    test('swap intercambia dos piezas sin mutar el original', () {
      final original = [0, 1, 2, 3];
      final swapped = PuzzleEngine.swap(original, 0, 3);
      expect(swapped, [3, 1, 2, 0]);
      expect(original, [0, 1, 2, 3]);
    });

    test('swap puede resolver el puzzle', () {
      final tiles = PuzzleEngine.swap([1, 0, 2, 3], 0, 1);
      expect(PuzzleEngine.isSolved(tiles), isTrue);
    });

    test('correctCount cuenta las piezas en su lugar', () {
      expect(PuzzleEngine.correctCount([0, 1, 2, 3]), 4);
      expect(PuzzleEngine.correctCount([1, 0, 2, 3]), 2);
      expect(PuzzleEngine.correctCount([3, 2, 1, 0]), 0);
    });
  });

  group('Difficulty', () {
    test('los tamaños de grilla son 3, 4 y 5', () {
      expect(Difficulty.easy.gridSize, 3);
      expect(Difficulty.medium.gridSize, 4);
      expect(Difficulty.hard.gridSize, 5);
      expect(Difficulty.hard.tileCount, 25);
    });
  });

  group('GameState', () {
    test('formattedTime formatea minutos y segundos', () {
      expect(const GameState(tiles: [1, 0], seconds: 0).formattedTime, '00:00');
      expect(const GameState(tiles: [1, 0], seconds: 65).formattedTime, '01:05');
      expect(const GameState(tiles: [1, 0], seconds: 600).formattedTime, '10:00');
    });
  });
}
