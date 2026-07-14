import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../game/models/puzzle_models.dart';
import '../../game/widgets/puzzle_art.dart';
import '../../stats/models/player_stats.dart';

/// Pantalla de fin de partida (ítem 5): tiempo, movimientos, récord y
/// acciones de revancha o volver.
class ResultsScreen extends StatelessWidget {
  final GameResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            // Desplazable si el contenido no cabe (pantallas bajas); en
            // pantallas altas los Spacer siguen centrando el contenido.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildContent(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final config = result.config;
    return Column(
      children: [
        const Spacer(),
        const Text('🏆', style: TextStyle(fontSize: 64)).animate().scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 800.ms,
        ),
        const SizedBox(height: 16),
        Text(
          '¡Puzzle completado!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 6),
        Text(
          '${config.categoryEmoji} ${config.imageName} · '
          '${config.difficulty.label} '
          '${config.difficulty.gridSize}×${config.difficulty.gridSize}',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 220.ms),
        const SizedBox(height: 24),
        _buildArtPreview(config).animate().fadeIn(delay: 280.ms),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ResultStat(
                icon: Icons.timer_rounded,
                value: result.formattedTime,
                label: 'Tiempo',
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultStat(
                icon: Icons.swap_horiz_rounded,
                value: '${result.moves}',
                label: 'Movimientos',
                color: AppTheme.accentBlue,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 14),
        _buildRecordBanner(context).animate().fadeIn(delay: 420.ms),
        const Spacer(),
        _buildActions(context)
            .animate()
            .fadeIn(delay: 500.ms)
            .slideY(begin: 0.2, end: 0, delay: 500.ms),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildArtPreview(PuzzleConfig config) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.categoryColor.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: CustomPaint(
          painter: PuzzleArtPainter(
            baseColor: config.categoryColor,
            seed: config.artSeed,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _buildRecordBanner(BuildContext context) {
    final isRecord = result.isNewRecord;
    final color = isRecord ? AppTheme.accent : AppTheme.textMuted;
    final String text;
    if (isRecord && result.previousBestSeconds == null) {
      text =
          '🎉 ¡Nuevo récord! Tu primer tiempo en '
          '${result.config.difficulty.label}';
    } else if (isRecord) {
      text =
          '🎉 ¡Nuevo récord! Antes: '
          '${PlayerStats.formatSeconds(result.previousBestSeconds)}';
    } else {
      text =
          'Tu mejor tiempo en ${result.config.difficulty.label}: '
          '${PlayerStats.formatSeconds(result.previousBestSeconds)}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isRecord ? AppTheme.accent : AppTheme.textMuted,
          fontSize: 13,
          fontWeight: isRecord ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                context.pushReplacement(AppRoutes.game, extra: result.config),
            icon: const Icon(Icons.replay_rounded, size: 20),
            label: const Text('Jugar de nuevo'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Volver al inicio'),
          ),
        ),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
