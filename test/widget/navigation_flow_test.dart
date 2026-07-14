import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_puzzlerace/core/constants/app_routes.dart';
import 'package:proyecto_puzzlerace/features/category/screens/category_screen.dart';
import 'package:proyecto_puzzlerace/features/difficulty/screens/difficulty_screen.dart';
import 'package:proyecto_puzzlerace/features/home/screens/home_screen.dart';
import 'package:proyecto_puzzlerace/features/images/screens/image_select_screen.dart';
import 'package:proyecto_puzzlerace/features/stats/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Router de prueba con el tramo del flujo previo a la partida.
GoRouter buildTestRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.category,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CategoryScreen(mode: extra['mode'] as String? ?? 'solo');
        },
      ),
      GoRoute(
        path: AppRoutes.images,
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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return DifficultyScreen(
            mode: extra['mode'] as String? ?? 'solo',
            categoryId: extra['categoryId'] as String? ?? 'naturaleza',
            categoryLabel: extra['categoryLabel'] as String? ?? 'Naturaleza',
            categoryEmoji: extra['categoryEmoji'] as String? ?? '🌿',
            categoryColor:
                extra['categoryColor'] as Color? ?? const Color(0xFF40F080),
            imageId: extra['imageId'] as String? ?? 'nat_01',
            imageName: extra['imageName'] as String? ?? 'Bosque nublado',
            imageSeed: extra['imageSeed'] as int? ?? 1101,
          );
        },
      ),
    ],
  );
}

Future<Widget> buildApp(GoRouter router) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('flujo completo: Home → Categoría → Imagen → Dificultad', (
    tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildApp(buildTestRouter()));
    await tester.pumpAndSettle();

    // Home → Categoría
    await tester.tap(find.text('Solitario'));
    await tester.pumpAndSettle();
    expect(find.text('Elige una categoría'), findsOneWidget);
    expect(find.text('Modo Solitario'), findsOneWidget);

    // La pantalla lista las 6 categorías del modelo compartido.
    for (final label in [
      'Naturaleza',
      'Ciudades',
      'Arte',
      'Animales',
      'Gastronomía',
      'Espacio',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    // Categoría → Imagen
    await tester.tap(find.text('Naturaleza'));
    await tester.pumpAndSettle();
    expect(find.text('Elige una imagen'), findsOneWidget);
    expect(find.text('Bosque nublado'), findsOneWidget);
    // La galería ofrece elegir una foto del dispositivo.
    expect(find.text('Tu galería'), findsOneWidget);

    // Imagen → Dificultad
    await tester.tap(find.text('Bosque nublado'));
    await tester.pumpAndSettle();
    expect(find.text('Elige la dificultad'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
    expect(find.text('Medio'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
    expect(find.text('¡A jugar!'), findsOneWidget);
  });

  testWidgets('el modo 1 vs 1 llega a categorías con su badge', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildApp(buildTestRouter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1 vs 1'));
    await tester.pumpAndSettle();
    expect(find.text('Modo 1 vs 1'), findsOneWidget);
  });
}
