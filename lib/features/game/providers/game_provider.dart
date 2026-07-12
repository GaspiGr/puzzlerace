import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stats/providers/stats_provider.dart';
import '../logic/puzzle_engine.dart';
import '../models/puzzle_models.dart';

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this.config, this._stats)
      : super(GameState(
          tiles: PuzzleEngine.createShuffled(config.difficulty.tileCount),
        )) {
    _stats.recordGameStarted();
    _startTimer();
  }

  final PuzzleConfig config;
  final StatsNotifier _stats;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(seconds: state.seconds + 1);
      }
    });
  }

  /// Toca una casilla: selecciona, deselecciona o intercambia con la
  /// selección previa.
  void tapTile(int index) {
    if (state.status != GameStatus.playing) return;

    final selected = state.selectedIndex;
    if (selected == null) {
      state = state.withSelection(index);
      return;
    }
    if (selected == index) {
      state = state.withSelection(null);
      return;
    }

    final tiles = PuzzleEngine.swap(state.tiles, selected, index);
    if (PuzzleEngine.isSolved(tiles)) {
      _timer?.cancel();
      final outcome = _stats.recordWin(config.difficulty, state.seconds);
      state = GameState(
        tiles: tiles,
        moves: state.moves + 1,
        seconds: state.seconds,
        status: GameStatus.won,
        isNewRecord: outcome.isNewRecord,
        previousBestSeconds: outcome.previousBestSeconds,
      );
    } else {
      state = state
          .copyWith(tiles: tiles, moves: state.moves + 1)
          .withSelection(null);
    }
  }

  void pause() {
    if (state.status == GameStatus.playing) {
      state = state.withSelection(null).copyWith(status: GameStatus.paused);
    }
  }

  void resume() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  void restart() {
    state = GameState(
      tiles: PuzzleEngine.createShuffled(config.difficulty.tileCount),
    );
    _stats.recordGameStarted();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider.autoDispose
    .family<GameNotifier, GameState, PuzzleConfig>(
  (ref, config) => GameNotifier(config, ref.read(statsProvider.notifier)),
);
