import 'dart:ui';

/// Niveles de dificultad disponibles para una partida.
enum Difficulty {
  easy(gridSize: 3, label: 'Fácil', description: '9 piezas · Relajado'),
  medium(gridSize: 4, label: 'Medio', description: '16 piezas · Equilibrado'),
  hard(gridSize: 5, label: 'Difícil', description: '25 piezas · Para expertos');

  const Difficulty({
    required this.gridSize,
    required this.label,
    required this.description,
  });

  final int gridSize;
  final String label;
  final String description;

  int get tileCount => gridSize * gridSize;
}

/// Configuración completa de una partida.
class PuzzleConfig {
  final String mode;
  final String categoryId;
  final String categoryLabel;
  final String categoryEmoji;
  final Color categoryColor;
  final Difficulty difficulty;

  const PuzzleConfig({
    required this.mode,
    required this.categoryId,
    required this.categoryLabel,
    required this.categoryEmoji,
    required this.categoryColor,
    required this.difficulty,
  });

  /// Semilla determinística para generar el arte del puzzle.
  int get artSeed =>
      categoryId.codeUnits.fold(7, (acc, unit) => acc * 31 + unit) +
      difficulty.index;

  @override
  bool operator ==(Object other) =>
      other is PuzzleConfig &&
      other.mode == mode &&
      other.categoryId == categoryId &&
      other.difficulty == difficulty;

  @override
  int get hashCode => Object.hash(mode, categoryId, difficulty);
}

enum GameStatus { playing, paused, won }

/// Estado inmutable de una partida en curso.
class GameState {
  /// `tiles[i]` es el id de la pieza colocada en la casilla `i`.
  /// El puzzle está resuelto cuando `tiles[i] == i` para todo `i`.
  final List<int> tiles;
  final int? selectedIndex;
  final int moves;
  final int seconds;
  final GameStatus status;

  const GameState({
    required this.tiles,
    this.selectedIndex,
    this.moves = 0,
    this.seconds = 0,
    this.status = GameStatus.playing,
  });

  GameState copyWith({
    List<int>? tiles,
    int? moves,
    int? seconds,
    GameStatus? status,
  }) {
    return GameState(
      tiles: tiles ?? this.tiles,
      selectedIndex: selectedIndex,
      moves: moves ?? this.moves,
      seconds: seconds ?? this.seconds,
      status: status ?? this.status,
    );
  }

  GameState withSelection(int? index) {
    return GameState(
      tiles: tiles,
      selectedIndex: index,
      moves: moves,
      seconds: seconds,
      status: status,
    );
  }

  String get formattedTime {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
