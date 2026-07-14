import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../logic/puzzle_engine.dart';
import '../models/puzzle_models.dart';
import '../providers/game_provider.dart';
import '../widgets/puzzle_board.dart';

class GameScreen extends ConsumerWidget {
  final PuzzleConfig config;
  const GameScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Al completar el puzzle se navega a la pantalla de resultados.
    ref.listen(gameProvider(config), (previous, next) {
      if (previous?.status != GameStatus.won && next.status == GameStatus.won) {
        context.pushReplacement(
          AppRoutes.results,
          extra: GameResult(
            config: config,
            seconds: next.seconds,
            moves: next.moves,
            isNewRecord: next.isNewRecord,
            previousBestSeconds: next.previousBestSeconds,
          ),
        );
      }
    });

    final state = ref.watch(gameProvider(config));
    final notifier = ref.read(gameProvider(config).notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, notifier),
                _buildStatsRow(context, state),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      PuzzleBoard(
                            config: config,
                            state: state,
                            onTileTap: notifier.tapTile,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                          ),
                ),
                const Spacer(),
                _buildFooterHint(context, state),
              ],
            ),
          ),
          if (state.status == GameStatus.paused)
            _PauseOverlay(onResume: notifier.resume),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${config.categoryEmoji} ${config.imageName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${config.categoryLabel} · ${config.difficulty.label} · '
                  '${config.difficulty.gridSize}×${config.difficulty.gridSize}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),
          ),
          _RoundIconButton(
            icon: Icons.pause_rounded,
            onTap: notifier.pause,
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, GameState state) {
    final correct = PuzzleEngine.correctCount(state.tiles);
    final total = config.difficulty.tileCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _GameStat(
              icon: Icons.timer_rounded,
              value: state.formattedTime,
              label: 'Tiempo',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _GameStat(
              icon: Icons.swap_horiz_rounded,
              value: '${state.moves}',
              label: 'Movimientos',
              color: AppTheme.accentBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _GameStat(
              icon: Icons.extension_rounded,
              value: '$correct/$total',
              label: 'Correctas',
              color: config.categoryColor,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms),
    );
  }

  Widget _buildFooterHint(BuildContext context, GameState state) {
    final hasSelection = state.selectedIndex != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        hasSelection
            ? 'Toca otra pieza para intercambiarlas'
            : 'Toca una pieza para seleccionarla',
        style: Theme.of(context).textTheme.bodySmall,
      ).animate().fadeIn(delay: 300.ms),
    );
  }
}

class _GameStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _GameStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 18),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  const _PauseOverlay({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return _Overlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.pause_circle_rounded,
            color: AppTheme.accent,
            size: 56,
          ),
          const SizedBox(height: 14),
          Text(
            'Pausa',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'El tiempo está detenido',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  final Widget child;
  const _Overlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppTheme.background.withValues(alpha: 0.82),
        alignment: Alignment.center,
        child:
            Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: child,
                )
                .animate()
                .fadeIn(duration: 250.ms)
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                ),
      ),
    );
  }
}
