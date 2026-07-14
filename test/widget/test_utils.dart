import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simula el tamaño lógico de un teléfono para evitar overflows de layout.
void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Asienta la UI descargando también los Timers de duración cero que
/// programa flutter_animate al montar animaciones.
///
/// `pumpAndSettle` solo avanza el reloj mientras haya frames agendados, así
/// que puede terminar con esos Timers aún pendientes y el test falla con
/// "A Timer is still pending". Un pump con avance de reloj los dispara; la
/// segunda ronda cubre animaciones montadas durante la primera.
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}
