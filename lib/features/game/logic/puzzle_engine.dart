import 'dart:math';

/// Lógica pura del puzzle de intercambio de piezas.
///
/// El tablero se representa como `List<int>` donde la posición `i` contiene
/// el id de la pieza colocada ahí. Está resuelto cuando `tiles[i] == i`.
class PuzzleEngine {
  PuzzleEngine._();

  /// Genera un tablero mezclado, garantizando que no salga ya resuelto.
  static List<int> createShuffled(int tileCount, {Random? random}) {
    assert(tileCount > 1, 'Un puzzle necesita al menos 2 piezas');
    final rng = random ?? Random();
    final tiles = List<int>.generate(tileCount, (i) => i);
    do {
      tiles.shuffle(rng);
    } while (isSolved(tiles));
    return tiles;
  }

  /// Devuelve un tablero nuevo con las piezas de `a` y `b` intercambiadas.
  static List<int> swap(List<int> tiles, int a, int b) {
    final next = List<int>.of(tiles);
    final tmp = next[a];
    next[a] = next[b];
    next[b] = tmp;
    return next;
  }

  static bool isSolved(List<int> tiles) {
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) return false;
    }
    return true;
  }

  /// Cantidad de piezas que ya están en su casilla correcta.
  static int correctCount(List<int> tiles) {
    var count = 0;
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] == i) count++;
    }
    return count;
  }
}
