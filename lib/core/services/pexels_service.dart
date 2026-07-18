import 'dart:convert';
import 'package:http/http.dart' as http;

/// Foto del catálogo online de Pexels (ítem 6b).
class PexelsPhoto {
  final int id;
  final String photographer;

  /// Miniatura para la galería (~350px).
  final String thumbUrl;

  /// Tamaño de juego (~1200px, se recorta al tablero).
  final String playUrl;

  const PexelsPhoto({
    required this.id,
    required this.photographer,
    required this.thumbUrl,
    required this.playUrl,
  });

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) {
    final src = json['src'] as Map<String, dynamic>? ?? const {};
    return PexelsPhoto(
      id: json['id'] as int? ?? 0,
      photographer: json['photographer'] as String? ?? 'Pexels',
      thumbUrl: src['medium'] as String? ?? src['original'] as String? ?? '',
      playUrl: src['large'] as String? ?? src['original'] as String? ?? '',
    );
  }
}

/// Cliente mínimo de la API de Pexels.
///
/// La clave se inyecta en compilación y NUNCA se sube al repositorio:
/// `flutter run --dart-define=PEXELS_API_KEY=tu_clave`
/// Sin clave, la app funciona igual con el catálogo procedural local.
class PexelsService {
  static const String apiKey = String.fromEnvironment('PEXELS_API_KEY');

  static bool get isConfigured => apiKey.isNotEmpty;

  /// Query de búsqueda por categoría de la app.
  static const Map<String, String> categoryQueries = {
    'naturaleza': 'nature landscape',
    'ciudades': 'city skyline',
    'arte': 'abstract art painting',
    'animales': 'wild animals',
    'gastronomia': 'gourmet food',
    'espacio': 'galaxy space stars',
  };

  PexelsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<PexelsPhoto>> searchForCategory(
    String categoryId, {
    int perPage = 12,
  }) async {
    final query = categoryQueries[categoryId] ?? categoryId;
    final uri = Uri.https('api.pexels.com', '/v1/search', {
      'query': query,
      'per_page': '$perPage',
      'orientation': 'square',
    });
    final response = await _client.get(uri, headers: {'Authorization': apiKey});
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Pexels respondió ${response.statusCode}',
        uri,
      );
    }
    return parsePhotos(response.body);
  }

  /// Parseo puro y testeable de la respuesta JSON de Pexels.
  static List<PexelsPhoto> parsePhotos(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final photos = json['photos'] as List? ?? const [];
    return photos
        .map((e) => PexelsPhoto.fromJson(e as Map<String, dynamic>))
        .where((p) => p.thumbUrl.isNotEmpty && p.playUrl.isNotEmpty)
        .toList();
  }
}
