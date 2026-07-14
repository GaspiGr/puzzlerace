import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/features/game/logic/image_crop.dart';

void main() {
  group('ImageCrop.squareCrop', () {
    test('imagen horizontal: recorta el cuadrado central', () {
      final crop = ImageCrop.squareCrop(1000, 600);
      expect(crop, const Rect.fromLTWH(200, 0, 600, 600));
    });

    test('imagen vertical: recorta el cuadrado central', () {
      final crop = ImageCrop.squareCrop(600, 1000);
      expect(crop, const Rect.fromLTWH(0, 200, 600, 600));
    });

    test('imagen cuadrada: usa la imagen completa', () {
      expect(
        ImageCrop.squareCrop(800, 800),
        const Rect.fromLTWH(0, 0, 800, 800),
      );
    });
  });

  group('ImageCrop.tileSource', () {
    test('las piezas cubren el recorte exactamente y sin solaparse', () {
      const grid = 3;
      final crop = ImageCrop.squareCrop(1000, 600);
      for (var id = 0; id < grid * grid; id++) {
        final tile = ImageCrop.tileSource(1000, 600, grid, id);
        expect(tile.width, closeTo(crop.width / grid, 0.001));
        expect(tile.height, closeTo(crop.height / grid, 0.001));
        expect(crop.contains(tile.topLeft), isTrue, reason: 'pieza $id');
      }

      // Primera y última pieza tocan las esquinas del recorte.
      final first = ImageCrop.tileSource(1000, 600, grid, 0);
      final last = ImageCrop.tileSource(1000, 600, grid, grid * grid - 1);
      expect(first.topLeft, crop.topLeft);
      expect(last.bottomRight, crop.bottomRight);
    });

    test('piezas contiguas comparten el borde', () {
      final left = ImageCrop.tileSource(900, 900, 3, 0);
      final right = ImageCrop.tileSource(900, 900, 3, 1);
      final below = ImageCrop.tileSource(900, 900, 3, 3);
      expect(right.left, left.right);
      expect(below.top, left.bottom);
    });
  });
}
