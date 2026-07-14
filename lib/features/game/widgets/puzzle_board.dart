import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/puzzle_models.dart';
import 'puzzle_art.dart';

/// Tablero cuadrado con las piezas del puzzle. Tocar una pieza la selecciona;
/// tocar una segunda las intercambia.
class PuzzleBoard extends StatelessWidget {
  final PuzzleConfig config;
  final GameState state;
  final ValueChanged<int> onTileTap;

  /// Foto decodificada del dispositivo; nula = arte procedural.
  final ui.Image? image;

  const PuzzleBoard({
    super.key,
    required this.config,
    required this.state,
    required this.onTileTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final grid = config.difficulty.gridSize;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: grid,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: state.tiles.length,
          itemBuilder: (context, slot) {
            final tileId = state.tiles[slot];
            return _PuzzleTile(
              tileId: tileId,
              config: config,
              image: image,
              isSelected: state.selectedIndex == slot,
              isCorrect: tileId == slot,
              onTap: () => onTileTap(slot),
            );
          },
        ),
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  final int tileId;
  final PuzzleConfig config;
  final ui.Image? image;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  const _PuzzleTile({
    required this.tileId,
    required this.config,
    required this.image,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accent
                  : isCorrect
                  ? config.categoryColor.withValues(alpha: 0.55)
                  : AppTheme.border,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CustomPaint(
              painter: PuzzleTilePainter(
                tileId: tileId,
                gridSize: config.difficulty.gridSize,
                baseColor: config.categoryColor,
                seed: config.artSeed,
                image: image,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
