import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../stats/providers/stats_provider.dart';

/// Notificación interna de la app (ítem 17): la campana del Home deja de ser
/// decorativa y muestra avisos generados localmente (bienvenida, récords).
/// Notificaciones push reales llegarán con el backend del modo online.
class AppNotification {
  final String emoji;
  final String title;
  final String body;
  final DateTime date;
  final bool read;

  const AppNotification({
    required this.emoji,
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
  });

  AppNotification asRead() => AppNotification(
    emoji: emoji,
    title: title,
    body: body,
    date: date,
    read: true,
  );

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'title': title,
    'body': body,
    'date': date.toIso8601String(),
    'read': read,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      emoji: json['emoji'] as String? ?? '🔔',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      read: json['read'] as bool? ?? false,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  static const _keyItems = 'notifications.items';
  static const _keyWelcomed = 'notifications.welcomed';

  /// Máximo de notificaciones guardadas.
  static const int limit = 20;

  NotificationsNotifier(this._prefs) : super(_load(_prefs)) {
    if (!(_prefs.getBool(_keyWelcomed) ?? false)) {
      add(
        emoji: '👋',
        title: '¡Bienvenido a PuzzleRace!',
        body: 'Arma puzzles contra el reloj y bate tus récords.',
      );
      _prefs.setBool(_keyWelcomed, true);
    }
  }

  final SharedPreferences _prefs;

  static List<AppNotification> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_keyItems);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  bool get hasUnread => state.any((n) => !n.read);

  void add({required String emoji, required String title, String body = ''}) {
    final items = [
      AppNotification(
        emoji: emoji,
        title: title,
        body: body,
        date: DateTime.now(),
      ),
      ...state,
    ];
    if (items.length > limit) items.removeRange(limit, items.length);
    state = items;
    _save();
  }

  void markAllRead() {
    if (!hasUnread) return;
    state = [for (final n in state) n.read ? n : n.asRead()];
    _save();
  }

  void _save() {
    _prefs.setString(
      _keyItems,
      jsonEncode(state.map((n) => n.toJson()).toList()),
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      (ref) => NotificationsNotifier(ref.watch(sharedPreferencesProvider)),
    );
