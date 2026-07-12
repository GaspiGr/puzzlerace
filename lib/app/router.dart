import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/category/screens/category_screen.dart';
import '../features/difficulty/screens/difficulty_screen.dart';
import '../features/game/models/puzzle_models.dart';
import '../features/game/screens/game_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.category,
        name: 'category',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final mode  = extra['mode'] as String? ?? 'solo';
          return CategoryScreen(mode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.difficulty,
        name: 'difficulty',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return DifficultyScreen(
            mode: extra['mode'] as String? ?? 'solo',
            categoryId: extra['categoryId'] as String? ?? 'naturaleza',
            categoryLabel: extra['categoryLabel'] as String? ?? 'Naturaleza',
            categoryEmoji: extra['categoryEmoji'] as String? ?? '🌿',
            categoryColor: extra['categoryColor'] as Color? ??
                const Color(0xFF40F080),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        builder: (context, state) {
          final config = state.extra as PuzzleConfig?;
          if (config == null) {
            // Acceso directo sin configuración: partida por defecto.
            return const GameScreen(
              config: PuzzleConfig(
                mode: 'solo',
                categoryId: 'naturaleza',
                categoryLabel: 'Naturaleza',
                categoryEmoji: '🌿',
                categoryColor: Color(0xFF40F080),
                difficulty: Difficulty.easy,
              ),
            );
          }
          return GameScreen(config: config);
        },
      ),
    ],
  );
});
