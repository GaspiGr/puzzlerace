import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/data/puzzle_catalog.dart';
import '../../../core/services/pexels_service.dart';
import '../../game/widgets/puzzle_art.dart';
import '../providers/remote_images_provider.dart';

/// Galería de imágenes de la categoría elegida (ítem 4). Con la API de
/// Pexels configurada muestra fotos reales (ítem 6b); sin clave usa el
/// catálogo procedural local.
class ImageSelectScreen extends ConsumerWidget {
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
    context.push(
      AppRoutes.difficulty,
      extra: {
        'mode': mode,
        'categoryId': categoryId,
        'categoryLabel': categoryLabel,
        'categoryEmoji': categoryEmoji,
        'categoryColor': categoryColor,
        'imageId': image.id,
        'imageName': image.name,
        'imageSeed': image.seed,
      },
    );
  }

  void _selectRemote(BuildContext context, PexelsPhoto photo) {
    context.push(
      AppRoutes.difficulty,
      extra: {
        'mode': mode,
        'categoryId': categoryId,
        'categoryLabel': categoryLabel,
        'categoryEmoji': categoryEmoji,
        'categoryColor': categoryColor,
        'imageId': 'pexels_${photo.id}',
        'imageName': 'Foto de ${photo.photographer}',
        'imageSeed': photo.id,
        'imageUrl': photo.playUrl,
      },
    );
  }

  /// Abre la galería del dispositivo; con la foto elegida se sigue el mismo
  /// flujo de dificultad, recortándola al cuadrado central del tablero.
  Future<void> _pickFromDevice(BuildContext context) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la galería')),
      );
      return;
    }
    if (picked == null || !context.mounted) return;

    context.push(
      AppRoutes.difficulty,
      extra: {
        'mode': mode,
        'categoryId': categoryId,
        'categoryLabel': categoryLabel,
        'categoryEmoji': '📷',
        'categoryColor': categoryColor,
        'imageId': 'device_${DateTime.now().millisecondsSinceEpoch}',
        'imageName': 'Tu foto',
        'imageSeed': 0,
        'imageFilePath': picked.path,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = PuzzleCatalog.forCategory(categoryId);
    final photos =
        ref.watch(remoteImagesProvider(categoryId)).valueOrNull ??
        const <PexelsPhoto>[];
    final useRemote = photos.isNotEmpty;

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
                // La primera celda abre la galería del dispositivo.
                itemCount: (useRemote ? photos.length : images.length) + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _DeviceImageCard(
                          color: categoryColor,
                          onTap: () => _pickFromDevice(context),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.15, end: 0, delay: 300.ms);
                  }
                  final delay = (300 + i * 70).ms;
                  if (useRemote) {
                    final photo = photos[i - 1];
                    return _RemoteImageCard(
                          photo: photo,
                          color: categoryColor,
                          onTap: () => _selectRemote(context, photo),
                        )
                        .animate()
                        .fadeIn(delay: delay)
                        .slideY(begin: 0.15, end: 0, delay: delay);
                  }
                  final image = images[i - 1];
                  return _ImageCard(
                        image: image,
                        color: categoryColor,
                        onTap: () => _selectImage(context, image),
                      )
                      .animate()
                      .fadeIn(delay: delay)
                      .slideY(begin: 0.15, end: 0, delay: delay);
                },
              ),
            ),
            if (useRemote)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    'Fotos proporcionadas por Pexels',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
                size: 18,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      'Elige una imagen',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.15, end: 0, delay: 100.ms),
                Text(
                  'Esta será tu puzzle a armar',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 180.ms),
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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(categoryEmoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                categoryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 14,
              color: color.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                mode == 'versus' ? 'Modo 1 vs 1' : 'Modo Solitario',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
              color: widget.color.withValues(alpha: _pressed ? 0.6 : 0.2),
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
                      child: Text(
                        widget.image.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.color,
                      size: 15,
                    ),
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

/// Tarjeta "Tu galería": elegir una foto propia del dispositivo.
class _DeviceImageCard extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;

  const _DeviceImageCard({required this.color, required this.onTap});

  @override
  State<_DeviceImageCard> createState() => _DeviceImageCardState();
}

class _DeviceImageCardState extends State<_DeviceImageCard> {
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
              color: widget.color.withValues(alpha: _pressed ? 0.6 : 0.35),
              width: _pressed ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  color: widget.color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu galería',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Elige una foto propia',
                style: TextStyle(
                  color: AppTheme.textMuted.withValues(alpha: 0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de una foto del catálogo online (Pexels).
class _RemoteImageCard extends StatefulWidget {
  final PexelsPhoto photo;
  final Color color;
  final VoidCallback onTap;

  const _RemoteImageCard({
    required this.photo,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RemoteImageCard> createState() => _RemoteImageCardState();
}

class _RemoteImageCardState extends State<_RemoteImageCard> {
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
              color: widget.color.withValues(alpha: _pressed ? 0.6 : 0.2),
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
                    child: Image.network(
                      widget.photo.thumbUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppTheme.surface2,
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surface2,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.photo.photographer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.color,
                      size: 15,
                    ),
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
