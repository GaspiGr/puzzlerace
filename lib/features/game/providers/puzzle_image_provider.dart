import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Ancho máximo al decodificar fotos del dispositivo: suficiente para un
/// tablero nítido sin cargar en memoria una foto de cámara completa.
const int kMaxPuzzleImageWidth = 1080;

/// Decodifica (una sola vez por partida) la imagen real de la partida:
/// una ruta local (foto del dispositivo) o una URL http(s) (Pexels).
/// Con fuente nula resuelve a `null` y el tablero usa el arte procedural.
final puzzleImageProvider = FutureProvider.autoDispose
    .family<ui.Image?, String?>((ref, source) async {
      if (source == null) return null;
      final Uint8List bytes;
      if (source.startsWith('http')) {
        final response = await http.get(Uri.parse(source));
        if (response.statusCode != 200) {
          throw http.ClientException('HTTP ${response.statusCode}');
        }
        bytes = response.bodyBytes;
      } else {
        bytes = await File(source).readAsBytes();
      }
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: kMaxPuzzleImageWidth,
        allowUpscaling: false,
      );
      final frame = await codec.getNextFrame();
      ref.onDispose(frame.image.dispose);
      return frame.image;
    });
