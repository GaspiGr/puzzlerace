import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';
import 'package:proyecto_puzzlerace/features/game/models/puzzle_models.dart';
import 'package:proyecto_puzzlerace/features/results/screens/results_screen.dart';

const _config = PuzzleConfig(
  mode: 'solo',
  categoryId: 'espacio',
  categoryLabel: 'Espacio',
  categoryEmoji: '🚀',
  categoryColor: Color(0xFF60D0C0),
  imageId: 'esp_03',
  imageName: 'Vía Láctea',
  imageSeed: 6103,
  difficulty: Difficulty.medium,
);

Future<void> pumpResults(WidgetTester tester, GameResult result) async {
  usePhoneSurface(tester);
  await tester.pumpWidget(MaterialApp(home: ResultsScreen(result: result)));
  await settle(tester);
}

void main() {
  testWidgets('muestra tiempo, movimientos y la partida jugada', (
    tester,
  ) async {
    await pumpResults(
      tester,
      const GameResult(
        config: _config,
        seconds: 95,
        moves: 34,
        isNewRecord: false,
        previousBestSeconds: 80,
      ),
    );

    expect(find.text('¡Puzzle completado!'), findsOneWidget);
    expect(find.text('01:35'), findsOneWidget);
    expect(find.text('34'), findsOneWidget);
    expect(find.textContaining('Vía Láctea'), findsOneWidget);
    expect(find.text('Jugar de nuevo'), findsOneWidget);
    expect(find.text('Volver al inicio'), findsOneWidget);
  });

  testWidgets('sin récord muestra la mejor marca vigente', (tester) async {
    await pumpResults(
      tester,
      const GameResult(
        config: _config,
        seconds: 95,
        moves: 34,
        isNewRecord: false,
        previousBestSeconds: 80,
      ),
    );

    expect(find.textContaining('Tu mejor tiempo en Medio'), findsOneWidget);
    expect(find.textContaining('01:20'), findsOneWidget);
  });

  testWidgets('con récord muestra el banner de nuevo récord', (tester) async {
    await pumpResults(
      tester,
      const GameResult(
        config: _config,
        seconds: 70,
        moves: 28,
        isNewRecord: true,
        previousBestSeconds: 80,
      ),
    );

    expect(find.textContaining('¡Nuevo récord!'), findsOneWidget);
    expect(find.textContaining('01:20'), findsOneWidget);
  });

  testWidgets('la primera victoria se anuncia como primer tiempo', (
    tester,
  ) async {
    await pumpResults(
      tester,
      const GameResult(
        config: _config,
        seconds: 70,
        moves: 28,
        isNewRecord: true,
        previousBestSeconds: null,
      ),
    );

    expect(find.textContaining('Tu primer tiempo en Medio'), findsOneWidget);
  });
}
