import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/pexels_service.dart';
import '../../stats/providers/stats_provider.dart';

/// Fotos online por categoría (ítem 6b), con caché local para no agotar la
/// cuota de la API en cada visita a la galería.
///
/// Sin clave de Pexels configurada resuelve a lista vacía y la galería usa
/// el catálogo procedural, exactamente como antes.
final remoteImagesProvider = FutureProvider.family<List<PexelsPhoto>, String>((
  ref,
  categoryId,
) async {
  if (!PexelsService.isConfigured) return const [];

  final prefs = ref.watch(sharedPreferencesProvider);
  const ttl = Duration(hours: 6);
  final cacheKey = 'pexels.cache.$categoryId';
  final stampKey = 'pexels.stamp.$categoryId';

  final stamp = prefs.getInt(stampKey);
  final cached = prefs.getString(cacheKey);
  if (stamp != null && cached != null) {
    final age = DateTime.now().millisecondsSinceEpoch - stamp;
    if (age < ttl.inMilliseconds) {
      try {
        return PexelsService.parsePhotos(cached);
      } catch (_) {
        // Caché corrupta: se ignora y se vuelve a pedir.
      }
    }
  }

  try {
    final photos = await PexelsService().searchForCategory(categoryId);
    await prefs.setString(
      cacheKey,
      jsonEncode({
        'photos': [
          for (final p in photos)
            {
              'id': p.id,
              'photographer': p.photographer,
              'src': {'medium': p.thumbUrl, 'large': p.playUrl},
            },
        ],
      }),
    );
    await prefs.setInt(stampKey, DateTime.now().millisecondsSinceEpoch);
    return photos;
  } catch (_) {
    // Sin red o cuota agotada: si hay caché vieja, mejor eso que nada.
    if (cached != null) {
      try {
        return PexelsService.parsePhotos(cached);
      } catch (_) {}
    }
    return const [];
  }
});
