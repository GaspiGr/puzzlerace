import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';

/// Fila de 3 estrellas con [stars] encendidas (1 a 3).
class StarRating extends StatelessWidget {
  final int stars;
  final double size;

  /// Hace aparecer las estrellas una por una (pantalla de resultados).
  final bool animated;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 16,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$stars de 3 estrellas',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final earned = i < stars;
          final icon = Icon(
            earned ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: earned ? AppTheme.accent : AppTheme.textMuted,
          );
          if (!animated) return icon;
          return icon.animate().scale(
            begin: const Offset(0.2, 0.2),
            end: const Offset(1, 1),
            delay: (350 + i * 150).ms,
            duration: 500.ms,
            curve: Curves.elasticOut,
          );
        }),
      ),
    );
  }
}
