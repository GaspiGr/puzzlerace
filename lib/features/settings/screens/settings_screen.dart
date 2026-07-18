import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/settings_provider.dart';

/// Pantalla de Ajustes (ítem 22): sonido, vibración, tutorial y datos.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _buildHeader(context).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 24),
            const _SectionTitle('Juego').animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.volume_up_rounded,
                  title: 'Sonido',
                  subtitle: 'Efectos al mover piezas',
                  value: settings.soundEnabled,
                  onChanged: notifier.setSoundEnabled,
                ),
                const Divider(height: 1, color: AppTheme.border),
                _SwitchTile(
                  icon: Icons.vibration_rounded,
                  title: 'Vibración',
                  subtitle: 'Respuesta háptica al jugar',
                  value: settings.hapticsEnabled,
                  onChanged: notifier.setHapticsEnabled,
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 24),
            const _SectionTitle('Ayuda').animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.school_rounded,
                  title: 'Ver el tutorial',
                  subtitle: 'Repasa cómo se juega',
                  onTap: () => context.push(
                    AppRoutes.onboarding,
                    extra: {'fromSettings': true},
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 24),
            const _SectionTitle('Datos').animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Restablecer estadísticas',
                  subtitle: 'Borra victorias, récords e historial',
                  destructive: true,
                  onTap: () => _confirmReset(context, ref),
                ),
              ],
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'PuzzleRace v1.0.0 · Hecho con Flutter',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Ajustes',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text(
          '¿Restablecer estadísticas?',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
        ),
        content: const Text(
          'Se borrarán tus victorias, partidas, mejores tiempos e historial. '
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: AppTheme.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(statsProvider.notifier).reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estadísticas restablecidas')),
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.accent, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
      ),
      // El color del switch sale de colorScheme.primary (accent) del tema.
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppTheme.accentOrange : AppTheme.accent;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppTheme.textMuted,
        size: 14,
      ),
      onTap: onTap,
    );
  }
}
