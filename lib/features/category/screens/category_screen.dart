import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';

class CategoryScreen extends StatelessWidget {
  final String mode;
  const CategoryScreen({super.key, required this.mode});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(emoji: '🌿', label: 'Naturaleza',   description: 'Bosques, montañas, océanos y más', count: 120, color: Color(0xFF40F080), bgColor: Color(0xFF0D2B1A), id: 'naturaleza'),
    _CategoryItem(emoji: '🏙️', label: 'Ciudades',     description: 'Paisajes urbanos del mundo',       count: 98,  color: Color(0xFF40B0F0), bgColor: Color(0xFF0D1E2B), id: 'ciudades'),
    _CategoryItem(emoji: '🎨', label: 'Arte',          description: 'Pinturas, ilustraciones y diseño', count: 75,  color: Color(0xFFA060F0), bgColor: Color(0xFF1A0D2B), id: 'arte'),
    _CategoryItem(emoji: '🐾', label: 'Animales',      description: 'Fauna de todo el planeta',         count: 110, color: Color(0xFFE06030), bgColor: Color(0xFF2B150D), id: 'animales'),
    _CategoryItem(emoji: '🍜', label: 'Gastronomía',   description: 'Platos y cocinas del mundo',       count: 64,  color: Color(0xFFF0C040), bgColor: Color(0xFF2B220D), id: 'gastronomia'),
    _CategoryItem(emoji: '🚀', label: 'Espacio',       description: 'Galaxias, planetas y nebulosas',   count: 52,  color: Color(0xFF60D0C0), bgColor: Color(0xFF0D2228), id: 'espacio'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(top: -80, right: -80,
            child: Container(width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(0.04)))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildModeBadge(context),
                Expanded(child: _buildCategoriesGrid(context)),
              ],
            ),
          ),
        ],
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
              width: 42, height: 42,
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
                Text('Elige una categoría',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.5),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.15, end: 0, delay: 100.ms),
                Text('¿Qué tipo de imagen quieres armar?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 180.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBadge(BuildContext context) {
    final isVersus = mode == 'versus';
    final color    = isVersus ? AppTheme.accentBlue : AppTheme.accent;
    final icon     = isVersus ? Icons.sports_esports_rounded : Icons.timer_rounded;
    final label    = isVersus ? 'Modo 1 vs 1' : 'Modo Solitario';

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
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(width: 1, height: 14, color: color.withOpacity(0.3)),
            const SizedBox(width: 8),
            Text('Selecciona la imagen',
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0, delay: 250.ms);
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 14,
          crossAxisSpacing: 14, childAspectRatio: 0.88,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return _CategoryCard(
            category: cat,
            onTap: () => context.push(AppRoutes.difficulty, extra: {
              'mode': mode,
              'categoryId': cat.id,
              'categoryLabel': cat.label,
              'categoryEmoji': cat.emoji,
              'categoryColor': cat.color,
            }),
          ).animate()
            .fadeIn(delay: (300 + i * 70).ms)
            .slideY(begin: 0.15, end: 0, delay: (300 + i * 70).ms);
        },
      ),
    );
  }

}

class _CategoryCard extends StatefulWidget {
  final _CategoryItem category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          decoration: BoxDecoration(
            color: cat.bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cat.color.withOpacity(_pressed ? 0.6 : 0.2),
              width: _pressed ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cat.color.withOpacity(0.2)),
                      ),
                      child: Center(child: Text(cat.emoji,
                        style: const TextStyle(fontSize: 26))),
                    ),
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.arrow_forward_rounded, color: cat.color, size: 15),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.label,
                      style: const TextStyle(color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3)),
                    const SizedBox(height: 3),
                    Text(cat.description,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11,
                        fontWeight: FontWeight.w400, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: cat.color.withOpacity(0.25)),
                      ),
                      child: Text('${cat.count}+ puzzles',
                        style: TextStyle(color: cat.color, fontSize: 10,
                          fontWeight: FontWeight.w600)),
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

class _CategoryItem {
  final String emoji, label, description, id;
  final int count;
  final Color color, bgColor;
  const _CategoryItem({required this.emoji, required this.label,
    required this.description, required this.count, required this.color,
    required this.bgColor, required this.id});
}
