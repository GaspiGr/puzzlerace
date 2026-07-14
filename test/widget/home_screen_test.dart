import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils.dart';
import 'package:proyecto_puzzlerace/features/home/screens/home_screen.dart';
import 'package:proyecto_puzzlerace/features/profile/screens/profile_view.dart';
import 'package:proyecto_puzzlerace/features/stats/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> buildHome({Map<String, Object> prefsValues = const {}}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  testWidgets('muestra el saludo, los modos y las estadísticas guardadas', (
    tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(
      await buildHome(
        prefsValues: {
          'stats.wins': 5,
          'stats.gamesPlayed': 12,
          'stats.bestTime.easy': 83,
        },
      ),
    );
    await settle(tester);

    expect(find.text('¡Hola, Jugador! 👋'), findsOneWidget);
    expect(find.text('Solitario'), findsOneWidget);
    expect(find.text('1 vs 1'), findsOneWidget);
    // Estadísticas leídas de SharedPreferences, no hardcodeadas.
    expect(find.text('5'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('01:23'), findsOneWidget);
  });

  testWidgets('sin datos previos las estadísticas están en cero', (
    tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildHome());
    await settle(tester);

    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('--'), findsOneWidget);
  });

  testWidgets('el tab Perfil muestra la vista de perfil', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildHome());
    await settle(tester);

    await tester.tap(find.text('Perfil'));
    await settle(tester);

    expect(find.byType(ProfileView), findsOneWidget);
    expect(find.text('Jugador'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Mejores tiempos'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Aún no completas ningún puzzle'), findsOneWidget);
  });

  testWidgets('el perfil muestra los mejores tiempos por dificultad', (
    tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(
      await buildHome(
        prefsValues: {
          'stats.wins': 2,
          'stats.gamesPlayed': 4,
          'stats.bestTime.easy': 65,
          'stats.bestTime.hard': 305,
        },
      ),
    );
    await settle(tester);

    await tester.tap(find.text('Perfil'));
    await settle(tester);

    expect(find.text('01:05'), findsOneWidget); // Fácil
    expect(find.text('05:05'), findsOneWidget); // Difícil
    expect(find.text('--'), findsOneWidget); // Medio sin récord
    expect(find.text('50%'), findsOneWidget); // 2 de 4 completadas
  });

  testWidgets('el tab Ranking muestra el placeholder', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildHome());
    await settle(tester);

    await tester.tap(find.text('Ranking'));
    await settle(tester);

    expect(find.text('Ranking global'), findsOneWidget);
    expect(
      find.text('Disponible cuando llegue el modo online'),
      findsOneWidget,
    );
  });
}
