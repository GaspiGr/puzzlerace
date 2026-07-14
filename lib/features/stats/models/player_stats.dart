import '../../game/models/puzzle_models.dart';

/// Una partida completada, para el historial del perfil.
class GameHistoryEntry {
  final String categoryEmoji;
  final String categoryLabel;
  final Difficulty difficulty;
  final int seconds;
  final int moves;
  final DateTime date;

  const GameHistoryEntry({
    required this.categoryEmoji,
    required this.categoryLabel,
    required this.difficulty,
    required this.seconds,
    required this.moves,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'categoryEmoji': categoryEmoji,
    'categoryLabel': categoryLabel,
    'difficulty': difficulty.name,
    'seconds': seconds,
    'moves': moves,
    'date': date.toIso8601String(),
  };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry(
      categoryEmoji: json['categoryEmoji'] as String? ?? '🧩',
      categoryLabel: json['categoryLabel'] as String? ?? 'Puzzle',
      difficulty:
          Difficulty.values.asNameMap()[json['difficulty']] ?? Difficulty.easy,
      seconds: json['seconds'] as int? ?? 0,
      moves: json['moves'] as int? ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get formattedTime => PlayerStats.formatSeconds(seconds);
}

/// Estadísticas persistentes del jugador.
class PlayerStats {
  /// Máximo de partidas guardadas en el historial.
  static const int historyLimit = 10;

  final int gamesPlayed;
  final int wins;

  /// Mejor tiempo (en segundos) por dificultad. Sin entrada = sin récord aún.
  final Map<Difficulty, int> bestTimes;

  /// Últimas partidas completadas, la más reciente primero.
  final List<GameHistoryEntry> history;

  const PlayerStats({
    this.gamesPlayed = 0,
    this.wins = 0,
    this.bestTimes = const {},
    this.history = const [],
  });

  PlayerStats copyWith({
    int? gamesPlayed,
    int? wins,
    Map<Difficulty, int>? bestTimes,
    List<GameHistoryEntry>? history,
  }) {
    return PlayerStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      bestTimes: bestTimes ?? this.bestTimes,
      history: history ?? this.history,
    );
  }

  /// Porcentaje de victorias (0-100) sobre las partidas jugadas.
  int get winRate =>
      gamesPlayed == 0 ? 0 : ((wins / gamesPlayed) * 100).round();

  /// Mejor tiempo global entre todas las dificultades, o `null` si no hay.
  int? get bestOverallSeconds => bestTimes.values.isEmpty
      ? null
      : bestTimes.values.reduce((a, b) => a < b ? a : b);

  String get formattedBestOverall => formatSeconds(bestOverallSeconds);

  static String formatSeconds(int? seconds) {
    if (seconds == null) return '--';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Resultado de registrar una victoria: si batió el récord y cuál era antes.
class RecordOutcome {
  final bool isNewRecord;
  final int? previousBestSeconds;

  const RecordOutcome({
    required this.isNewRecord,
    required this.previousBestSeconds,
  });
}
