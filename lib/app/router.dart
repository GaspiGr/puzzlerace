import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../core/data/puzzle_catalog.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/category/screens/category_screen.dart';
import '../features/images/screens/image_select_screen.dart';
import '../features/difficulty/screens/difficulty_screen.dart';
import '../features/game/models/puzzle_models.dart';
import '../features/game/screens/game_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/results/screens/results_screen.dart';
import '../features/settings/screens/settings_screen.dart';

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
          final mode = extra['mode'] as String? ?? 'solo';
          return CategoryScreen(mode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.images,
        name: 'images',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ImageSelectScreen(
            mode: extra['mode'] as String? ?? 'solo',
            categoryId: extra['categoryId'] as String? ?? 'naturaleza',
            categoryLabel: extra['categoryLabel'] as String? ?? 'Naturaleza',
            categoryEmoji: extra['categoryEmoji'] as String? ?? '🌿',
            categoryColor:
                extra['categoryColor'] as Color? ?? const Color(0xFF40F080),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.difficulty,
        name: 'difficulty',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final categoryId = extra['categoryId'] as String? ?? 'naturaleza';
          final fallbackImage = PuzzleCatalog.forCategory(categoryId).first;
          return DifficultyScreen(
            mode: extra['mode'] as String? ?? 'solo',
            categoryId: categoryId,
            categoryLabel: extra['categoryLabel'] as String? ?? 'Naturaleza',
            categoryEmoji: extra['categoryEmoji'] as String? ?? '🌿',
            categoryColor:
                extra['categoryColor'] as Color? ?? const Color(0xFF40F080),
            imageId: extra['imageId'] as String? ?? fallbackImage.id,
            imageName: extra['imageName'] as String? ?? fallbackImage.name,
            imageSeed: extra['imageSeed'] as int? ?? fallbackImage.seed,
            imageFilePath: extra['imageFilePath'] as String?,
            imageUrl: extra['imageUrl'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        builder: (context, state) {
          final config = state.extra as PuzzleConfig?;
          if (config != null) return GameScreen(config: config);
          // Acceso directo sin configuración: partida por defecto.
          final image = PuzzleCatalog.forCategory('naturaleza').first;
          return GameScreen(
            config: PuzzleConfig(
              mode: 'solo',
              categoryId: 'naturaleza',
              categoryLabel: 'Naturaleza',
              categoryEmoji: '🌿',
              categoryColor: const Color(0xFF40F080),
              imageId: image.id,
              imageName: image.name,
              imageSeed: image.seed,
              difficulty: Difficulty.easy,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OnboardingScreen(
            fromSettings: extra['fromSettings'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        builder: (context, state) {
          final result = state.extra as GameResult?;
          // Sin resultado (acceso directo): no hay nada que mostrar.
          if (result == null) return const HomeScreen();
          return ResultsScreen(result: result);
        },
      ),
    ],
  );
});
