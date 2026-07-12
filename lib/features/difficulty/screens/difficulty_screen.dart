import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../game/models/puzzle_models.dart';

class DifficultyScreen extends StatefulWidget {
  final String mode;
  final String categoryId;
  final String categoryLabel;
  final String categoryEmoji;
  final Color categoryColor;

  const DifficultyScreen({
    super.key,
    required this.mode,
    required this.categoryId,
    required this.categoryLabel,
    required this.categoryEmoji,
    required this.categoryColor,
  });

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  Difficulty _selected = Difficulty.easy;

  void _startGame() {
    context.push(
      AppRoutes.game,
      extra: PuzzleConfig(
        mode: widget.mode,
        categoryId: widget.categoryId,
        categoryLabel: widget.categoryLabel,
        categoryEmoji: widget.categoryEmoji,
        categoryColor: widget.categoryColor,
        difficulty: _selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildCategoryBadge(context),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                itemCount: Difficulty.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final difficulty = Difficulty.values[i];
                  return _DifficultyCard(
                    difficulty: difficulty,
                    color: widget.categoryColor,
                    isSelected: _selected == difficulty,
                    onTap: () => setState(() => _selected = difficulty),
                  ).animate()
                      .fadeIn(delay: (250 + i * 90).ms)
                      .slideY(begin: 0.15, end: 0, delay: (250 + i * 90).ms);
                },
              ),
            ),
            _buildStartButton(context),
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
                Text('Elige la dificultad',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: -0.5))
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.15, end: 0, delay: 100.ms),
                Text('¿Qué tan rápido eres armando puzzles?',
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
    final color = widget.categoryColor;
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
            Text(widget.categoryEmoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Text(widget.categoryLabel,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(width: 1, height: 14, color: color.withOpacity(0.3)),
            const SizedBox(width: 8),
            Text(
              widget.mode == 'versus' ? 'Modo 1 vs 1' : 'Modo Solitario',
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

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _startGame,
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: const Text('¡A jugar!'),
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0, delay: 500.ms),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _MiniGridPreview(gridSize: difficulty.gridSize, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(difficulty.label,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 3),
                  Text(difficulty.description,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                    color: isSelected ? color : AppTheme.border, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 15, color: AppTheme.background)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniGridPreview extends StatelessWidget {
  final int gridSize;
  final Color color;

  const _MiniGridPreview({required this.gridSize, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: GridView.count(
        crossAxisCount: gridSize,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(gridSize * gridSize, (i) {
          return Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.10 + (i % 3) * 0.08),
              borderRadius: BorderRadius.circular(2.5),
              border: Border.all(color: color.withOpacity(0.25), width: 0.5),
            ),
          );
        }),
      ),
    );
  }
}
