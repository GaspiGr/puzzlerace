import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ancho máximo al decodificar fotos del dispositivo: suficiente para un
/// tablero nítido sin cargar en memoria una foto de cámara completa.
const int kMaxPuzzleImageWidth = 1080;

/// Decodifica (una sola vez por partida) la foto elegida del dispositivo.
/// Con ruta nula resuelve a `null` y el tablero usa el arte procedural.
final puzzleImageProvider = FutureProvider.autoDispose
    .family<ui.Image?, String?>((ref, path) async {
      if (path == null) return null;
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: kMaxPuzzleImageWidth,
        allowUpscaling: false,
      );
      final frame = await codec.getNextFrame();
      ref.onDispose(frame.image.dispose);
      return frame.image;
    });
