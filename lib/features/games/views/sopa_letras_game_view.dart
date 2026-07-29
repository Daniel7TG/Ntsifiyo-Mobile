import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/kid_card.dart';
import '../game_session.dart';
import '../logic/word_search_generator.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

/// Segundos de partida por dificultad (mirror de TIME_BY_DIFFICULTY).
const _timeByDifficulty = {
  Difficulty.easy: 180,
  Difficulty.medium: 150,
  Difficulty.hard: 120,
};

/// Sopa de Letras (mirror de SopaLetrasGameView.jsx): arrastra sobre la
/// cuadrícula para marcar cada palabra escondida (vale en ambos sentidos).
/// La partida es contrarreloj: al agotarse el tiempo cuenta lo encontrado.
class SopaLetrasGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const SopaLetrasGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<SopaLetrasGameView> createState() =>
      _SopaLetrasGameViewState();
}

class _SopaLetrasGameViewState extends ConsumerState<SopaLetrasGameView> {
  late WordSearchBoard _board;
  late List<Word> _targetWords;
  final Set<int> _foundIds = {};
  final Set<GridPos> _foundCells = {};
  List<GridPos> _selection = [];
  bool _finished = false;

  late int _totalTime;
  late int _timeLeft;
  Timer? _timer;

  GameConfig get _cfg => widget.session.data.promptConfig;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setup() {
    final data = widget.session.data;
    _targetWords = data.words;
    _board = generateWordSearch([
      for (final w in data.words)
        (id: w.id ?? 0, text: w.textFor(_cfg)),
    ]);
    _foundIds.clear();
    _foundCells.clear();
    _selection = [];
    _finished = false;
    _totalTime = _timeByDifficulty[data.difficult] ??
        _timeByDifficulty[Difficulty.medium]!;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _totalTime;
    if (_board.placements.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() {
          _timeLeft = 0;
          _finished = true;
        });
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _finished = true);
  }

  /// Convierte la posición del gesto a celda de la cuadrícula.
  GridPos? _cellAt(Offset local, double cellSize) {
    final c = (local.dx / cellSize).floor();
    final r = (local.dy / cellSize).floor();
    if (r < 0 || c < 0 || r >= _board.size || c >= _board.size) return null;
    return GridPos(r, c);
  }

  /// Traza recta desde el inicio: solo permite líneas en las 8 direcciones.
  List<GridPos> _lineBetween(GridPos start, GridPos end) {
    final dr = end.r - start.r;
    final dc = end.c - start.c;
    if (dr != 0 && dc != 0 && dr.abs() != dc.abs()) return [start];
    final steps = max(dr.abs(), dc.abs());
    final stepR = dr == 0 ? 0 : dr ~/ dr.abs();
    final stepC = dc == 0 ? 0 : dc ~/ dc.abs();
    return [
      for (var i = 0; i <= steps; i++)
        GridPos(start.r + stepR * i, start.c + stepC * i),
    ];
  }

  void _checkSelection() {
    if (_selection.length < 2) {
      setState(() => _selection = []);
      return;
    }
    for (final placement in _board.placements) {
      if (_foundIds.contains(placement.id)) continue;
      final cells = placement.cells;
      final forward = _sameCells(_selection, cells);
      final backward = _sameCells(_selection, cells.reversed.toList());
      if (forward || backward) {
        setState(() {
          _foundIds.add(placement.id);
          _foundCells.addAll(cells);
          _selection = [];
        });
        showGameFeedback(context, ref, correct: true);
        final word = _targetWords
            .where((w) => w.id == placement.id)
            .firstOrNull;
        if (word != null && (word.audioUrl ?? '').isNotEmpty) {
          playWordAudio(word.audioUrl);
        }
        if (_foundIds.length == _board.placements.length) {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) setState(() => _finished = true);
          });
        }
        return;
      }
    }
    setState(() => _selection = []);
  }

  bool _sameCells(List<GridPos> a, List<GridPos> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.data.words.isEmpty || _board.grid.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Sopa de Letras')),
        body: const Center(
            child: Text('No se pudo generar la sopa de letras.')),
      );
    }

    if (_finished) {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _foundIds.length,
          totalQuestions: _board.placements.length,
          responseLogs: [
            for (final p in _board.placements)
              ResponseLog(
                responseAnswerId: p.id,
                isCorrect: _foundIds.contains(p.id),
                wordText: p.text,
              ),
          ],
        ),
        onExit: widget.onExit,
        onRetry: () {
          ref.read(gameSessionProvider.notifier).restart();
          setState(_setup);
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Sopa de Letras'),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_foundIds.length}/${_board.placements.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            GameTimerBar(timeLeft: _timeLeft, total: _totalTime),

            // Cuadrícula
            Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gridSide = min(constraints.maxWidth,
                      MediaQuery.sizeOf(context).height * 0.52);
                  final cellSize = gridSide / _board.size;

                  return Center(
                    child: SizedBox(
                      width: gridSide,
                      height: gridSide,
                      child: GestureDetector(
                        onPanStart: (details) {
                          final cell =
                              _cellAt(details.localPosition, cellSize);
                          if (cell != null) {
                            setState(() => _selection = [cell]);
                          }
                        },
                        onPanUpdate: (details) {
                          if (_selection.isEmpty) return;
                          final cell =
                              _cellAt(details.localPosition, cellSize);
                          if (cell != null) {
                            setState(() => _selection =
                                _lineBetween(_selection.first, cell));
                          }
                        },
                        onPanEnd: (_) => _checkSelection(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                                color: AppColors.border, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xFFCBD5E1),
                                  offset: Offset(0, 4)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.card - 3),
                            child: CustomPaint(
                              painter: _GridPainter(
                                board: _board,
                                cellSize: cellSize,
                                selection: _selection.toSet(),
                                found: _foundCells,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Lista de palabras por encontrar
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final p in _board.placements)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _foundIds.contains(p.id)
                              ? AppColors.success.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _foundIds.contains(p.id)
                                ? AppColors.success
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          p.text,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            decoration: _foundIds.contains(p.id)
                                ? TextDecoration.lineThrough
                                : null,
                            color: _foundIds.contains(p.id)
                                ? AppColors.success
                                : AppColors.textMain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Terminar antes de tiempo
            Padding(
              padding: const EdgeInsets.all(12),
              child: KidBackButton(
                label: 'Terminar juego',
                icon: Icons.flag,
                onPressed: _finish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final WordSearchBoard board;
  final double cellSize;
  final Set<GridPos> selection;
  final Set<GridPos> found;

  _GridPainter({
    required this.board,
    required this.cellSize,
    required this.selection,
    required this.found,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1;
    final selectedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25);
    final foundPaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.22);

    for (var r = 0; r < board.size; r++) {
      for (var c = 0; c < board.size; c++) {
        final rect = Rect.fromLTWH(
            c * cellSize, r * cellSize, cellSize, cellSize);
        final pos = GridPos(r, c);
        if (found.contains(pos)) {
          canvas.drawRect(rect, foundPaint);
        }
        if (selection.contains(pos)) {
          canvas.drawRect(rect, selectedPaint);
        }
        canvas.drawRect(rect, linePaint..style = PaintingStyle.stroke);

        final tp = TextPainter(
          text: TextSpan(
            text: board.grid[r][c],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: cellSize * 0.45,
              color: AppColors.textMain,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            rect.left + (cellSize - tp.width) / 2,
            rect.top + (cellSize - tp.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.selection != selection || oldDelegate.found != found;
}
