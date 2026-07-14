import 'dart:ui';

/// Matemática pura del recorte de una foto para el tablero.
///
/// El tablero es cuadrado, así que la imagen se recorta al cuadrado central
/// (estilo "cover") y cada pieza toma su región de ese recorte.
class ImageCrop {
  ImageCrop._();

  /// Cuadrado central de una imagen de `width`×`height` píxeles.
  static Rect squareCrop(double width, double height) {
    final side = width < height ? width : height;
    return Rect.fromLTWH((width - side) / 2, (height - side) / 2, side, side);
  }

  /// Región fuente (en píxeles de la imagen) de la pieza `tileId` en una
  /// grilla de `gridSize`×`gridSize`.
  static Rect tileSource(
    double width,
    double height,
    int gridSize,
    int tileId,
  ) {
    final crop = squareCrop(width, height);
    final tileSide = crop.width / gridSize;
    final row = tileId ~/ gridSize;
    final col = tileId % gridSize;
    return Rect.fromLTWH(
      crop.left + col * tileSide,
      crop.top + row * tileSide,
      tileSide,
      tileSide,
    );
  }
}
