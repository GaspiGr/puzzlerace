import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/data/puzzle_catalog.dart';
import '../../game/widgets/puzzle_art.dart';

/// Galería de imágenes disponibles para la categoría elegida (ítem 4).
class ImageSelectScreen extends StatelessWidget {
  final String mode;
  final String categoryId;
  final String categoryLabel;
  final String categoryEmoji;
  final Color categoryColor;

  const ImageSelectScreen({
    super.key,
    required this.mode,
    required this.categoryId,
    required this.categoryLabel,
    required this.categoryEmoji,
    required this.categoryColor,
  });

  void _selectImage(BuildContext context, PuzzleImage image) {
    context.push(AppRoutes.difficulty, extra: {
      'mode': mode,
      'categoryId': categoryId,
      'categoryLabel': categoryLabel,
      'categoryEmoji': categoryEmoji,
      'categoryColor': categoryColor,
      'imageId': image.id,
      'imageName': image.name,
      'imageSeed': image.seed,
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = PuzzleCatalog.forCategory(categoryId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildCategoryBadge(context),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: images.length,
                itemBuilder: (context, i) {
                  final image = images[i];
                  return _ImageCard(
                    image: image,
                    color: categoryColor,
                    onTap: () => _selectImage(context, image),
                  ).animate()
                      .fadeIn(delay: (300 + i * 70).ms)
                      .slideY(begin: 0.15, end: 0, delay: (300 + i * 70).ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary, size: 18),
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elige una imagen',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                letterSpacing: -0.5))
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.15, end: 0, delay: 100.ms),
                Text('Esta será tu puzzle a armar',
                        style: Theme.of(context).textTheme.bodyMedium)
                    .animate()
                    .fadeIn(delay: 180.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final color = categoryColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(categoryEmoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Text(categoryLabel,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(width: 1, height: 14, color: color.withOpacity(0.3)),
            const SizedBox(width: 8),
            Text(
              mode == 'versus' ? 'Modo 1 vs 1' : 'Modo Solitario',
              style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0, delay: 250.ms);
  }
}

class _ImageCard extends StatefulWidget {
  final PuzzleImage image;
  final Color color;
  final VoidCallback onTap;

  const _ImageCard({
    required this.image,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.color.withOpacity(_pressed ? 0.6 : 0.2),
              width: _pressed ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(
                      painter: PuzzleArtPainter(
                        baseColor: widget.color,
                        seed: widget.image.seed,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.image.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: -0.2)),
                    ),
                    Icon(Icons.arrow_forward_rounded,
                        color: widget.color, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
