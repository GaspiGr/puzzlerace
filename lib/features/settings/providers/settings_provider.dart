import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../stats/providers/stats_provider.dart';

/// Preferencias del jugador (ítem 22), persistidas localmente.
class AppSettings {
  final bool soundEnabled;
  final bool hapticsEnabled;

  /// Números de ayuda sobre las piezas del tablero.
  final bool showHintsEnabled;

  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.showHintsEnabled = true,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? showHintsEnabled,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      showHintsEnabled: showHintsEnabled ?? this.showHintsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const _keySound = 'settings.sound';
  static const _keyHaptics = 'settings.haptics';
  static const _keyHints = 'settings.hints';

  SettingsNotifier(this._prefs)
    : super(
        AppSettings(
          soundEnabled: _prefs.getBool(_keySound) ?? true,
          hapticsEnabled: _prefs.getBool(_keyHaptics) ?? true,
          showHintsEnabled: _prefs.getBool(_keyHints) ?? true,
        ),
      );

  final SharedPreferences _prefs;

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    _prefs.setBool(_keySound, value);
  }

  void setHapticsEnabled(bool value) {
    state = state.copyWith(hapticsEnabled: value);
    _prefs.setBool(_keyHaptics, value);
  }

  void setShowHintsEnabled(bool value) {
    state = state.copyWith(showHintsEnabled: value);
    _prefs.setBool(_keyHints, value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(ref.watch(sharedPreferencesProvider)),
);
