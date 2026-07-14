import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/features/game/models/puzzle_models.dart';
import 'package:proyecto_puzzlerace/features/stats/models/player_stats.dart';
import 'package:proyecto_puzzlerace/features/stats/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerStats', () {
    test('formatSeconds formatea o devuelve -- sin valor', () {
      expect(PlayerStats.formatSeconds(null), '--');
      expect(PlayerStats.formatSeconds(0), '00:00');
      expect(PlayerStats.formatSeconds(75), '01:15');
    });

    test('bestOverallSeconds es el mínimo entre dificultades', () {
      const stats = PlayerStats(bestTimes: {
        Difficulty.easy: 90,
        Difficulty.medium: 45,
        Difficulty.hard: 200,
      });
      expect(stats.bestOverallSeconds, 45);
      expect(const PlayerStats().bestOverallSeconds, isNull);
      expect(const PlayerStats().formattedBestOverall, '--');
    });
  });

  group('StatsNotifier', () {
    late SharedPreferences prefs;
    late StatsNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      notifier = StatsNotifier(prefs);
    });

    test('inicia en cero sin datos previos', () {
      expect(notifier.state.gamesPlayed, 0);
      expect(notifier.state.wins, 0);
      expect(notifier.state.bestTimes, isEmpty);
    });

    test('recordGameStarted incrementa las partidas jugadas', () {
      notifier.recordGameStarted();
      notifier.recordGameStarted();
      expect(notifier.state.gamesPlayed, 2);
    });

    test('la primera victoria siempre es récord', () {
      final outcome = notifier.recordWin(Difficulty.easy, 120);
      expect(outcome.isNewRecord, isTrue);
      expect(outcome.previousBestSeconds, isNull);
      expect(notifier.state.wins, 1);
      expect(notifier.state.bestTimes[Difficulty.easy], 120);
    });

    test('un tiempo mejor actualiza el récord y uno peor no', () {
      notifier.recordWin(Difficulty.medium, 100);

      final better = notifier.recordWin(Difficulty.medium, 80);
      expect(better.isNewRecord, isTrue);
      expect(better.previousBestSeconds, 100);
      expect(notifier.state.bestTimes[Difficulty.medium], 80);

      final worse = notifier.recordWin(Difficulty.medium, 300);
      expect(worse.isNewRecord, isFalse);
      expect(worse.previousBestSeconds, 80);
      expect(notifier.state.bestTimes[Difficulty.medium], 80);
      expect(notifier.state.wins, 3);
    });

    test('los récords son independientes por dificultad', () {
      notifier.recordWin(Difficulty.easy, 60);
      notifier.recordWin(Difficulty.hard, 300);
      expect(notifier.state.bestTimes[Difficulty.easy], 60);
      expect(notifier.state.bestTimes[Difficulty.hard], 300);
      expect(notifier.state.bestOverallSeconds, 60);
    });

    test('las estadísticas persisten entre sesiones', () {
      notifier.recordGameStarted();
      notifier.recordWin(Difficulty.easy, 95);

      final restored = StatsNotifier(prefs);
      expect(restored.state.gamesPlayed, 1);
      expect(restored.state.wins, 1);
      expect(restored.state.bestTimes[Difficulty.easy], 95);
    });

    test('cada victoria se añade al historial, la más reciente primero', () {
      notifier.recordWin(Difficulty.easy, 90,
          moves: 12, categoryEmoji: '🌿', categoryLabel: 'Naturaleza');
      notifier.recordWin(Difficulty.hard, 300,
          moves: 60, categoryEmoji: '🚀', categoryLabel: 'Espacio');

      final history = notifier.state.history;
      expect(history.length, 2);
      expect(history.first.categoryLabel, 'Espacio');
      expect(history.first.difficulty, Difficulty.hard);
      expect(history.first.moves, 60);
      expect(history.last.categoryLabel, 'Naturaleza');
    });

    test('el historial se limita a las últimas ${PlayerStats.historyLimit}',
        () {
      for (var i = 0; i < PlayerStats.historyLimit + 5; i++) {
        notifier.recordWin(Difficulty.easy, 100 + i, moves: i);
      }
      expect(notifier.state.history.length, PlayerStats.historyLimit);
      // La más reciente es la última registrada.
      expect(notifier.state.history.first.moves,
          PlayerStats.historyLimit + 4);
    });

    test('el historial persiste entre sesiones', () {
      notifier.recordWin(Difficulty.medium, 120,
          moves: 25, categoryEmoji: '🎨', categoryLabel: 'Arte');

      final restored = StatsNotifier(prefs);
      expect(restored.state.history.length, 1);
      expect(restored.state.history.first.categoryLabel, 'Arte');
      expect(restored.state.history.first.seconds, 120);
      expect(restored.state.history.first.difficulty, Difficulty.medium);
    });

    test('un historial corrupto se descarta sin romper el resto', () async {
      SharedPreferences.setMockInitialValues({
        'stats.wins': 3,
        'stats.history': 'esto-no-es-json',
      });
      final corruptPrefs = await SharedPreferences.getInstance();
      final restored = StatsNotifier(corruptPrefs);
      expect(restored.state.wins, 3);
      expect(restored.state.history, isEmpty);
    });
  });

  group('PlayerStats.winRate', () {
    test('calcula el porcentaje de partidas completadas', () {
      expect(const PlayerStats().winRate, 0);
      expect(const PlayerStats(gamesPlayed: 4, wins: 2).winRate, 50);
      expect(const PlayerStats(gamesPlayed: 3, wins: 3).winRate, 100);
    });
  });
}
