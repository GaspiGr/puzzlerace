import '../../game/models/puzzle_models.dart';

/// Estadísticas persistentes del jugador.
class PlayerStats {
  final int gamesPlayed;
  final int wins;

  /// Mejor tiempo (en segundos) por dificultad. Sin entrada = sin récord aún.
  final Map<Difficulty, int> bestTimes;

  const PlayerStats({
    this.gamesPlayed = 0,
    this.wins = 0,
    this.bestTimes = const {},
  });

  PlayerStats copyWith({
    int? gamesPlayed,
    int? wins,
    Map<Difficulty, int>? bestTimes,
  }) {
    return PlayerStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      bestTimes: bestTimes ?? this.bestTimes,
    );
  }

  /// Mejor tiempo global entre todas las dificultades, o `null` si no hay.
  int? get bestOverallSeconds =>
      bestTimes.values.isEmpty ? null : bestTimes.values.reduce((a, b) => a < b ? a : b);

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
