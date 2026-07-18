import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/settings_provider.dart';

/// Sonido y háptica del juego (ítem 18), respetando los Ajustes.
///
/// Usa los sonidos y vibraciones del sistema (sin assets de audio); si más
/// adelante se agregan efectos propios, este es el único punto a tocar.
class GameFeedback {
  const GameFeedback(this._settings);

  final AppSettings _settings;

  /// Toque sobre una pieza (seleccionar / deseleccionar).
  void tileTap() {
    if (_settings.hapticsEnabled) HapticFeedback.selectionClick();
    if (_settings.soundEnabled) SystemSound.play(SystemSoundType.click);
  }

  /// Intercambio de dos piezas.
  void swap() {
    if (_settings.hapticsEnabled) HapticFeedback.lightImpact();
    if (_settings.soundEnabled) SystemSound.play(SystemSoundType.click);
  }

  /// Puzzle completado.
  void win() {
    if (_settings.hapticsEnabled) HapticFeedback.heavyImpact();
  }
}

final gameFeedbackProvider = Provider<GameFeedback>(
  (ref) => GameFeedback(ref.watch(settingsProvider)),
);
