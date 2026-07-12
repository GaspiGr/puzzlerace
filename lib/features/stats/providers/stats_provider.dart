import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../game/models/puzzle_models.dart';
import '../models/player_stats.dart';

/// Instancia de SharedPreferences inyectada en `main()` antes de `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider debe sobreescribirse en main()',
  ),
);

class StatsNotifier extends StateNotifier<PlayerStats> {
  static const _keyGamesPlayed = 'stats.gamesPlayed';
  static const _keyWins = 'stats.wins';
  static String _keyBestTime(Difficulty d) => 'stats.bestTime.${d.name}';

  StatsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static PlayerStats _load(SharedPreferences prefs) {
    final bestTimes = <Difficulty, int>{};
    for (final d in Difficulty.values) {
      final seconds = prefs.getInt(_keyBestTime(d));
      if (seconds != null) bestTimes[d] = seconds;
    }
    return PlayerStats(
      gamesPlayed: prefs.getInt(_keyGamesPlayed) ?? 0,
      wins: prefs.getInt(_keyWins) ?? 0,
      bestTimes: bestTimes,
    );
  }

  /// Registra el inicio de una partida (cuenta como partida jugada).
  void recordGameStarted() {
    state = state.copyWith(gamesPlayed: state.gamesPlayed + 1);
    _save();
  }

  /// Registra una victoria y actualiza el mejor tiempo de la dificultad.
  RecordOutcome recordWin(Difficulty difficulty, int seconds) {
    final previous = state.bestTimes[difficulty];
    final isNewRecord = previous == null || seconds < previous;
    final bestTimes = Map<Difficulty, int>.of(state.bestTimes);
    if (isNewRecord) bestTimes[difficulty] = seconds;

    state = state.copyWith(wins: state.wins + 1, bestTimes: bestTimes);
    _save();
    return RecordOutcome(
      isNewRecord: isNewRecord,
      previousBestSeconds: previous,
    );
  }

  void _save() {
    _prefs.setInt(_keyGamesPlayed, state.gamesPlayed);
    _prefs.setInt(_keyWins, state.wins);
    for (final entry in state.bestTimes.entries) {
      _prefs.setInt(_keyBestTime(entry.key), entry.value);
    }
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, PlayerStats>(
  (ref) => StatsNotifier(ref.watch(sharedPreferencesProvider)),
);
