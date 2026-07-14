/// Catálogo de imágenes de puzzle disponibles por categoría (ítem 6).
///
/// Mientras el proyecto no incluya fotografías reales en `assets/images/`,
/// cada "imagen" es una obra procedural determinística: la `seed` define la
/// composición que dibuja `PuzzleArt`, de modo que cada entrada del catálogo
/// se ve siempre igual. Cuando existan assets reales, este catálogo puede
/// ampliarse con una ruta de asset por imagen sin cambiar el resto del flujo.
class PuzzleImage {
  final String id;
  final String name;
  final int seed;

  const PuzzleImage({required this.id, required this.name, required this.seed});
}

class PuzzleCatalog {
  PuzzleCatalog._();

  static const Map<String, List<PuzzleImage>> _images = {
    'naturaleza': [
      PuzzleImage(id: 'nat_01', name: 'Bosque nublado', seed: 1101),
      PuzzleImage(id: 'nat_02', name: 'Atardecer andino', seed: 1102),
      PuzzleImage(id: 'nat_03', name: 'Cascada esmeralda', seed: 1103),
      PuzzleImage(id: 'nat_04', name: 'Pradera en flor', seed: 1104),
      PuzzleImage(id: 'nat_05', name: 'Aurora boreal', seed: 1105),
      PuzzleImage(id: 'nat_06', name: 'Costa salvaje', seed: 1106),
    ],
    'ciudades': [
      PuzzleImage(id: 'ciu_01', name: 'Neón de Tokio', seed: 2101),
      PuzzleImage(id: 'ciu_02', name: 'Tejados de París', seed: 2102),
      PuzzleImage(id: 'ciu_03', name: 'Skyline nocturno', seed: 2103),
      PuzzleImage(id: 'ciu_04', name: 'Callejón veneciano', seed: 2104),
      PuzzleImage(id: 'ciu_05', name: 'Metrópolis lluviosa', seed: 2105),
      PuzzleImage(id: 'ciu_06', name: 'Puerto al amanecer', seed: 2106),
    ],
    'arte': [
      PuzzleImage(id: 'art_01', name: 'Composición dorada', seed: 3101),
      PuzzleImage(id: 'art_02', name: 'Sueño violeta', seed: 3102),
      PuzzleImage(id: 'art_03', name: 'Geometría lírica', seed: 3103),
      PuzzleImage(id: 'art_04', name: 'Trazos nocturnos', seed: 3104),
      PuzzleImage(id: 'art_05', name: 'Mosaico moderno', seed: 3105),
      PuzzleImage(id: 'art_06', name: 'Abstracción cálida', seed: 3106),
    ],
    'animales': [
      PuzzleImage(id: 'ani_01', name: 'Tigre al acecho', seed: 4101),
      PuzzleImage(id: 'ani_02', name: 'Bandada al vuelo', seed: 4102),
      PuzzleImage(id: 'ani_03', name: 'Arrecife tropical', seed: 4103),
      PuzzleImage(id: 'ani_04', name: 'Manada en la sabana', seed: 4104),
      PuzzleImage(id: 'ani_05', name: 'Búho del bosque', seed: 4105),
      PuzzleImage(id: 'ani_06', name: 'Ballena austral', seed: 4106),
    ],
    'gastronomia': [
      PuzzleImage(id: 'gas_01', name: 'Ramen humeante', seed: 5101),
      PuzzleImage(id: 'gas_02', name: 'Mercado de especias', seed: 5102),
      PuzzleImage(id: 'gas_03', name: 'Dulces de feria', seed: 5103),
      PuzzleImage(id: 'gas_04', name: 'Cocina mediterránea', seed: 5104),
      PuzzleImage(id: 'gas_05', name: 'Frutas del trópico', seed: 5105),
      PuzzleImage(id: 'gas_06', name: 'Café de la mañana', seed: 5106),
    ],
    'espacio': [
      PuzzleImage(id: 'esp_01', name: 'Nebulosa carmesí', seed: 6101),
      PuzzleImage(id: 'esp_02', name: 'Anillos de Saturno', seed: 6102),
      PuzzleImage(id: 'esp_03', name: 'Vía Láctea', seed: 6103),
      PuzzleImage(id: 'esp_04', name: 'Eclipse lunar', seed: 6104),
      PuzzleImage(id: 'esp_05', name: 'Campo de estrellas', seed: 6105),
      PuzzleImage(id: 'esp_06', name: 'Cometa errante', seed: 6106),
    ],
  };

  static List<String> get categoryIds => _images.keys.toList();

  static List<PuzzleImage> forCategory(String categoryId) =>
      _images[categoryId] ?? _images.values.first;
}
