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
  });
}
