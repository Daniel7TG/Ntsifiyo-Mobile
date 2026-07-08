import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/models.dart';
import '../game_session.dart';
import '../logic/maze_generator.dart';
import '../widgets/game_widgets.dart';
import '../widgets/game_summary_view.dart';

class _MazeItem {
  final int pairId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  final int row;

  _MazeItem({
    required this.pairId,
    this.text,
    this.imageUrl,
    this.audioUrl,
    required this.row,
  });
}

/// Laberinto (mirror de LaberintoGameView.jsx): lleva cada concepto de la
/// entrada (izquierda) hasta su par en la salida (derecha) moviéndote por el
/// laberinto con el control táctil, antes de que acabe el tiempo.
class LaberintoGameView extends ConsumerStatefulWidget {
  final GameSession session;
  final VoidCallback onExit;

  const LaberintoGameView(
      {super.key, required this.session, required this.onExit});

  @override
  ConsumerState<LaberintoGameView> createState() =>
      _LaberintoGameViewState();
}

class _LaberintoGameViewState extends ConsumerState<LaberintoGameView> {
  late List<List<MazeCell>> _grid;
  late List<_MazeItem> _entrances;
  late List<_MazeItem> _exits;
  late List<Word> _wordList;

  int _avatarX = 0;
  int _avatarY = 0;
  _MazeItem? _carrying;
  String? _carryingSide; // 'entrance' | 'exit'
  final Set<int> _completed = {};
  bool _finished = false;
  int _timeLeft = 120;
  Timer? _timer;

  int get _width => _grid[0].length;
  int get _height => _grid.length;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final data = widget.session.data;
    final difficulty = data.difficult ?? 'MEDIUM';
    final dims = mazeDimensions(difficulty);
    final random = Random();

    _grid = generateMaze(dims.width, dims.height, random: random);

    final cfg0 = data.promptConfig;
    final cfg1 = data.answerConfig;
    final count = min(min(8, dims.height), data.words.length);
    final selected = [...data.words]..shuffle(random);
    final words = selected.take(count).toList();
    _wordList = words;

    List<int> randomRows(int n) =>
        ([for (var i = 0; i < dims.height; i++) i]..shuffle(random))
            .take(n)
            .toList();

    final rowsLeft = randomRows(words.length);
    final rowsRight = randomRows(words.length);
    final shuffledA = [...words]..shuffle(random);
    final shuffledB = [...words]..shuffle(random);

    _MazeItem build(Word w, GameConfig cfg, int row) => _MazeItem(
          pairId: w.id ?? 0,
          text: cfg.showText ? w.textFor(cfg) : null,
          imageUrl: cfg.showImage ? w.imageUrl : null,
          audioUrl: cfg.playAudio ? w.audioUrl : null,
          row: row,
        );

    _entrances = [
      for (var i = 0; i < shuffledA.length; i++)
        build(shuffledA[i], cfg0, rowsLeft[i]),
    ];
    _exits = [
      for (var i = 0; i < shuffledB.length; i++)
        build(shuffledB[i], cfg1, rowsRight[i]),
    ];

    _avatarX = dims.width ~/ 2;
    _avatarY = dims.height ~/ 2;
    _carrying = null;
    _carryingSide = null;
    _completed.clear();
    _finished = false;
    _timeLeft = 120;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() {
          _timeLeft = 0;
          _finished = true;
        });
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _move(int dx, int dy) {
    if (_finished) return;
    final cell = _grid[_avatarY][_avatarX];
    var nx = _avatarX;
    var ny = _avatarY;

    if (dx == 0 && dy == -1 && !cell.top) ny--;
    if (dx == 1 && dy == 0 && !cell.right) nx++;
    if (dx == 0 && dy == 1 && !cell.bottom) ny++;
    if (dx == -1 && dy == 0 && !cell.left) nx--;

    if (nx != _avatarX || ny != _avatarY) {
      setState(() {
        _avatarX = nx;
        _avatarY = ny;
      });
    }
  }

  void _select() {
    if (_finished) return;
    final atLeft = _avatarX == 0;
    final atRight = _avatarX == _width - 1;

    if (_carrying == null) {
      if (atLeft) {
        final entrance = _entrances
            .where((e) => e.row == _avatarY && !_completed.contains(e.pairId))
            .firstOrNull;
        if (entrance != null) {
          setState(() {
            _carrying = entrance;
            _carryingSide = 'entrance';
          });
          if ((entrance.audioUrl ?? '').isNotEmpty) {
            playWordAudio(entrance.audioUrl);
          }
        }
      } else if (atRight) {
        final exit = _exits
            .where((e) => e.row == _avatarY && !_completed.contains(e.pairId))
            .firstOrNull;
        if (exit != null) {
          setState(() {
            _carrying = exit;
            _carryingSide = 'exit';
          });
          if ((exit.audioUrl ?? '').isNotEmpty) playWordAudio(exit.audioUrl);
        }
      }
      return;
    }

    // Entregar en el borde opuesto
    if (_carryingSide == 'entrance' && atRight) {
      final hit = _exits
          .where((e) => e.row == _avatarY && !_completed.contains(e.pairId))
          .firstOrNull;
      _deliver(hit);
    } else if (_carryingSide == 'exit' && atLeft) {
      final hit = _entrances
          .where((e) => e.row == _avatarY && !_completed.contains(e.pairId))
          .firstOrNull;
      _deliver(hit);
    }
  }

  void _deliver(_MazeItem? hit) {
    final carrying = _carrying!;
    if (hit != null && hit.pairId == carrying.pairId) {
      setState(() {
        _completed.add(carrying.pairId);
        _carrying = null;
        _carryingSide = null;
      });
      showGameFeedback(context, correct: true);
      if (_completed.length >= _wordList.length) {
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _finished = true);
        });
      }
    } else {
      setState(() {
        _carrying = null;
        _carryingSide = null;
      });
      showGameFeedback(context, correct: false);
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (widget.session.data.words.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Laberinto')),
        body:
            const Center(child: Text('La actividad no tiene palabras.')),
      );
    }

    if (_finished) {
      return GameSummaryView(
        outcome: GameOutcome(
          correctAnswers: _completed.length,
          totalQuestions: _wordList.length,
          responseLogs: [
            for (final w in _wordList)
              ResponseLog(
                responseAnswerId: w.id,
                isCorrect: _completed.contains(w.id),
                wordText: w.spanishWord.isNotEmpty
                    ? w.spanishWord
                    : w.mazahuaWord,
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
        title: const Text('Laberinto'),
        leading: BackButton(onPressed: widget.onExit),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⏱ ${_formatTime(_timeLeft)}   ${_completed.length}/${_wordList.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _timeLeft <= 15
                      ? AppColors.error
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Objeto que llevas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _carrying == null
                  ? const Text(
                      'Ve a un borde y toca ✋ para tomar una carta',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Llevas: ',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            _carrying!.text ?? '🖼',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
            ),

            // Tablero: entradas | laberinto | salidas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _buildSideColumn(_entrances, isLeft: true),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: _width / _height,
                        child: CustomPaint(
                          painter: _MazePainter(
                            grid: _grid,
                            avatarX: _avatarX,
                            avatarY: _avatarY,
                            carrying: _carrying != null,
                          ),
                        ),
                      ),
                    ),
                    _buildSideColumn(_exits, isLeft: false),
                  ],
                ),
              ),
            ),

            // Controles: D-pad + tomar/entregar
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      _dpadButton(Icons.keyboard_arrow_up, () => _move(0, -1)),
                      Row(
                        children: [
                          _dpadButton(
                              Icons.keyboard_arrow_left, () => _move(-1, 0)),
                          const SizedBox(width: 44),
                          _dpadButton(
                              Icons.keyboard_arrow_right, () => _move(1, 0)),
                        ],
                      ),
                      _dpadButton(
                          Icons.keyboard_arrow_down, () => _move(0, 1)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _select,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: darken(AppColors.primary, 0.15),
                            width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: darken(AppColors.primary, 0.32),
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Center(
                        child: Text('✋', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideColumn(List<_MazeItem> items, {required bool isLeft}) {
    return SizedBox(
      width: 64,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rowHeight = constraints.maxHeight / _height;
          return Stack(
            children: [
              for (final item in items)
                Positioned(
                  top: item.row * rowHeight + (rowHeight - 52) / 2,
                  left: 4,
                  right: 4,
                  child: Opacity(
                    opacity: _completed.contains(item.pairId) ? 0.35 : 1,
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _carrying?.pairId == item.pairId &&
                                  ((isLeft && _carryingSide == 'entrance') ||
                                      (!isLeft && _carryingSide == 'exit'))
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: (item.imageUrl ?? '').isNotEmpty
                          ? WordImage(path: item.imageUrl)
                          : Center(
                              child: Text(
                                item.text ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _dpadButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0xFFCBD5E1), offset: Offset(0, 3)),
            ],
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 28),
        ),
      ),
    );
  }
}

class _MazePainter extends CustomPainter {
  final List<List<MazeCell>> grid;
  final int avatarX;
  final int avatarY;
  final bool carrying;

  _MazePainter({
    required this.grid,
    required this.avatarX,
    required this.avatarY,
    required this.carrying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = grid.length;
    final width = grid[0].length;
    final cw = size.width / width;
    final ch = size.height / height;

    // Fondo
    final bg = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      bg,
    );

    final wall = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final row in grid) {
      for (final cell in row) {
        final x = cell.x * cw;
        final y = cell.y * ch;
        if (cell.top) {
          canvas.drawLine(Offset(x, y), Offset(x + cw, y), wall);
        }
        if (cell.right) {
          canvas.drawLine(
              Offset(x + cw, y), Offset(x + cw, y + ch), wall);
        }
        if (cell.bottom) {
          canvas.drawLine(
              Offset(x, y + ch), Offset(x + cw, y + ch), wall);
        }
        if (cell.left) {
          canvas.drawLine(Offset(x, y), Offset(x, y + ch), wall);
        }
      }
    }

    // Avatar
    final avatarPaint = Paint()
      ..color = carrying ? AppColors.warning : AppColors.primary;
    canvas.drawCircle(
      Offset(avatarX * cw + cw / 2, avatarY * ch + ch / 2),
      min(cw, ch) * 0.3,
      avatarPaint,
    );
  }

  @override
  bool shouldRepaint(_MazePainter oldDelegate) =>
      oldDelegate.avatarX != avatarX ||
      oldDelegate.avatarY != avatarY ||
      oldDelegate.carrying != carrying;
}
