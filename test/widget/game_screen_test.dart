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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: GameScreen(config: testConfig)),
      ),
    );
    // Sin pumpAndSettle: el cronómetro de la partida programa frames
    // continuamente y nunca "asentaría".
    await tester.pump(const Duration(milliseconds: 700));
  }

  /// Monta una pantalla de inicio y abre la partida encima, para poder
  /// probar la salida hacia la pantalla anterior.
  Future<void> pumpGameOverHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final prefs = await mockPrefs();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GameScreen(config: testConfig),
                    ),
                  ),
                  child: const Text('Inicio'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Inicio'));
    // El primer frame de una ruta nueva se construye fuera de escena (para
    // medir las transiciones) y los finders lo ignoran: hace falta un
    // segundo frame para que la partida quede visible.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  /// Desmonta el árbol para que el provider autoDispose cancele su Timer.
  Future<void> tearDownGame(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('el tablero muestra todas las piezas de la dificultad', (
    tester,
  ) async {
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

  testWidgets('seleccionar y deseleccionar una pieza actualiza la ayuda', (
    tester,
  ) async {
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

  testWidgets('pausar congela la partida y muestra el overlay', (tester) async {
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

  testWidgets('iniciar una partida la registra en las estadísticas', (
    tester,
  ) async {
    final prefs = await mockPrefs();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: Consumer(
          builder: (context, ref, child) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(home: GameScreen(config: testConfig));
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(container.read(statsProvider).gamesPlayed, 1);
    expect(prefs.getInt('stats.gamesPlayed'), 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('salir pide confirmación y "Seguir jugando" retoma la partida', (
    tester,
  ) async {
    await pumpGameOverHome(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('¿Abandonar la partida?'), findsOneWidget);

    await tester.tap(find.text('Seguir jugando'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('¿Abandonar la partida?'), findsNothing);
    expect(find.byType(GameScreen), findsOneWidget);
    // La partida estaba en curso: se reanuda sin overlay de pausa.
    expect(find.text('Pausa'), findsNothing);

    await tearDownGame(tester);
  });

  testWidgets('"Abandonar" vuelve a la pantalla anterior', (tester) async {
    await pumpGameOverHome(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Abandonar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(GameScreen), findsNothing);
    expect(find.text('Inicio'), findsOneWidget);

    await tearDownGame(tester);
  });

  testWidgets('la partida se pausa al dejar la app en segundo plano', (
    tester,
  ) async {
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    await pumpGame(tester);
    expect(find.text('Pausa'), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pausa'), findsOneWidget);
    expect(find.text('El tiempo está detenido'), findsOneWidget);

    // Cerrar el overlay deja sin timers pendientes sus animaciones.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.text('Continuar'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pausa'), findsNothing);

    await tearDownGame(tester);
  });
}
