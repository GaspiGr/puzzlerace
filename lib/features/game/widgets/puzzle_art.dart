import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../logic/image_crop.dart';

/// Arte procedural determinístico del puzzle.
///
/// Mientras el proyecto no tenga assets de imágenes, cada puzzle se genera
/// dibujando composiciones abstractas (gradiente + formas grandes que cruzan
/// todo el lienzo) a partir de una semilla, de modo que las piezas tengan
/// continuidad visual y el mismo puzzle se vea idéntico en cada pieza.
class PuzzleArt {
  PuzzleArt._();

  /// Dibuja la obra completa ocupando `size` en el canvas.
  static void paintFull(Canvas canvas, Size size, Color base, int seed) {
    final rng = Random(seed);
    final rect = Offset.zero & size;
    final hsl = HSLColor.fromColor(base);

    Color shade(double hueShift, double sat, double light) => hsl
        .withHue((hsl.hue + hueShift) % 360)
        .withSaturation(sat.clamp(0.0, 1.0))
        .withLightness(light.clamp(0.0, 1.0))
        .toColor();

    // Fondo: gradiente diagonal oscuro derivado del color de la categoría.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            shade(-20, 0.55, 0.16),
            shade(15, 0.6, 0.28),
            shade(45, 0.5, 0.14),
          ],
        ).createShader(rect),
    );

    // Bandas diagonales que atraviesan el lienzo (continuidad entre piezas).
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.15 + rng.nextDouble() * 0.7);
      final tilt = (rng.nextDouble() - 0.5) * size.height * 0.9;
      final path = Path()
        ..moveTo(-size.width * 0.1, y)
        ..lineTo(size.width * 1.1, y + tilt)
        ..lineTo(size.width * 1.1, y + tilt + size.height * 0.08)
        ..lineTo(-size.width * 0.1, y + size.height * 0.08)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = shade(30.0 * i, 0.7, 0.5).withValues(alpha: 0.18),
      );
    }

    // Círculos y anillos grandes.
    for (var i = 0; i < 7; i++) {
      final center = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      );
      final radius = size.shortestSide * (0.08 + rng.nextDouble() * 0.22);
      final color = shade(rng.nextDouble() * 80 - 20, 0.75, 0.55);
      if (rng.nextBool()) {
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = color.withValues(alpha: 0.30 + rng.nextDouble() * 0.25),
        );
      } else {
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.shortestSide * 0.015
            ..color = color.withValues(alpha: 0.45),
        );
      }
    }

    // Puntos pequeños de textura.
    for (var i = 0; i < 24; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        size.shortestSide * (0.004 + rng.nextDouble() * 0.008),
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.25 + rng.nextDouble() * 0.3,
          ),
      );
    }
  }
}

/// Pinta la obra completa (vista previa en la galería de imágenes).
class PuzzleArtPainter extends CustomPainter {
  final Color baseColor;
  final int seed;

  const PuzzleArtPainter({required this.baseColor, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    PuzzleArt.paintFull(canvas, size, baseColor, seed);
    canvas.restore();
  }

  @override
  bool shouldRepaint(PuzzleArtPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor || oldDelegate.seed != seed;
}

/// Pinta una sola pieza: recorta la región `tileId` de la foto elegida
/// (si `image` no es nula) o de la obra procedural completa.
class PuzzleTilePainter extends CustomPainter {
  final int tileId;
  final int gridSize;
  final Color baseColor;
  final int seed;
  final ui.Image? image;
  final bool showHint;

  const PuzzleTilePainter({
    required this.tileId,
    required this.gridSize,
    required this.baseColor,
    required this.seed,
    this.image,
    this.showHint = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final img = image;
    if (img != null) {
      canvas.drawImageRect(
        img,
        ImageCrop.tileSource(
          img.width.toDouble(),
          img.height.toDouble(),
          gridSize,
          tileId,
        ),
        Offset.zero & size,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      final row = tileId ~/ gridSize;
      final col = tileId % gridSize;

      canvas.save();
      canvas.clipRect(Offset.zero & size);
      canvas.translate(-col * size.width, -row * size.height);
      PuzzleArt.paintFull(
        canvas,
        Size(size.width * gridSize, size.height * gridSize),
        baseColor,
        seed,
      );
      canvas.restore();
    }

    if (showHint) {
      final painter = TextPainter(
        text: TextSpan(
          text: '${tileId + 1}',
          style: TextStyle(
            color: AppTheme.textPrimary.withValues(alpha: 0.55),
            fontSize: size.shortestSide * 0.16,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pad = size.shortestSide * 0.07;
      painter.paint(canvas, Offset(pad, pad));
    }
  }

  @override
  bool shouldRepaint(PuzzleTilePainter oldDelegate) =>
      oldDelegate.tileId != tileId ||
      oldDelegate.gridSize != gridSize ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.seed != seed ||
      oldDelegate.image != image ||
      oldDelegate.showHint != showHint;
}
