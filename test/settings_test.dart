import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/features/game/models/puzzle_models.dart';
import 'package:proyecto_puzzlerace/features/settings/providers/settings_provider.dart';
import 'package:proyecto_puzzlerace/features/stats/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsNotifier', () {
    test('sonido y vibración activados por defecto', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      expect(notifier.state.soundEnabled, isTrue);
      expect(notifier.state.hapticsEnabled, isTrue);
    });

    test('los cambios persisten entre sesiones', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);

      notifier.setSoundEnabled(false);
      notifier.setHapticsEnabled(false);

      final restored = SettingsNotifier(prefs);
      expect(restored.state.soundEnabled, isFalse);
      expect(restored.state.hapticsEnabled, isFalse);
    });
  });

  group('StatsNotifier.reset', () {
    test('borra estadísticas, récords e historial', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = StatsNotifier(prefs);

      notifier.recordGameStarted();
      notifier.recordWin(Difficulty.easy, 90, moves: 10);
      expect(notifier.state.wins, 1);

      await notifier.reset();
      expect(notifier.state.gamesPlayed, 0);
      expect(notifier.state.wins, 0);
      expect(notifier.state.bestTimes, isEmpty);
      expect(notifier.state.history, isEmpty);

      final restored = StatsNotifier(prefs);
      expect(restored.state.gamesPlayed, 0);
      expect(restored.state.bestTimes, isEmpty);
    });
  });
}
