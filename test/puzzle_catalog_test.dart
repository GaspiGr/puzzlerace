import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/core/data/puzzle_catalog.dart';

void main() {
  group('PuzzleCatalog', () {
    const expectedCategories = [
      'naturaleza',
      'ciudades',
      'arte',
      'animales',
      'gastronomia',
      'espacio',
    ];

    test('cubre las 6 categorías de la app', () {
      expect(PuzzleCatalog.categoryIds, expectedCategories);
    });

    test('cada categoría tiene al menos 6 imágenes', () {
      for (final id in expectedCategories) {
        expect(
          PuzzleCatalog.forCategory(id).length,
          greaterThanOrEqualTo(6),
          reason: 'categoría $id',
        );
      }
    });

    test('los ids y seeds son únicos en todo el catálogo', () {
      final all = expectedCategories.expand(PuzzleCatalog.forCategory);
      final ids = all.map((i) => i.id).toList();
      final seeds = all.map((i) => i.seed).toList();
      expect(ids.toSet().length, ids.length);
      expect(seeds.toSet().length, seeds.length);
    });

    test('una categoría desconocida cae a la lista por defecto', () {
      expect(PuzzleCatalog.forCategory('inexistente'), isNotEmpty);
    });
  });
}
