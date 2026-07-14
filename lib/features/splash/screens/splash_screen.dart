import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/theme.dart';
import '../../../../../core/constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Esperar a que terminen las animaciones (2.8s) + pequeño margen
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Fondo con gradiente radial
          Positioned.fill(
            child: CustomPaint(painter: _SplashBackgroundPainter()),
          ),

          // Contenido central
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono del puzzle animado
                _PuzzleIcon()
                    .animate()
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // Título "PuzzleRace"
                RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Puzzle',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -1.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Race',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accent,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 500.ms,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 8),

                // Subtítulo
                const Text(
                  'Compite. Arma. Gana.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

                const SizedBox(height: 64),

                // Indicador de carga
                _LoadingDots().animate().fadeIn(
                  delay: 1200.ms,
                  duration: 400.ms,
                ),
              ],
            ),
          ),

          // Versión en la parte inferior
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted.withValues(alpha: 0.4),
                letterSpacing: 1.0,
              ),
            ).animate().fadeIn(delay: 1500.ms, duration: 500.ms),
          ),
        ],
      ),
    );
  }
}

// ─── Ícono central del puzzle ──────────────────────────────────────────────

class _PuzzleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.extension_rounded, size: 54, color: AppTheme.accent),
      ),
    );
  }
}

// ─── Dots de carga animados ───────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            // Cada dot tiene un desfase en la animación
            final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final scale =
                0.6 + 0.4 * (1 - (offset - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.3 + 0.7 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Fondo personalizado ──────────────────────────────────────────────────

class _SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradiente radial central suave (dorado)
    final paintGold = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [AppTheme.accent.withValues(alpha: 0.07), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintGold);

    // Gradiente inferior (azul sutil)
    final paintBlue = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 1.2),
        radius: 0.6,
        colors: [
          AppTheme.accentBlue.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
