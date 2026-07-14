import 'dart:ui';

/// Categoría de puzzles. Modelo compartido entre Home, la pantalla de
/// categorías y cualquier flujo futuro (antes estaba duplicado en ambas
/// pantallas con formatos distintos).
class PuzzleCategory {
  final String id;
  final String label;
  final String emoji;
  final String description;
  final Color color;
  final Color bgColor;

  const PuzzleCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.description,
    required this.color,
    required this.bgColor,
  });
}
