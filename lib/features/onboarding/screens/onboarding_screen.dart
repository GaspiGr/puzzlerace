import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../stats/providers/stats_provider.dart';

/// Clave de prefs: el tutorial ya fue visto.
const String kOnboardingSeenKey = 'onboarding.seen';

/// Tutorial de primera vez (ítem 21). También puede reabrirse desde Ajustes,
/// en cuyo caso el botón final vuelve atrás en vez de ir al Home.
class OnboardingScreen extends ConsumerStatefulWidget {
  final bool fromSettings;
  const OnboardingScreen({super.key, this.fromSettings = false});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🖼️',
      title: 'Elige tu imagen',
      body:
          'Escoge una categoría y una imagen del catálogo, '
          'o usa una foto de tu propia galería.',
    ),
    _OnboardingPage(
      emoji: '🧩',
      title: 'Intercambia las piezas',
      body:
          'Toca una pieza para seleccionarla y otra para intercambiarlas. '
          'Ordena todas para completar el puzzle.',
    ),
    _OnboardingPage(
      emoji: '⏱️',
      title: 'Corre contra el reloj',
      body:
          'Cada partida cuenta: bate tus mejores tiempos por dificultad '
          'y revisa tu historial en el perfil.',
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(sharedPreferencesProvider).setBool(kOnboardingSeenKey, true);
    if (widget.fromSettings) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Saltar',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final selected = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.accent : AppTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLast
                      ? _finish
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                  icon: Icon(
                    _isLast
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                  label: Text(_isLast ? '¡A jugar!' : 'Siguiente'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 56)),
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ).animate().fadeIn(delay: 180.ms),
        ],
      ),
    );
  }
}
