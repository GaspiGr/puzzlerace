import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../stats/providers/stats_provider.dart';

/// Nombre del jugador, editable desde el perfil y persistido localmente.
class ProfileNameNotifier extends StateNotifier<String> {
  static const _key = 'profile.name';
  static const defaultName = 'Jugador';

  ProfileNameNotifier(this._prefs)
    : super(_prefs.getString(_key) ?? defaultName);

  final SharedPreferences _prefs;

  void setName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
    _prefs.setString(_key, trimmed);
  }
}

final profileNameProvider = StateNotifierProvider<ProfileNameNotifier, String>(
  (ref) => ProfileNameNotifier(ref.watch(sharedPreferencesProvider)),
);
