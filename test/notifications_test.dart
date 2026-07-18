import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/features/notifications/providers/notifications_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  group('NotificationsNotifier', () {
    test('agrega la bienvenida solo la primera vez', () async {
      final prefs = await freshPrefs();
      final first = NotificationsNotifier(prefs);
      expect(first.state.length, 1);
      expect(first.state.first.title, contains('Bienvenido'));
      expect(first.hasUnread, isTrue);

      final second = NotificationsNotifier(prefs);
      expect(second.state.length, 1);
    });

    test('las nuevas notificaciones van primero y se limitan', () async {
      final prefs = await freshPrefs();
      final notifier = NotificationsNotifier(prefs);
      for (var i = 0; i < NotificationsNotifier.limit + 5; i++) {
        notifier.add(emoji: '🏆', title: 'Récord $i');
      }
      expect(notifier.state.length, NotificationsNotifier.limit);
      expect(
        notifier.state.first.title,
        'Récord ${NotificationsNotifier.limit + 4}',
      );
    });

    test('markAllRead apaga el indicador y persiste', () async {
      final prefs = await freshPrefs();
      final notifier = NotificationsNotifier(prefs);
      notifier.add(emoji: '🏆', title: 'Nuevo récord');
      expect(notifier.hasUnread, isTrue);

      notifier.markAllRead();
      expect(notifier.hasUnread, isFalse);

      final restored = NotificationsNotifier(prefs);
      expect(restored.hasUnread, isFalse);
      expect(restored.state.length, 2);
    });
  });
}
