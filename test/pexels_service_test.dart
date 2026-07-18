import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/core/services/pexels_service.dart';

const _sampleBody = '''
{
  "page": 1,
  "photos": [
    {
      "id": 12345,
      "photographer": "Ana Fotógrafa",
      "src": {
        "original": "https://images.pexels.com/12345/original.jpg",
        "large": "https://images.pexels.com/12345/large.jpg",
        "medium": "https://images.pexels.com/12345/medium.jpg"
      }
    },
    {
      "id": 67890,
      "photographer": "Juan Cámara",
      "src": {
        "original": "https://images.pexels.com/67890/original.jpg"
      }
    },
    {
      "id": 11111,
      "photographer": "Sin Fotos",
      "src": {}
    }
  ]
}
''';

void main() {
  group('PexelsService.parsePhotos', () {
    test('parsea fotos con sus tamaños', () {
      final photos = PexelsService.parsePhotos(_sampleBody);
      expect(photos.length, 2);
      expect(photos.first.id, 12345);
      expect(photos.first.photographer, 'Ana Fotógrafa');
      expect(photos.first.thumbUrl, contains('medium.jpg'));
      expect(photos.first.playUrl, contains('large.jpg'));
    });

    test('sin medium/large cae al original', () {
      final photos = PexelsService.parsePhotos(_sampleBody);
      final fallback = photos[1];
      expect(fallback.thumbUrl, contains('original.jpg'));
      expect(fallback.playUrl, contains('original.jpg'));
    });

    test('descarta fotos sin URLs y tolera respuestas vacías', () {
      final photos = PexelsService.parsePhotos(_sampleBody);
      expect(photos.any((p) => p.id == 11111), isFalse);
      expect(PexelsService.parsePhotos('{"photos": []}'), isEmpty);
      expect(PexelsService.parsePhotos('{}'), isEmpty);
    });

    test('todas las categorías de la app tienen query', () {
      for (final id in [
        'naturaleza',
        'ciudades',
        'arte',
        'animales',
        'gastronomia',
        'espacio',
      ]) {
        expect(PexelsService.categoryQueries[id], isNotNull, reason: id);
      }
    });
  });
}
