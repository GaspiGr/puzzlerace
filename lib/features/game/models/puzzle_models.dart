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
  final String imageId;
  final String imageName;
  final int imageSeed;

  /// Ruta de una foto elegida del dispositivo. Si no es nula, las piezas se
  /// recortan de esa imagen; si es nula, se usa el arte procedural del seed.
  final String? imageFilePath;
  final Difficulty difficulty;

  const PuzzleConfig({
    required this.mode,
    required this.categoryId,
    required this.categoryLabel,
    required this.categoryEmoji,
    required this.categoryColor,
    required this.imageId,
    required this.imageName,
    required this.imageSeed,
    this.imageFilePath,
    required this.difficulty,
  });

  /// Semilla determinística para generar el arte del puzzle.
  int get artSeed => imageSeed;

  @override
  bool operator ==(Object other) =>
      other is PuzzleConfig &&
      other.mode == mode &&
      other.categoryId == categoryId &&
      other.imageId == imageId &&
      other.imageFilePath == imageFilePath &&
      other.difficulty == difficulty;

  @override
  int get hashCode =>
      Object.hash(mode, categoryId, imageId, imageFilePath, difficulty);
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

  /// Solo con estado `won`: si la partida batió el récord de su dificultad
  /// y cuál era el mejor tiempo anterior.
  final bool isNewRecord;
  final int? previousBestSeconds;

  const GameState({
    required this.tiles,
    this.selectedIndex,
    this.moves = 0,
    this.seconds = 0,
    this.status = GameStatus.playing,
    this.isNewRecord = false,
    this.previousBestSeconds,
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
      isNewRecord: isNewRecord,
      previousBestSeconds: previousBestSeconds,
    );
  }

  GameState withSelection(int? index) {
    return GameState(
      tiles: tiles,
      selectedIndex: index,
      moves: moves,
      seconds: seconds,
      status: status,
      isNewRecord: isNewRecord,
      previousBestSeconds: previousBestSeconds,
    );
  }

  String get formattedTime {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Datos que la pantalla de juego entrega a la pantalla de resultados.
class GameResult {
  final PuzzleConfig config;
  final int seconds;
  final int moves;
  final bool isNewRecord;
  final int? previousBestSeconds;

  const GameResult({
    required this.config,
    required this.seconds,
    required this.moves,
    required this.isNewRecord,
    required this.previousBestSeconds,
  });

  String get formattedTime {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
