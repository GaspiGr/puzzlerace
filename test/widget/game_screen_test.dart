import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_puzzlerace/features/game/models/puzzle_models.dart';
import 'package:proyecto_puzzlerace/features/game/screens/game_screen.dart';
import 'package:proyecto_puzzlerace/features/game/widgets/puzzle_board.dart';
import 'package:proyecto_puzzlerace/features/stats/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testConfig = PuzzleConfig(
  mode: 'solo',
  categoryId: 'naturaleza',
  categoryLabel: 'Naturaleza',
  categoryEmoji: '🌿',
  categoryColor: Color(0xFF40F080),
  imageId: 'nat_01',
  imageName: 'Bosque nublado',
  imageSeed: 1101,
  difficulty: Difficulty.easy,
);

void main() {
  Future<SharedPreferences> mockPrefs() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  Future<void> pumpGame(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final prefs = await mockPrefs();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: GameScreen(config: testConfig)),
    ));
    // Sin pumpAndSettle: el cronómetro de la partida programa frames
    // continuamente y nunca "asentaría".
    await tester.pump(const Duration(milliseconds: 700));
  }

  /// Desmonta el árbol para que el provider autoDispose cancele su Timer.
  Future<void> tearDownGame(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('el tablero muestra todas las piezas de la dificultad',
      (tester) async {
    await pumpGame(tester);

    final tiles = find.descendant(
      of: find.byType(PuzzleBoard),
      matching: find.byType(GestureDetector),
    );
    expect(tiles, findsNWidgets(Difficulty.easy.tileCount));
    expect(find.text('🌿 Bosque nublado'), findsOneWidget);
    expect(find.text('Tiempo'), findsOneWidget);
    expect(find.text('Movimientos'), findsOneWidget);

    await tearDownGame(tester);
  });

  testWidgets('seleccionar y deseleccionar una pieza actualiza la ayuda',
      (tester) async {
    await pumpGame(tester);

    expect(find.text('Toca una pieza para seleccionarla'), findsOneWidget);

    final tiles = find.descendant(
      of: find.byType(PuzzleBoard),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(tiles.first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Toca otra pieza para intercambiarlas'), findsOneWidget);

    // Tocar la misma pieza la deselecciona sin contar movimiento.
    await tester.tap(tiles.first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Toca una pieza para seleccionarla'), findsOneWidget);

    await tearDownGame(tester);
  });

  testWidgets('pausar congela la partida y muestra el overlay',
      (tester) async {
    await pumpGame(tester);

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pausa'), findsOneWidget);
    expect(find.text('El tiempo está detenido'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pausa'), findsNothing);

    await tearDownGame(tester);
  });

  testWidgets('iniciar una partida la registra en las estadísticas',
      (tester) async {
    final prefs = await mockPrefs();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late ProviderContainer container;
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Consumer(builder: (context, ref, child) {
        container = ProviderScope.containerOf(context);
        return const MaterialApp(home: GameScreen(config: testConfig));
      }),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(container.read(statsProvider).gamesPlayed, 1);
    expect(prefs.getInt('stats.gamesPlayed'), 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
