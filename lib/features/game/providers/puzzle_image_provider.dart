import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/puzzle_models.dart';
import '../widgets/puzzle_art.dart';

/// Lado máximo de la imagen del tablero: suficiente para que se vea nítido
/// sin cargar en memoria una foto de cámara completa.
const int kMaxPuzzleImageWidth = 1080;

/// Imagen completa de la partida, preparada una sola vez por partida:
/// - foto del dispositivo o de Pexels: se decodifica;
/// - arte procedural: se rasteriza a una imagen.
///
/// Así cada pieza solo copia su recorte (`drawImageRect`) en vez de volver a
/// dibujar la obra entera, que en 5×5 eran 25 dibujos completos por frame.
final puzzleImageProvider = FutureProvider.autoDispose
    .family<ui.Image, PuzzleConfig>((ref, config) async {
      // El dispose se registra antes de cualquier await: si la partida se
      // cierra mientras se prepara la imagen, no se usa `ref` ya liberado.
      var disposed = false;
      ui.Image? image;
      ref.onDispose(() {
        disposed = true;
        image?.dispose();
      });

      final source = config.imageSource;
      final result = source == null
          ? await _renderProcedural(config)
          : await _decode(source);

      if (disposed) {
        result.dispose();
      } else {
        image = result;
      }
      return result;
    });

Future<ui.Image> _renderProcedural(PuzzleConfig config) {
  const side = kMaxPuzzleImageWidth;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  PuzzleArt.paintFull(
    canvas,
    ui.Size.square(side.toDouble()),
    config.categoryColor,
    config.artSeed,
  );
  final picture = recorder.endRecording();
  return picture.toImage(side, side).whenComplete(picture.dispose);
}

Future<ui.Image> _decode(String source) async {
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
  codec.dispose();
  return frame.image;
}
