import 'dart:ui';
import '../models/puzzle_category.dart';

/// Fuente única de las categorías de la app.
class AppCategories {
  AppCategories._();

  static const List<PuzzleCategory> all = [
    PuzzleCategory(id: 'naturaleza', label: 'Naturaleza', emoji: '🌿',
        description: 'Bosques, montañas, océanos y más',
        color: Color(0xFF40F080), bgColor: Color(0xFF0D2B1A)),
    PuzzleCategory(id: 'ciudades', label: 'Ciudades', emoji: '🏙️',
        description: 'Paisajes urbanos del mundo',
        color: Color(0xFF40B0F0), bgColor: Color(0xFF0D1E2B)),
    PuzzleCategory(id: 'arte', label: 'Arte', emoji: '🎨',
        description: 'Pinturas, ilustraciones y diseño',
        color: Color(0xFFA060F0), bgColor: Color(0xFF1A0D2B)),
    PuzzleCategory(id: 'animales', label: 'Animales', emoji: '🐾',
        description: 'Fauna de todo el planeta',
        color: Color(0xFFE06030), bgColor: Color(0xFF2B150D)),
    PuzzleCategory(id: 'gastronomia', label: 'Gastronomía', emoji: '🍜',
        description: 'Platos y cocinas del mundo',
        color: Color(0xFFF0C040), bgColor: Color(0xFF2B220D)),
    PuzzleCategory(id: 'espacio', label: 'Espacio', emoji: '🚀',
        description: 'Galaxias, planetas y nebulosas',
        color: Color(0xFF60D0C0), bgColor: Color(0xFF0D2228)),
  ];

  static PuzzleCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}
